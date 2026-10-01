import {
  Env, VAR, ATOM, COMPOUND, compound, atom, numberTerm, variable,
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

function resolveNode(node, env) {
  return {
    ...node, goal: copyResolved(node.goal, env),
    bindings: node.bindings.map(([name, value]) => [name, copyResolved(value, env)]),
    children: node.children.map((child) => resolveNode(child, env)),
  };
}
const primitiveNode = (goal, by = atom('builtin'), children = []) => ({ goal, by, bindings: [], children });

export class Solver {
  constructor(program, options = {}) {
    this.program = program;
    this.options = options;
    this.serial = 0;
    this.facts = new Map();
    this.factKeys = new Set();
    this.derived = [];
    this.reported = new Map();
    this.stats = { inferences: 0, rounds: 0, derived: 0 };
    this.haltCode = null;
    for (const clause of program.clauses) {
      if (!clause.forward && !clause.body.length && termIsGround(clause.head)) this.factKeys.add(text(clause.head));
    }
  }
  budget(depth) {
    if (depth > (this.options.maxDepth ?? 256)) throw new Error('backward reasoning exceeded maxDepth');
    if (++this.stats.inferences > (this.options.maxInferences ?? 1000000)) throw new Error('reasoning exceeded maxInferences');
  }
  *solve(goals, env = new Env(), depth = 0) {
    if (!goals.length) { yield { env, nodes: [] }; return; }
    this.budget(depth);
    for (const first of this.goal(goals[0], env, depth)) {
      for (const rest of this.solve(goals.slice(1), first.env, depth)) {
        yield { env: rest.env, nodes: [...first.nodes, ...rest.nodes].map((node) => resolveNode(node, rest.env)) };
      }
    }
  }
  *goal(request, env, depth) {
    const goal = deref(request, env);
    if (!callable(goal)) throw new Error(`expected a callable goal, got ${text(goal)}`);
    validateControls(goal);
    if (is(goal, ',', 2)) { yield* this.solve(flattenConjunction(goal), env, depth); return; }
    if (is(goal, ';', 2)) {
      for (const branch of goal.args) for (const answer of this.solve([branch], env, depth + 1)) {
        yield { env: answer.env, nodes: [primitiveNode(copyResolved(goal, answer.env), atom('control'), answer.nodes)] };
      }
      return;
    }
    if (is(goal, 'call', 1) || is(goal, 'once', 1)) {
      for (const answer of this.solve([goal.args[0]], env, depth + 1)) {
        yield { env: answer.env, nodes: [primitiveNode(copyResolved(goal, answer.env), atom('control'), answer.nodes)] };
        if (goal.name === 'once') break;
      }
      return;
    }
    if (is(goal, '\\+', 1)) {
      // Negation is a test, not a way to bind its variables.
      if (!termIsGround(goal.args[0], env)) throw new Error('negation requires a ground goal');
      const iterator = this.solve([goal.args[0]], env.clone(), depth + 1);
      let absent;
      try { absent = iterator.next().done; } finally { iterator.return(); }
      if (absent) yield { env, nodes: [primitiveNode(copyResolved(goal, env), atom('absent'))] };
      return;
    }
    if (is(goal, 'findall', 3)) {
      const items = [];
      for (const answer of this.solve([goal.args[1]], env.clone(), depth + 1)) {
        items.push(freshTerm(copyResolved(goal.args[0], answer.env), `collection${++this.serial}`));
      }
      const next = env.clone();
      if (unify(goal.args[2], listFromItems(items), next, { occursCheck: true })) {
        yield { env: next, nodes: [primitiveNode(copyResolved(goal, next), atom('collected'))] };
      }
      return;
    }
    if (primitiveKeys.has(key(goal))) {
      for (const next of primitive(goal, env)) yield { env: next, nodes: [primitiveNode(copyResolved(goal, next))] };
      return;
    }
    for (const fact of this.facts.get(key(goal)) ?? []) {
      const next = env.clone();
      if (unify(goal, fact.goal, next, { occursCheck: true })) yield { env: next, nodes: [fact] };
    }
    for (const clause of this.program.candidates(goal, env)) {
      const names = new Map();
      const head = freshTerm(clause.head, ++this.serial, names);
      const body = clause.body.map((item) => freshTerm(item, this.serial, names));
      const next = env.clone();
      if (!unify(goal, head, next, { occursCheck: true })) continue;
      for (const answer of this.solve(body, next, depth + 1)) {
        const node = {
          goal: copyResolved(goal, answer.env),
          by: compound(body.length ? 'rule' : 'fact', [numberTerm(clause.id)]),
          bindings: [...names].map(([name, value]) => [name, copyResolved(value, answer.env)]),
          children: answer.nodes,
        };
        yield { env: answer.env, nodes: [node] };
      }
    }
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
          // Snapshot answers before adding facts to avoid extending a live scan.
          const answers = [...this.solve(body)];
          for (const answer of answers) {
            const next = answer.env.clone();
            // Residual head variables become
            // sk_0, sk_1, ... within each conclusion, with sharing preserved.
            const unresolved = variables(copyResolved(head, next));
            let skolem = 0;
            for (const value of unresolved.values()) unify(value, atom(`sk_${skolem++}`), next);
            const children = answer.nodes.map((node) => resolveNode(node, next));
            const bindings = [...names].map(([name, value]) => [name, copyResolved(value, next)]);
            for (const item of flattenConjunction(head)) {
              const conclusion = copyResolved(item, next);
              if (is(conclusion, 'true', 0)) {
                const claim = copyResolved(conjunction(body), next);
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
        roots.push(...answer.nodes);
        claims.push(conclusion);
        bindings.push(Object.fromEntries([...variables(goal)].filter(([name]) => !name.startsWith('_')).map(([name, value]) => [name, text(value, answer.env)])));
      }
    }
  } else if (solver.haltCode == null && solver.reported.size) {
    for (const report of solver.reported.values()) { claims.push(report.claim); roots.push(...report.children); }
  } else { roots.push(...solver.derived); claims.push(...solver.derived.map((node) => node.goal)); }
  const answers = claims.map((claim) => text(claim));
  const proof = options.proof ? renderProof(program, claims, roots) : null;
  if (proof && claims.length) {
    const report = checkProof(program, proof);
    if (!report.valid) throw new Error(`cannot certify this result: ${report.failures[0].detail}`);
  }
  return {
    answers, bindings, inferred: solver.derived.map((node) => text(node.goal)),
    stdout: proof ?? answers.map((answer) => `${answer}.\n`).join(''),
    proof, stats: solver.stats, haltCode: solver.haltCode,
  };
}
