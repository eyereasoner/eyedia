// Finite-tree terms, substitutions, unification and ordering.
// Retain logical terms, unification, readback and order; omit attributed
// variables, constraint stores, compact VM terms and host lifecycle state.
import { compareIntegerValueText, sameNumberValue } from './number-value.js';
export const VAR = 'var', ATOM = 'atom', STRING = 'string', NUMBER = 'number', COMPOUND = 'compound';
const EMPTY_ARGS = Object.freeze([]);

export class Term {
  constructor(type, name, args = []) {
    this.type = type;
    this.name = String(name ?? '');
    this.args = args;
  }
  get arity() {
    return this.args.length;
  }
}


export const variable = (name) => new Term(VAR, name, EMPTY_ARGS);
export const atom = (name) => new Term(ATOM, name, EMPTY_ARGS);
export const stringTerm = (value) => new Term(STRING, value, EMPTY_ARGS);
export const numberTerm = (value) => new Term(NUMBER, value, EMPTY_ARGS);
export const compound = (name, args = []) => args.length === 0 ? atom(name) : new Term(COMPOUND, name, args);
// Terms are never changed after they are built, so the empty list can be one
// shared term rather than a new one at the end of every list.
const EMPTY_LIST = atom('[]');
export const emptyList = () => EMPTY_LIST;
export const cons = (head, tail) => compound('.', [head, tail]);


// One substitution per search, with an undo trail. Backtracking restores the
// bindings a failed branch made instead of copying the whole map for every
// alternative, so a derivation N steps deep costs O(N) rather than O(N^2).
// The trail records each name with the value it had, so rebinding a name -
// which path compression in deref below does - undoes correctly too.
export class Env {
  constructor() {
    this.bindings = new Map();
    this.trail = [];
  }
  mark() {
    return this.trail.length;
  }
  undo(mark) {
    while (this.trail.length > mark) {
      const previous = this.trail.pop();
      const name = this.trail.pop();
      if (previous === undefined) this.bindings.delete(name);
      else this.bindings.set(name, previous);
    }
  }
  lookup(name) {
    return this.bindings.get(name);
  }
  bind(name, value) {
    this.trail.push(name, this.bindings.get(name));
    this.bindings.set(name, value);
  }
}
export function deref(term, env) {
  if (term.type !== VAR) return term;
  let value = env.lookup(term.name);
  if (value === undefined) return term;
  if (value.type !== VAR) return value;
  // Resolving a chain of variable-to-variable bindings records where the whole
  // chain ended, not just its head. These are the same bindings, reached in one
  // step from now on; without this a derivation that threads one variable
  // through N resolution steps re-walks the chain on every dereference.
  const chain = [term.name];
  while (value.type === VAR) {
    const next = env.lookup(value.name);
    if (next === undefined) break;
    chain.push(value.name);
    value = next;
  }
  for (const name of chain) env.bind(name, value);
  return value;
}
export const isEmptyList = (term) => term?.type === ATOM && term.name === '[]';
export const isCons = (term) => term?.type === COMPOUND && term.name === '.' && term.arity === 2;
const isConjunction = (term) => term?.type === COMPOUND && term.name === ',' && term.arity === 2;
function occurs(name, term, env) {
  const pending = [term];
  while (pending.length) {
    const item = deref(pending.pop(), env);
    if (item.type === VAR && item.name === name) return true;
    pending.push(...item.args);
  }
  return false;
}
// Unification always applies the occurs check: eyedia terms are finite trees,
// so a binding that would create a cycle fails instead of building one.
export function unify(left, right, env) {
  const pending = [left, right];
  while (pending.length) {
    let b = deref(pending.pop(), env);
    let a = deref(pending.pop(), env);
    if (a === b || (a.type === VAR && b.type === VAR && a.name === b.name)) continue;
    if (b.type === VAR && a.type !== VAR) [a, b] = [b, a];
    if (a.type === VAR) {
      if (occurs(a.name, b, env)) return false;
      env.bind(a.name, b);
    } else {
      if (a.type !== b.type || a.arity !== b.arity) return false;
      if (a.type === NUMBER ? !sameNumberValue(a.name, b.name) : a.name !== b.name) return false;
      for (let i = a.arity - 1; i >= 0; i--) pending.push(a.args[i], b.args[i]);
    }
  }
  return true;
}

// Rename a clause's variables apart. Terms are never changed after they are
// built, so a subterm with no variable in it is shared rather than copied:
// renaming a clause then costs only the parts that actually hold variables.
export function freshTerm(term, suffix, variables = new Map()) {
  if (term.type === VAR) {
    let fresh = variables.get(term.name);
    if (fresh == null) {
      fresh = variable(`${term.name}#${suffix}`);
      variables.set(term.name, fresh);
    }
    return fresh;
  }
  const count = term.args.length;
  if (count === 0) return term;
  let args = null;
  for (let index = 0; index < count; index++) {
    const arg = term.args[index];
    const copy = freshTerm(arg, suffix, variables);
    if (args === null) {
      if (copy === arg) continue;
      args = term.args.slice(0, index);
    }
    args.push(copy);
  }
  return args === null ? term : new Term(term.type, term.name, args);
}

export function copyResolved(term, env) {
  const makeCopy = (resolved) => {
    if (resolved.type === VAR) return variable(resolved.name);
    return resolved.type === COMPOUND && resolved.arity === 0
      ? atom(resolved.name)
      : new Term(resolved.type, resolved.name, new Array(resolved.args.length));
  };

  const resolved = deref(term, env);
  const copied = makeCopy(resolved);
  if (resolved.type === VAR || resolved.args.length === 0) return copied;

  // Deeply nested terms can contain thousands of cells. Copy them iteratively
  // so readback never consumes the JavaScript call stack, and keep a
  // source-to-copy map so shared subterms stay shared in the copy.
  const copies = new Map([[resolved, copied]]);
  const pending = [{ source: resolved, target: copied }];
  while (pending.length > 0) {
    const { source, target } = pending.pop();
    for (let index = 0; index < source.args.length; index++) {
      const childSource = deref(source.args[index], env);
      let childCopy = copies.get(childSource);
      if (childCopy == null) {
        childCopy = makeCopy(childSource);
        if (childSource.type !== VAR && childSource.args.length > 0) {
          copies.set(childSource, childCopy);
          pending.push({ source: childSource, target: childCopy });
        }
      }
      target.args[index] = childCopy;
    }
  }
  return copied;
}

export function termIsGround(term, env = new Env()) {
  // Defer the cycle-guard Set until we encounter a compound term, since
  // the overwhelming majority of ground checks are on acyclic clause data.
  const pending = [term];
  let seen = null;
  while (pending.length > 0) {
    const resolved = deref(pending.pop(), env);
    if (resolved.type === VAR) return false;
    const arity = resolved.args.length;
    if (arity === 0) continue;
    if (seen == null) seen = new Set();
    if (seen.has(resolved)) continue;
    seen.add(resolved);
    // Visit leftmost arguments first. Lists and other recursive structures
    // commonly carry their first unbound variable there, allowing a
    // non-ground check to finish without walking the complete tail.
    for (let index = arity - 1; index >= 0; index--) {
      pending.push(resolved.args[index]);
    }
  }
  return true;
}


export function properListItems(list, env) {
  const items = [];
  let cursor = deref(list, env);
  while (isCons(cursor)) {
    items.push(cursor.args[0]);
    cursor = deref(cursor.args[1], env);
  }
  if (!isEmptyList(cursor)) return null;
  return items;
}

export function listFromItems(items, start = 0, end = items.length, tail = emptyList()) {
  let result = tail;
  for (let i = end - 1; i >= start; i--) result = cons(items[i], result);
  return result;
}

export function flattenConjunction(goal) {
  const out = [];
  const stack = [goal];
  while (stack.length) {
    const current = stack.pop();
    if (isConjunction(current)) {
      stack.push(current.args[1], current.args[0]);
    } else {
      out.push(current);
    }
  }
  return out;
}


function compareCharacterText(left, right) {
  let li = 0;
  let ri = 0;
  while (li < left.length && ri < right.length) {
    const ac = left.codePointAt(li);
    const bc = right.codePointAt(ri);
    if (ac !== bc) return ac < bc ? -1 : 1;
    li += ac > 0xffff ? 2 : 1;
    ri += bc > 0xffff ? 2 : 1;
  }
  return li < left.length ? 1 : ri < right.length ? -1 : 0;
}

// ISO 7.2.1 deliberately leaves the order of distinct variables implementation
// dependent. Rank them by first encounter within this one comparison rather
// than attaching a permanent ordinal to a logical variable, which would make
// the chosen order observable outside the operation that needs it.
export function compareTerms(left, right) {
  return compareTermsWithRanks(left, right, new Map());
}

function variableRank(name, ranks) {
  let rank = ranks.get(name);
  if (rank == null) {
    rank = ranks.size;
    ranks.set(name, rank);
  }
  return rank;
}

// ISO standard order: variables < numbers < atoms < strings < compound.
// Defined once to avoid allocating a fresh object literal on every comparison.
const TYPE_ORDER = { [VAR]: 0, [NUMBER]: 1, [ATOM]: 2, [STRING]: 3, [COMPOUND]: 4 };
const EMPTY_ENV = new Env();

function compareTermsWithRanks(left, right, variableRanks) {
  // Walk argument pairs explicitly so long lists do not exhaust the host stack.
  const pending = [left, right];
  while (pending.length !== 0) {
    right = deref(pending.pop(), EMPTY_ENV);
    left = deref(pending.pop(), EMPTY_ENV);
    const lr = TYPE_ORDER[left.type] ?? 0;
    const rr = TYPE_ORDER[right.type] ?? 0;
    if (lr !== rr) return lr < rr ? -1 : 1;
    if (left.type === NUMBER) {
      // Numbers are ordered by value; a float precedes an integer of equal value.
      const cmp = compareNumberText(left.name, right.name);
      if (cmp) return cmp;
      const leftInteger = isDecimalInteger(left.name);
      if (leftInteger !== isDecimalInteger(right.name)) return leftInteger ? 1 : -1;
    } else if (left.type === VAR) {
      if (left.name === right.name) continue;
      const leftOrder = variableRank(left.name, variableRanks);
      const rightOrder = variableRank(right.name, variableRanks);
      return leftOrder < rightOrder ? -1 : 1;
    } else if (left.type === ATOM || left.type === STRING) {
      const cmp = compareCharacterText(left.name, right.name);
      if (cmp) return cmp;
    } else {
      if (left.arity !== right.arity) return left.arity < right.arity ? -1 : 1;
      if (left.name !== right.name) return compareCharacterText(left.name, right.name);
      for (let i = left.arity - 1; i >= 0; i--) pending.push(left.args[i], right.args[i]);
    }
  }
  return 0;
}


const RE_FLOAT = /^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$/;

const RE_DECIMAL_INTEGER = /^-?\d+$/;
export function isDecimalInteger(text) {
  return RE_DECIMAL_INTEGER.test(text ?? '');
}

function parseFiniteNumber(text) {
  if (text == null || text === '') return null;
  if (!RE_FLOAT.test(text)) return null;
  const n = Number(text);
  return Number.isFinite(n) ? n : null;
}

export function numberTextFromDouble(value) {
  if (!Number.isFinite(value)) return null;
  if (Object.is(value, -0)) value = 0;
  // Number#toString returns the shortest decimal spelling that round-trips to
  // the same IEEE-754 double. Keep that value identity while adapting the text
  // to ISO float syntax, which requires an explicit fractional part.
  let text = Number(value).toString();
  const exponent = text.search(/[eE]/);
  if (exponent >= 0) {
    if (!text.slice(0, exponent).includes('.')) {
      text = `${text.slice(0, exponent)}.0${text.slice(exponent)}`;
    }
  } else if (!text.includes('.')) {
    text += '.0';
  }
  return text;
}

// Compare an unbounded integer spelling against a float without rounding the
// integer through a double: every integral double converts back exactly, and a
// fractional double necessarily has magnitude below 2^53.
function compareIntegerTextToFloat(integerText, value) {
  const integer = BigInt(integerText);
  const truncated = BigInt(Math.trunc(value));
  if (integer < truncated) return -1;
  if (integer > truncated) return 1;
  return Number.isInteger(value) ? 0 : value > 0 ? -1 : 1;
}

function compareNumberText(left, right) {
  const leftInteger = isDecimalInteger(left);
  const rightInteger = isDecimalInteger(right);
  if (leftInteger && rightInteger) return compareIntegerValueText(left, right);
  const a = parseFiniteNumber(left);
  const b = parseFiniteNumber(right);
  if (a == null || b == null) return left < right ? -1 : left > right ? 1 : 0;
  if (leftInteger) return compareIntegerTextToFloat(left, b);
  if (rightInteger) return -compareIntegerTextToFloat(right, a);
  return a < b ? -1 : a > b ? 1 : 0;
}


// Error messages use a small canonical renderer; public output uses write.js.
export function termToString(term, env = new Env()) {
  const item = deref(term, env);
  if (item.type === VAR || item.type === NUMBER) return item.name;
  const name = /^[a-z][A-Za-z0-9_]*$/.test(item.name) ? item.name : "'" + item.name.replaceAll("'", "''") + "'";
  return item.arity ? name + '(' + item.args.map((arg) => termToString(arg, env)).join(', ') + ')' : name;
}
