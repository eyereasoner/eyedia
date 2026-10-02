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
      if (is(parsed.head, ':-', 1) || is(parsed.head, '-->', 2)) throw new Error('directives and DCGs are outside eyel');
      const forward = is(parsed.head, ':+', 2);
      if (forward && parsed.body.length) throw new Error('guarded :+ rule declarations are outside eyel');
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
      this.indexes.set(id, positionIndexes(clauses, (clause) => clause.head, clauses[0].head.arity));
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
      if (index === null) continue;
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

// An argument position earns an index only when enough entries carry an atom
// there for it to narrow the choice. Indexing a position where nearly every
// head has a variable costs a pass over the predicate and a list holding every
// entry in it, and rules out nothing. One counting pass covers all positions.
function positionIndexes(entries, headOf, arity) {
  const counts = new Array(arity).fill(0);
  for (const entry of entries) {
    const head = headOf(entry);
    for (let position = 0; position < arity; position++) {
      if (head.args[position].type === ATOM) counts[position]++;
    }
  }
  const positions = [];
  for (let position = 0; position < arity; position++) {
    positions.push(counts[position] * 2 < entries.length ? null : { atoms: new Map(), other: [] });
  }
  for (const entry of entries) {
    const head = headOf(entry);
    for (let position = 0; position < arity; position++) {
      const index = positions[position];
      if (index === null) continue;
      const argument = head.args[position];
      if (argument.type !== ATOM) { index.other.push(entry); continue; }
      if (!index.atoms.has(argument.name)) index.atoms.set(argument.name, []);
      index.atoms.get(argument.name).push(entry);
    }
  }
  return positions;
}

export function validateControls(goal) {
  if (excludedControls.has(key(goal))) throw new Error(`control outside eyel: ${key(goal)}`);
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
// A dependency can only resolve against a head with the same functor, and an
// atom in the goal can only meet the same atom or a variable in the head. Index
// both so a body goal is compared with the few heads that can match it rather
// than with every clause sharing its name. Without this, a program whose
// clauses all share one functor costs a full pairwise scan to stratify.
function headIndex(clauses) {
  const index = new Map();
  for (const clause of clauses) {
    for (const head of clause.heads) {
      const id = key(head);
      let entry = index.get(id);
      if (entry == null) { entry = { pairs: [], arity: head.arity, positions: null }; index.set(id, entry); }
      entry.pairs.push({ clause, head });
    }
  }
  for (const entry of index.values()) {
    entry.positions = positionIndexes(entry.pairs, (pair) => pair.head, entry.arity);
  }
  return index;
}
function headCandidates(entry, goal) {
  if (entry == null) return [];
  let chosen = entry.pairs;
  for (const [position, bucket] of entry.positions.entries()) {
    if (bucket === null || goal.args[position]?.type !== ATOM) continue;
    const matched = bucket.atoms.get(goal.args[position].name) ?? [];
    if (matched.length + bucket.other.length < chosen.length) chosen = [...matched, ...bucket.other];
  }
  return chosen;
}
// Whether a goal could contribute a closed dependency or a dynamic call. Erring
// towards true only costs the full analysis below, which is always correct.
function mayNeedStratifying(goal) {
  if (is(goal, ',', 2) || is(goal, ';', 2)) {
    return mayNeedStratifying(goal.args[0]) || mayNeedStratifying(goal.args[1]);
  }
  if (is(goal, '\\+', 1) || is(goal, 'findall', 3)) return true;
  if (is(goal, 'once', 1) || is(goal, 'call', 1)) return mayNeedStratifying(goal.args[0]);
  return goal.type === VAR;
}
function stratify(clauses) {
  const ranks = new Map(clauses.map((clause) => [clause.id, 0]));
  // Edges exist to raise a rank across a closed dependency and to find the
  // dynamic calls a forward rule can reach. A program with neither leaves every
  // rank at zero, so the whole analysis - and the head index it needs - is work
  // with no possible outcome. Decide that without collecting anything.
  if (!clauses.some((clause) => clause.body.some(mayNeedStratifying))) return ranks;
  const edges = [];
  const outgoing = new Map();
  const dynamic = new Set();
  const index = headIndex(clauses);
  const everyHead = clauses.flatMap((clause) => clause.heads.map((head) => ({ clause, head })));
  for (const clause of clauses) {
    for (const goal of clause.body) for (const dep of dependencies(goal)) {
      const named = dep.goal.type !== VAR;
      if (!named) dynamic.add(clause.id);
      for (const candidate of named ? headCandidates(index.get(key(dep.goal)), dep.goal) : everyHead) {
        if (unify(freshTerm(dep.goal, 'dependency'), freshTerm(candidate.head, 'head'), new Env())) {
          const edge = { head: clause.id, id: candidate.clause.id, closed: dep.closed };
          edges.push(edge);
          if (!outgoing.has(clause.id)) outgoing.set(clause.id, []);
          outgoing.get(clause.id).push(edge);
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
    for (const edge of outgoing.get(id) ?? []) pending.push(edge.id);
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
