import {
  Env, ATOM, COMPOUND, compound, atom, numberTerm,
  deref, unify, freshTerm, copyResolved, termIsGround, listFromItems,
  flattenConjunction,
} from './kernel/term.js';
import { parseGoalText } from './kernel/parser.js';
import { primitive, primitiveKeys } from './builtins.js';
import { key, is, text, variables, conjunction, variant } from './common.js';
import { renderProof, checkProof } from './proof.js';

import { Program, validateControls } from './program.js';
export { Program } from './program.js';
const callable = (term) => term?.type === ATOM || term?.type === COMPOUND;

// A derivation chain is as deep as the search that produced it, so resolve the
// forest with an explicit stack rather than by recursion.
const resolveOne = (node, env) => ({
  ...node, goal: copyResolved(node.goal, env),
  bindings: node.bindings.map(([name, value]) => [name, copyResolved(value, env)]),
  children: new Array(node.children.length),
});
function resolveNode(node, env) {
  const root = resolveOne(node, env);
  const pending = [{ source: node, target: root }];
  while (pending.length) {
    const { source, target } = pending.pop();
    for (const [index, child] of source.children.entries()) {
      const copy = resolveOne(child, env);
      target.children[index] = copy;
      if (child.children.length) pending.push({ source: child, target: copy });
    }
  }
  return root;
}
const BUILTIN = atom('builtin'), CONTROL = atom('control'), ABSENT = atom('absent'), COLLECTED = atom('collected');
const primitiveNode = (goal, by = BUILTIN, children = []) => ({ goal, by, bindings: [], children });

// Proof nodes are recorded only when a proof is asked for. Without one, frames
// share this empty list and a finished body has nothing to hand back, so the
// search keeps only what it needs to find answers.
const NO_NODES = Object.freeze([]);
const QUIET = Object.freeze({ goal: null, by: null, bindings: NO_NODES, cut: null });
const SPLICE = 'splice';
const advance = (frame, node, recording) =>
  ({ ...frame, index: frame.index + 1, nodes: recording ? [...frame.nodes, node] : NO_NODES });
const childFrame = (parent, goals, pending, depth, recording) =>
  ({ goals, index: 0, nodes: recording ? [] : NO_NODES, parent, pending, depth });
const controlPending = (goal, cut, recording) =>
  (recording || cut !== null ? { goal, by: CONTROL, bindings: NO_NODES, cut } : QUIET);
// A finished body hands its nodes to the frame that started it: a conjunction
// splices them in place, anything else wraps them as one step's children.
function closeFrame(frame, recording) {
  const parent = frame.parent;
  if (!recording) return { ...parent, index: parent.index + 1 };
  const nodes = frame.pending === SPLICE
    ? [...parent.nodes, ...frame.nodes]
    : [...parent.nodes, {
      goal: frame.pending.goal, by: frame.pending.by, bindings: frame.pending.bindings, children: frame.nodes,
    }];
  return { ...parent, index: parent.index + 1, nodes };
}

const alternativeCount = (point) =>
  (point.kind === 'branch' ? point.alternatives.length : point.facts.length + point.clauses.length);

export class Solver {
  constructor(program, options = {}) {
    this.program = program;
    this.options = options;
    this.recording = Boolean(options.proof);
    this.serial = 0;
    this.facts = new Map();
    this.factKeys = new Set(program.groundFactKeys);
    this.derived = [];
    this.reported = new Map();
    this.stats = { inferences: 0, rounds: 0, derived: 0 };
    this.haltCode = null;
  }
  budget(depth) {
    if (depth > (this.options.maxDepth ?? 1000000)) throw new Error('backward reasoning exceeded maxDepth');
    if (++this.stats.inferences > (this.options.maxInferences ?? 1000000)) throw new Error('reasoning exceeded maxInferences');
  }
  // Backward search runs as an explicit machine rather than nested generators.
  // Every conjunct and every clause body would otherwise cost host stack
  // frames, so a long derivation chain exhausts the stack long before it
  // reaches maxDepth. A frame is one body being worked through; frames are
  // immutable, so a choice point only has to remember the frame it was made in
  // and backtracking is a pointer assignment rather than an undo log.
  //
  // Proof nodes keep the terms they were built from and are resolved once, by
  // whoever consumes a complete answer. Resolving at every conjunct instead
  // would deep-copy the whole forest once per goal in the body.
  // One substitution is threaded through the whole search and restored by the
  // trail on backtracking, so an answer's bindings are only valid until the
  // next one is requested. Every consumer here copies what it needs first.
  *solve(goals, env = new Env(), depth = 0) {
    const recording = this.recording;
    let frame = { goals, index: 0, nodes: recording ? [] : NO_NODES, parent: null, pending: null, depth };
    const choices = [];
    const entry = env.mark();
    let failed = false;
    try {
      for (;;) {
        if (failed) {
          const point = choices[choices.length - 1];
          if (point === undefined) return;
          env.undo(point.mark);
          const resumed = this.retry(point, env);
          if (resumed === null) { choices.pop(); continue; }
          frame = resumed;
          failed = false;
          continue;
        }
        if (frame.index >= frame.goals.length) {
          if (frame.parent === null) { yield { env, nodes: frame.nodes }; failed = true; continue; }
          // once/1 commits to its first solution by discarding the choice
          // points its own goal created.
          if (frame.pending.cut != null && choices.length > frame.pending.cut) choices.length = frame.pending.cut;
          frame = closeFrame(frame, recording);
          continue;
        }
        this.budget(frame.depth);
        const goal = deref(frame.goals[frame.index], env);
        if (!callable(goal)) throw new Error(`expected a callable goal, got ${text(goal)}`);
        validateControls(goal);
        const step = this.step(goal, frame, env, choices);
        if (step === null) { failed = true; continue; }
        frame = step;
      }
    } finally {
      env.undo(entry);
    }
  }
  // Start one goal. Returns the frame to continue from, or null when the goal
  // has no solution at all.
  step(goal, frame, env, choices) {
    const recording = this.recording;
    if (is(goal, ',', 2)) return childFrame(frame, flattenConjunction(goal), SPLICE, frame.depth, recording);
    if (is(goal, '\\+', 1)) {
      // Negation is a test, not a way to bind its variables.
      if (!termIsGround(goal.args[0], env)) throw new Error('negation requires a ground goal');
      const mark = env.mark();
      const iterator = this.solve([goal.args[0]], env, frame.depth + 1);
      let absent;
      try { absent = iterator.next().done; } finally { iterator.return(); env.undo(mark); }
      return absent ? advance(frame, recording ? primitiveNode(goal, ABSENT) : null, recording) : null;
    }
    if (is(goal, 'findall', 3)) {
      const items = [];
      const mark = env.mark();
      for (const answer of this.solve([goal.args[1]], env, frame.depth + 1)) {
        items.push(freshTerm(copyResolved(goal.args[0], answer.env), `collection${++this.serial}`));
      }
      env.undo(mark);
      if (!unify(goal.args[2], listFromItems(items), env)) { env.undo(mark); return null; }
      return advance(frame, recording ? primitiveNode(goal, COLLECTED) : null, recording);
    }
    let point;
    const id = key(goal);
    if (is(goal, ';', 2)) {
      point = { kind: 'branch', frame, mark: env.mark(), goal, alternatives: goal.args, position: 0 };
    } else if (is(goal, 'call', 1) || is(goal, 'once', 1)) {
      const cut = goal.name === 'once' ? choices.length : null;
      return childFrame(frame, [goal.args[0]], controlPending(goal, cut, recording), frame.depth + 1, recording);
    } else if (primitiveKeys.has(id)) {
      point = { kind: 'primitive', frame, mark: env.mark(), goal, iterator: primitive(goal, env) };
    } else {
      // Derived facts are tried before source clauses. Both lists are read in
      // place: neither changes while a search runs.
      point = {
        kind: 'resolve', frame, mark: env.mark(), goal,
        facts: this.facts.get(id) ?? NO_NODES, clauses: this.program.candidates(goal, env, id), position: 0,
      };
    }
    const step = this.retry(point, env);
    if (step === null) return null;
    if (point.kind === 'primitive' || point.position < alternativeCount(point)) choices.push(point);
    return step;
  }
  // Take the next untried alternative of a choice point, or null when it has
  // none left. The caller has already undone the bindings of the previous one.
  retry(point, env) {
    if (point.kind === 'primitive') {
      const next = point.iterator.next();
      return next.done ? null : advance(point.frame, this.recording ? primitiveNode(point.goal) : null, this.recording);
    }
    const recording = this.recording;
    while (point.position < alternativeCount(point)) {
      const position = point.position++;
      if (point.kind === 'branch') {
        return childFrame(point.frame, [point.alternatives[position]], controlPending(point.goal, null, recording),
          point.frame.depth + 1, recording);
      }
      if (position < point.facts.length) {
        const fact = point.facts[position];
        if (unify(point.goal, fact.goal, env)) return advance(point.frame, fact, recording);
        env.undo(point.mark);
        continue;
      }
      const clause = point.clauses[position - point.facts.length];
      const names = new Map();
      const head = freshTerm(clause.head, ++this.serial, names);
      const body = clause.body.map((item) => freshTerm(item, this.serial, names));
      if (!unify(point.goal, head, env)) { env.undo(point.mark); continue; }
      const pending = recording ? {
        goal: point.goal,
        by: compound(body.length ? 'rule' : 'fact', [numberTerm(clause.id)]),
        bindings: [...names],
        cut: null,
      } : QUIET;
      return childFrame(point.frame, body, pending, point.frame.depth + 1, recording);
    }
    return null;
  }
  // A rule whose heads are all `true` only publishes output. When the caller
  // asks its own question that output is discarded, so the rule has nothing to
  // contribute and solving its body would be wasted work.
  forward(reporting = true) {
    // Each rule's heads share a stratum. A rule with multiple heads runs only
    // after every prerequisite has reached its fixpoint.
    const layers = new Map();
    for (const clause of this.program.forward) {
      const rank = this.program.strata.get(clause.id) ?? 0;
      if (!layers.has(rank)) layers.set(rank, []);
      layers.get(rank).push(clause);
    }
    for (const [, rules] of [...layers].sort(([a], [b]) => a - b)) {
      let changed = true;
      let rounds = 0;
      while (changed) {
        if (++rounds > (this.options.maxIterations ?? 1000)) throw new Error('forward reasoning exceeded maxIterations');
        this.stats.rounds++; changed = false;
        for (const clause of rules) {
          if (!reporting && clause.heads.every((item) => is(item, 'true', 0))) continue;
          const names = new Map();
          const head = freshTerm(clause.head, ++this.serial, names);
          const body = clause.body.map((item) => freshTerm(item, this.serial, names));
          // An answer's bindings last only until the next one is requested, and
          // adding facts mid-scan would extend a live search, so copy each
          // activation out first and add the conclusions afterwards.
          const activations = [];
          for (const answer of this.solve(body)) {
            const mark = answer.env.mark();
            // Residual head variables become
            // sk_0, sk_1, ... within each conclusion, with sharing preserved.
            const unresolved = variables(copyResolved(head, answer.env));
            let skolem = 0;
            for (const value of unresolved.values()) unify(value, atom(`sk_${skolem++}`), answer.env);
            const conclusions = flattenConjunction(head).map((item) => copyResolved(item, answer.env));
            activations.push({
              conclusions,
              children: this.recording ? answer.nodes.map((node) => resolveNode(node, answer.env)) : NO_NODES,
              bindings: this.recording ? [...names].map(([name, value]) => [name, copyResolved(value, answer.env)]) : NO_NODES,
              claim: conclusions.some((item) => is(item, 'true', 0))
                ? copyResolved(conjunction(body), answer.env) : null,
            });
            answer.env.undo(mark);
          }
          for (const { conclusions, children, bindings, claim } of activations) {
            for (const conclusion of conclusions) {
              if (is(conclusion, 'true', 0)) {
                if (!this.reported.has(text(claim))) this.reported.set(text(claim), { claim, children });
                continue;
              }
              const node = { goal: conclusion, by: compound('rule', [numberTerm(clause.id)]), bindings, children };
              if (is(conclusion, 'false', 0)) { this.derived.push(node); this.haltCode = 65; return; }
              if (this.factKeys.has(text(conclusion))) continue;
              this.factKeys.add(text(conclusion));
              if (!this.facts.has(key(conclusion))) this.facts.set(key(conclusion), []);
              this.facts.get(key(conclusion)).push(node);
              this.derived.push(node); this.stats.derived++; changed = true;
            }
          }
        }
      }
    }
  }
}

export function run(source, options = {}) {
  try {
    return reason(source, options);
  } catch (error) {
    // Search itself is iterative, but a few term walks are still recursive, so
    // a term nested deeply enough can exhaust the host stack. Report that
    // boundary in the language's own terms instead of leaking the host's.
    if (error instanceof RangeError && /call stack/i.test(error.message)) {
      throw new Error('reasoning exhausted the host stack on a deeply nested term');
    }
    throw error;
  }
}

function reason(source, options) {
  const program = source instanceof Program ? source : Program.parse(source);
  const solver = new Solver(program, options);
  const goals = options.goals ?? (options.goal == null ? [] : [options.goal]);
  solver.forward(goals.length === 0);
  const roots = [];
  const bindings = [];
  const claims = [];
  const seen = new Set();
  if (goals.length && solver.haltCode == null) {
    for (const requested of goals) {
      const goal = typeof requested === 'string' ? parseGoalText(requested) : requested;
      validateControls(goal);
      for (const answer of solver.solve([goal])) {
        const conclusion = copyResolved(goal, answer.env);
        const id = variant(conclusion);
        if (seen.has(id)) continue;
        seen.add(id);
        if (options.proof) for (const node of answer.nodes) roots.push(resolveNode(node, answer.env));
        claims.push(conclusion);
        bindings.push(Object.fromEntries([...variables(goal)].filter(([name]) => !name.startsWith('_')).map(([name, value]) => [name, text(value, answer.env)])));
      }
    }
  } else if (solver.haltCode == null && solver.reported.size) {
    for (const report of solver.reported.values()) {
      claims.push(report.claim);
      for (const child of report.children) roots.push(child);
    }
  } else {
    // A large closure can hold more nodes than a spread argument list allows.
    for (const node of solver.derived) { roots.push(node); claims.push(node.goal); }
  }
  const answers = claims.map((claim) => text(claim));
  const proof = options.proof ? renderProof(program, claims, roots) : null;
  let proofReport = null;
  if (proof && claims.length) {
    proofReport = checkProof(program, proof, { goals });
    if (!proofReport.valid) throw new Error(`cannot certify this result: ${proofReport.failures[0].detail}`);
  }
  return {
    answers, bindings, inferred: solver.derived.map((node) => text(node.goal)),
    stdout: proof ?? answers.map((answer) => `${answer}.\n`).join(''),
    // The generated proof is checked before it is returned, so hand back that
    // report rather than making a caller that wants it check the same document
    // a second time.
    proof, proofReport, stats: solver.stats, haltCode: solver.haltCode,
  };
}
