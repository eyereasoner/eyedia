import { Env, VAR, ATOM, COMPOUND, deref, flattenConjunction, unify, freshTerm, termIsGround } from './kernel/term.js';
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
    for (const parsed of parseProgramText(String(source))) {
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
    this.indexes = new Map();
    for (const [id, clauses] of this.groups) {
      const positions = [];
      for (let position = 0; position < clauses[0].head.arity; position++) {
        const atoms = new Map(), other = [];
        for (const clause of clauses) {
          const argument = clause.head.args[position];
          if (argument.type !== ATOM) { other.push(clause); continue; }
          if (!atoms.has(argument.name)) atoms.set(argument.name, []);
          atoms.get(argument.name).push(clause);
        }
        positions.push({ atoms, other });
      }
      this.indexes.set(id, positions);
    }
    // Ground source facts are compared against forward conclusions by text, so
    // render them once here rather than on every run of this program.
    this.groundFactKeys = new Set();
    for (const clause of this.clauses) {
      if (!clause.forward && !clause.body.length && termIsGround(clause.head)) this.groundFactKeys.add(text(clause.head));
    }
    this.strata = stratify(this.clauses);
  }
  candidates(goal, env = new Env()) {
    const id = key(goal);
    const clauses = this.groups.get(id) ?? [];
    let chosen = null, matches = null, count = clauses.length;
    for (const [position, index] of (this.indexes.get(id) ?? []).entries()) {
      const argument = deref(goal.args[position], env);
      if (argument.type !== ATOM) continue;
      const bucket = index.atoms.get(argument.name) ?? [];
      if (bucket.length + index.other.length < count) {
        chosen = index; matches = bucket; count = bucket.length + index.other.length;
      }
    }
    if (!chosen) return clauses;
    if (!chosen.other.length) return matches;
    // Retain source order, including clauses with variable or structured heads.
    return [...matches, ...chosen.other].sort((a, b) => a.id - b.id);
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
  // A dependency can only resolve against a head with the same functor, so
  // index the heads and compare complete terms within one bucket instead of
  // unifying every body goal against every clause in the program.
  const byHead = new Map();
  for (const clause of clauses) {
    for (const id of new Set(clause.heads.map(key))) {
      if (!byHead.has(id)) byHead.set(id, []);
      byHead.get(id).push(clause);
    }
  }
  for (const clause of clauses) {
    for (const goal of clause.body) for (const dep of dependencies(goal)) {
      const named = dep.goal.type !== VAR;
      if (!named) dynamic.add(clause.id);
      for (const candidate of named ? byHead.get(key(dep.goal)) ?? [] : clauses) {
        if (candidate.heads.some((head) => unify(freshTerm(dep.goal, 'dependency'), freshTerm(head, 'head'), new Env()))) {
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
