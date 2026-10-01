import { Env, VAR, ATOM, COMPOUND, flattenConjunction, unify, freshTerm } from './kernel/term.js';
import { parseProgramText } from './kernel/parser.js';
import { primitiveKeys } from './builtins.js';
import { key, is, text } from './common.js';

const controls = new Set([',/2', ';/2', '\\+/1', 'call/1', 'once/1', 'findall/3']);
const reserved = new Set(['step/4', 'clause/3']);
const excludedControls = new Set(['!/0', '->/2', '*->/2', ':/2', ':-/1', '-->/2']);
const callable = (term) => term?.type === ATOM || term?.type === COMPOUND;
export class Program {
  constructor(source) {
    this.clauses = [];
    this.queries = [];
    this.groups = new Map();
    this.forward = [];
    for (const parsed of parseProgramText(String(source), { sourceMetadata: true })) {
      if (parsed.kind === 'query') { this.queries.push(parsed.goal); continue; }
      if (!parsed.head || parsed.kind) throw new Error('only facts, :- rules, :+ rules and ?- queries are supported');
      if (is(parsed.head, ':-', 1) || is(parsed.head, '-->', 2)) throw new Error('directives and DCGs are outside eyelang');
      const forward = is(parsed.head, ':+', 2);
      if (forward && parsed.body.length) throw new Error('guarded :+ rule declarations are outside eyelang');
      const head = forward ? parsed.head.args[0] : parsed.head;
      const body = (forward ? [parsed.head.args[1]] : parsed.body).flatMap(flattenConjunction);
      const heads = forward ? flattenConjunction(head) : [head];
      for (const goal of body) validateControls(goal);
      for (const item of heads) {
        if (!callable(item) || is(item, ':', 2) || reserved.has(key(item)) ||
            ((primitiveKeys.has(key(item)) || controls.has(key(item))) && !(forward && ['true', 'false'].includes(item.name)))) {
          throw new Error(`unsupported or reserved head ${text(item)}`);
        }
      }
      const clause = { id: this.clauses.length + 1, head, heads, body, forward, source: parsed.source };
      this.clauses.push(clause);
      if (forward) this.forward.push(clause);
      else {
        const id = key(head);
        if (!this.groups.has(id)) this.groups.set(id, []);
        this.groups.get(id).push(clause);
      }
    }
    this.strata = stratify(this.clauses);
  }
  static parse(source) { return new Program(source); }
}

export function validateControls(goal) {
  if (excludedControls.has(key(goal))) throw new Error(`control outside eyelang: ${key(goal)}`);
  if (is(goal, ',', 2) || is(goal, ';', 2)) goal.args.forEach(validateControls);
  else if (is(goal, 'call', 1) || is(goal, 'once', 1) || is(goal, '\\+', 1)) validateControls(goal.args[0]);
  else if (is(goal, 'findall', 3)) validateControls(goal.args[1]);
}

// Closed dependencies arise from absence and collection. Reject negative
// cycles instead of deriving conclusions before a lower stratum is complete.
function dependencies(goal, closed = false, out = []) {
  if (is(goal, ',', 2) || is(goal, ';', 2)) {
    dependencies(goal.args[0], closed, out); dependencies(goal.args[1], closed, out);
  } else if (is(goal, '\\+', 1)) dependencies(goal.args[0], true, out);
  else if (is(goal, 'findall', 3)) dependencies(goal.args[1], true, out);
  else if (is(goal, 'once', 1) || is(goal, 'call', 1)) dependencies(goal.args[0], closed, out);
  else if (goal.type === VAR || !primitiveKeys.has(key(goal))) out.push({ goal, closed });
  return out;
}
function stratify(clauses) {
  const ranks = new Map(clauses.map((clause) => [clause.id, 0]));
  const edges = [];
  const dynamic = new Set();
  for (const clause of clauses) {
    for (const goal of clause.body) for (const dep of dependencies(goal)) {
      if (dep.goal.type === VAR) dynamic.add(clause.id);
      for (const candidate of clauses) {
        if (candidate.heads.some((head) => unify(freshTerm(dep.goal, 'dependency'), freshTerm(head, 'head'), new Env(), { occursCheck: true }))) {
          edges.push({ head: clause.id, id: candidate.id, closed: dep.closed });
        }
      }
    }
  }
  const reachable = new Set();
  const pending = clauses.filter((clause) => clause.forward).map((clause) => clause.id);
  while (pending.length) {
    const id = pending.pop();
    if (reachable.has(id)) continue;
    reachable.add(id);
    if (dynamic.has(id)) throw new Error('forward dependencies require statically named calls');
    for (const edge of edges) if (edge.head === id) pending.push(edge.id);
  }
  for (let pass = 0; pass <= ranks.size; pass++) {
    let changed = false;
    for (const edge of edges) {
      const rank = (ranks.get(edge.id) ?? 0) + Number(edge.closed);
      if (rank > ranks.get(edge.head)) { ranks.set(edge.head, rank); changed = true; }
    }
    if (!changed) return ranks;
  }
  throw new Error('unstratified negation or collection dependency');
}

