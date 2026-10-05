import {
  Env, compound, atom, numberTerm,
  deref, unify, freshTerm, copyResolved, termIsGround, listFromItems,
  flattenConjunction,
} from './kernel/term.js';
import { parseGoalText } from './kernel/parser.js';
import { primitive, primitiveKeys } from './builtins.js';
import { key, is, text, callable, addTo, freshClause, variables, conjunction, variant } from './common.js';
import { renderProof, checkProof } from './proof.js';
import { Program, validateControls } from './program.js';

export { Program } from './program.js';

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

// The source clauses a set of proof nodes rests on. A collection has no
// children in a proof, so its node keeps the clauses its answers used.
function clausesUsed(nodes, used = new Set()) {
  const pending = [...nodes];
  while (pending.length) {
    const node = pending.pop();
    if (node.by.arity) used.add(Number(node.by.args[0].name));
    if (node.collectedUses) for (const id of node.collectedUses) used.add(id);
    pending.push(...node.children);
  }
  return used;
}

// The source clauses that searches behind a trusted boundary could consult.
// A negation or a collection records no derivation in a proof, so follow its
// goal through the program instead: every clause whose head could answer a
// goal it reaches, and the goals in that clause's body, transitively.
function clausesBehindBoundaries(program, roots) {
  const byKey = new Map();
  for (const clause of program.clauses) {
    for (const head of clause.heads ?? [clause.head]) if (callable(head)) addTo(byKey, key(head), clause);
  }
  const pending = [];
  const visit = (goal) => {
    if (!callable(goal)) return;
    if (is(goal, ',', 2) || is(goal, ';', 2)) { visit(goal.args[0]); visit(goal.args[1]); }
    else if (is(goal, '\\+', 1) || is(goal, 'call', 1) || is(goal, 'once', 1)) visit(goal.args[0]);
    else if (is(goal, 'findall', 3)) visit(goal.args[1]);
    else if (!primitiveKeys.has(key(goal))) pending.push(key(goal));
  };
  const nodes = [...roots];
  while (nodes.length) {
    const node = nodes.pop();
    if (node.by === ABSENT || node.by === COLLECTED) visit(node.goal);
    nodes.push(...node.children);
  }
  const seen = new Set();
  const reached = new Set();
  while (pending.length) {
    const id = pending.pop();
    if (seen.has(id)) continue;
    seen.add(id);
    for (const clause of byKey.get(id) ?? []) { reached.add(clause.id); clause.body.forEach(visit); }
  }
  return reached;
}

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

class Solver {
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
      const uses = recording ? new Set() : null;
      const mark = env.mark();
      for (const answer of this.solve([goal.args[1]], env, frame.depth + 1)) {
        items.push(freshTerm(copyResolved(goal.args[0], answer.env), `collection${++this.serial}`));
        if (recording) clausesUsed(answer.nodes, uses);
      }
      env.undo(mark);
      if (!unify(goal.args[2], listFromItems(items), env)) { env.undo(mark); return null; }
      if (!recording) return advance(frame, null, recording);
      return advance(frame, { ...primitiveNode(goal, COLLECTED), collectedUses: uses }, recording);
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
      const { head, body, names } = freshClause(clause, ++this.serial);
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
    for (const clause of this.program.forward) addTo(layers, this.program.strata.get(clause.id) ?? 0, clause);
    for (const [, rules] of [...layers].sort(([a], [b]) => a - b)) {
      let changed = true;
      let rounds = 0;
      while (changed) {
        if (++rounds > (this.options.maxIterations ?? 1000)) throw new Error('forward reasoning exceeded maxIterations');
        this.stats.rounds++; changed = false;
        for (const clause of rules) {
          if (!reporting && clause.heads.every((item) => is(item, 'true', 0))) continue;
          const { head, body, names } = freshClause(clause, ++this.serial);
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
                const id = text(claim);
                if (!this.reported.has(id)) this.reported.set(id, { claim, children, clause: clause.id });
                continue;
              }
              const node = { goal: conclusion, by: compound('rule', [numberTerm(clause.id)]), bindings, children };
              if (is(conclusion, 'false', 0)) { this.derived.push(node); this.haltCode = 65; return; }
              const id = text(conclusion);
              if (this.factKeys.has(id)) continue;
              this.factKeys.add(id);
              addTo(this.facts, key(conclusion), node);
              this.derived.push(node); this.stats.derived++; changed = true;
            }
          }
        }
      }
    }
  }
}

// The clauses of a program that make no difference to its conclusions, one
// unused/2 fact each with the clause's source line: clauses no conclusion's
// proof rests on, unless leaving one out changes what the program concludes.
export function unusedClauseTerms(source, options = {}) {
  const program = Program.parse(source);
  const result = run(program, { ...options, proof: true });
  const used = new Set(result.clausesUsed);
  const behind = new Set(result.clausesBehindBoundaries);
  // A clause only a negation or a collection consults may still decide a
  // conclusion, which a proof does not record; so leave it out and compare.
  const conclusions = (outcome) => JSON.stringify([[...outcome.answers].sort(), outcome.haltCode]);
  const baseline = conclusions(result);
  const matters = (clause) => {
    try {
      return conclusions(run(new Program(source, { without: clause.id }), options)) !== baseline;
    } catch {
      return true;
    }
  };
  return program.clauses
    .filter((clause) => !used.has(clause.id) && !(behind.has(clause.id) && matters(clause)))
    .map((clause) => {
      const written = clause.forward ? compound(':+', [clause.head, conjunction(clause.body)])
        : clause.body.length ? compound(':-', [clause.head, conjunction(clause.body)]) : clause.head;
      return `${text(compound('unused', [compound('line', [numberTerm(clause.line)]), written]))}.\n`;
    }).join('');
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
  // A rule that reports a claim is used by it, though a proof records only
  // the claim's support.
  const used = options.proof ? clausesUsed(roots) : null;
  if (used && solver.haltCode == null && !goals.length) for (const report of solver.reported.values()) used.add(report.clause);
  let proofReport = null;
  if (proof && claims.length) {
    proofReport = checkProof(program, proof, { goals });
    if (!proofReport.valid) throw new Error(`cannot certify this result: ${proofReport.failures[0].detail}`);
  }
  return {
    answers, bindings, inferred: solver.derived.map((node) => text(node.goal)),
    // With a proof, the ids of the source clauses its conclusions rest on.
    clausesUsed: options.proof ? [...used].sort((a, b) => a - b) : null,
    // With a proof, the ids of clauses only searches behind a trusted
    // boundary could consult: the proof cannot show what they contribute.
    clausesBehindBoundaries: options.proof
      ? [...clausesBehindBoundaries(program, roots)].filter((id) => !used.has(id)).sort((a, b) => a - b) : null,
    stdout: proof ?? answers.map((answer) => `${answer}.\n`).join(''),
    // The generated proof is checked before it is returned, so hand back that
    // report rather than making a caller that wants it check the same document
    // a second time.
    proof, proofReport, stats: solver.stats, haltCode: solver.haltCode,
  };
}
