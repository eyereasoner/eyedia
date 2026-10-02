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
const primitiveNode = (goal, by = atom('builtin'), children = []) => ({ goal, by, bindings: [], children });

const SPLICE = 'splice';
const advance = (frame, node) => ({ ...frame, index: frame.index + 1, nodes: [...frame.nodes, node] });
const childFrame = (parent, goals, pending, depth) => ({ goals, index: 0, nodes: [], parent, pending, depth });
const controlPending = (goal, cut) => ({ goal, by: atom('control'), bindings: [], cut });
// A finished body hands its nodes to the frame that started it: a conjunction
// splices them in place, anything else wraps them as one step's children.
function closeFrame(frame) {
  const parent = frame.parent;
  const nodes = frame.pending === SPLICE
    ? [...parent.nodes, ...frame.nodes]
    : [...parent.nodes, {
      goal: frame.pending.goal, by: frame.pending.by, bindings: frame.pending.bindings, children: frame.nodes,
    }];
  return { ...parent, index: parent.index + 1, nodes };
}

export class Solver {
  constructor(program, options = {}) {
    this.program = program;
    this.options = options;
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
    let frame = { goals, index: 0, nodes: [], parent: null, pending: null, depth };
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
          frame = closeFrame(frame);
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
    if (is(goal, ',', 2)) return childFrame(frame, flattenConjunction(goal), SPLICE, frame.depth);
    if (is(goal, '\\+', 1)) {
      // Negation is a test, not a way to bind its variables.
      if (!termIsGround(goal.args[0], env)) throw new Error('negation requires a ground goal');
      const mark = env.mark();
      const iterator = this.solve([goal.args[0]], env, frame.depth + 1);
      let absent;
      try { absent = iterator.next().done; } finally { iterator.return(); env.undo(mark); }
      return absent ? advance(frame, primitiveNode(goal, atom('absent'))) : null;
    }
    if (is(goal, 'findall', 3)) {
      const items = [];
      const mark = env.mark();
      for (const answer of this.solve([goal.args[1]], env, frame.depth + 1)) {
        items.push(freshTerm(copyResolved(goal.args[0], answer.env), `collection${++this.serial}`));
      }
      env.undo(mark);
      if (!unify(goal.args[2], listFromItems(items), env)) { env.undo(mark); return null; }
      return advance(frame, primitiveNode(goal, atom('collected')));
    }
    let point;
    if (is(goal, ';', 2)) {
      point = { kind: 'branch', frame, mark: env.mark(), goal, alternatives: goal.args, position: 0 };
    } else if (is(goal, 'call', 1) || is(goal, 'once', 1)) {
      const cut = goal.name === 'once' ? choices.length : null;
      return childFrame(frame, [goal.args[0]], controlPending(goal, cut), frame.depth + 1);
    } else if (primitiveKeys.has(key(goal))) {
      point = { kind: 'primitive', frame, mark: env.mark(), goal, iterator: primitive(goal, env) };
    } else {
      const alternatives = [];
      for (const fact of this.facts.get(key(goal)) ?? []) alternatives.push({ fact });
      for (const clause of this.program.candidates(goal, env)) alternatives.push({ clause });
      point = { kind: 'resolve', frame, mark: env.mark(), goal, alternatives, position: 0 };
    }
    const step = this.retry(point, env);
    if (step === null) return null;
    if (point.kind === 'primitive' || point.position < point.alternatives.length) choices.push(point);
    return step;
  }
  // Take the next untried alternative of a choice point, or null when it has
  // none left. The caller has already undone the bindings of the previous one.
  retry(point, env) {
    if (point.kind === 'primitive') {
      const next = point.iterator.next();
      return next.done ? null : advance(point.frame, primitiveNode(point.goal));
    }
    while (point.position < point.alternatives.length) {
      const alternative = point.alternatives[point.position++];
      if (point.kind === 'branch') {
        return childFrame(point.frame, [alternative], controlPending(point.goal, null), point.frame.depth + 1);
      }
      if (alternative.fact !== undefined) {
        if (unify(point.goal, alternative.fact.goal, env)) return advance(point.frame, alternative.fact);
        env.undo(point.mark);
        continue;
      }
      const clause = alternative.clause;
      const names = new Map();
      const head = freshTerm(clause.head, ++this.serial, names);
      const body = clause.body.map((item) => freshTerm(item, this.serial, names));
      if (!unify(point.goal, head, env)) { env.undo(point.mark); continue; }
      const pending = {
        goal: point.goal,
        by: compound(body.length ? 'rule' : 'fact', [numberTerm(clause.id)]),
        bindings: [...names],
        cut: null,
      };
      return childFrame(point.frame, body, pending, point.frame.depth + 1);
    }
    return null;
  }
  forward() {
    // Each rule's heads share a stratum. A rule with multiple heads runs only
    // after every prerequisite has reached its fixpoint.
    const layers = new Map();
    for (const clause of this.program.forward) {
      const rank = this.program.strata.get(clause.id);
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
              children: answer.nodes.map((node) => resolveNode(node, answer.env)),
              bindings: [...names].map(([name, value]) => [name, copyResolved(value, answer.env)]),
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
  solver.forward();
  const goals = options.goals ?? (options.goal == null ? program.queries : [options.goal]);
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
        for (const node of answer.nodes) roots.push(resolveNode(node, answer.env));
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
    proofReport = checkProof(program, proof);
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
