import {
  VAR, ATOM, COMPOUND, NUMBER, compound, atom, numberTerm, variable,
  deref, unify, termIsGround, properListItems, listFromItems, compareTerms, copyResolved,
} from './kernel/term.js';
import { evaluateArithmetic, arithmeticValueTerm, compareArithmeticValues } from './kernel/iso-arithmetic.js';
import { key } from './common.js';

// Only pure primitives belong here. Collections, call and negation are controls
// handled by the solver and explicitly distinguished in proof documents.
//
// A test decides a goal at most once: it is handed the goal's arguments, the
// same arguments dereferenced, the substitution and a bind function, and says
// whether the goal holds. Any bindings it made on the way to failing are undone
// for it.
const comparison = (holds) => (args, _, env) => holds(compareArithmeticValues(
  evaluateArithmetic(args[0], env), evaluateArithmetic(args[1], env),
));
const sameTerm = (args, env) => compareTerms(copyResolved(args[0], env), copyResolved(args[1], env)) === 0;
const isInteger = (term) => term.type === NUMBER && /^-?\d+$/.test(term.name);
const tests = new Map([
  ['true/0', () => true],
  ['fail/0', () => false],
  ['false/0', () => false],
  ['=/2', (args, _, env, bind) => bind(args[0], args[1])],
  ['\\=/2', (args, _, env) => {
    const mark = env.mark();
    const unifies = unify(args[0], args[1], env);
    env.undo(mark);
    return !unifies;
  }],
  ['==/2', (args, _, env) => sameTerm(args, env)],
  ['\\==/2', (args, _, env) => !sameTerm(args, env)],
  ['is/2', (args, _, env, bind) => bind(args[0], arithmeticValueTerm(evaluateArithmetic(args[1], env)))],
  ['=:=/2', comparison((n) => n === 0)],
  ['=\\=/2', comparison((n) => n !== 0)],
  ['</2', comparison((n) => n < 0)],
  ['=</2', comparison((n) => n <= 0)],
  ['>/2', comparison((n) => n > 0)],
  ['>=/2', comparison((n) => n >= 0)],
  ['var/1', (_, [term]) => term.type === VAR],
  ['nonvar/1', (_, [term]) => term.type !== VAR],
  ['ground/1', (args, _, env) => termIsGround(args[0], env)],
  ['atom/1', (_, [term]) => term.type === ATOM],
  ['number/1', (_, [term]) => term.type === NUMBER],
  ['integer/1', (_, [term]) => isInteger(term)],
  ['float/1', (_, [term]) => term.type === NUMBER && !isInteger(term)],
  ['compound/1', (_, [term]) => term.type === COMPOUND],
  ['functor/3', (args, [term, name, arity], env, bind) => {
    if (term.type !== VAR) {
      return bind(args[1], term.arity ? atom(term.name) : term) && bind(args[2], numberTerm(term.arity));
    }
    const count = boundedInteger(arity, 0, 1024);
    if (count > 0 && name.type !== ATOM) throw new Error('functor/3 needs an atom name');
    if (name.type === VAR) throw new Error('functor/3 needs a bound name');
    // Unique names across primitive invocations preserve variable isolation.
    const serial = ++functorSerial;
    return bind(args[0], count === 0 ? name
      : compound(name.name, Array.from({ length: count }, (_, i) => variable(`_functor${serial}_${i}`))));
  }],
  ['arg/3', (args, [position, term], env, bind) => {
    const index = boundedInteger(position, 1, 1024);
    return index <= term.arity && bind(args[2], term.args[index - 1]);
  }],
  ['=../2', (args, [term], env, bind) => {
    if (term.type !== VAR) return bind(args[1], listFromItems([term.arity ? atom(term.name) : term, ...term.args]));
    const items = properListItems(args[1], env)?.map((item) => deref(item, env));
    if (!items?.length || items[0].type === VAR || (items.length > 1 && items[0].type !== ATOM)) {
      throw new Error('=../2 needs a nonempty bound term list');
    }
    return bind(args[0], items.length === 1 ? items[0] : compound(items[0].name, items.slice(1)));
  }],
  ['atom_chars/2', atomText('atom_chars/2', false)],
  ['atom_codes/2', atomText('atom_codes/2', true)],
  ['atom_length/2', (args, [term], env, bind) => {
    if (term.type !== ATOM) throw new Error('atom_length/2 needs a bound atom');
    return bind(args[1], numberTerm(Array.from(term.name).length));
  }],
  ['compare/3', (args, _, env, bind) => {
    const order = compareTerms(copyResolved(args[1], env), copyResolved(args[2], env));
    return bind(args[0], atom(order < 0 ? '<' : order > 0 ? '>' : '='));
  }],
]);
// A relation can hold several times. It is a generator over the same arguments
// as a test plus the mark to undo to, and yields once per solution; the solver
// undoes the bindings of one solution before asking for the next.
const relations = new Map([
  ['atom_concat/3', function* atomConcat(args, [left, right, whole], env, mark) {
    if (left.type === ATOM && right.type === ATOM) {
      if (unify(args[2], atom(left.name + right.name), env)) yield env;
      else env.undo(mark);
      return;
    }
    if (whole.type !== ATOM) throw new Error('atom_concat/3 needs the result or both operands bound');
    const chars = Array.from(whole.name);
    for (let i = 0; i <= chars.length; i++) {
      if (unify(args[0], atom(chars.slice(0, i).join('')), env) &&
          unify(args[1], atom(chars.slice(i).join('')), env)) yield env;
      env.undo(mark);
    }
  }],
]);
export const primitiveKeys = new Set([...tests.keys(), ...relations.keys()]);

export function* primitive(goal, env) {
  const id = key(goal);
  const args = goal.args;
  const resolved = args.map((arg) => deref(arg, env));
  const mark = env.mark();
  const test = tests.get(id);
  if (test === undefined) {
    const relation = relations.get(id);
    if (relation === undefined) throw new Error(`unsupported primitive ${id}`);
    yield* relation(args, resolved, env, mark);
    return;
  }
  if (test(args, resolved, env, (a, b) => unify(a, b, env))) yield env;
  else env.undo(mark);
}

// atom_chars/2 and atom_codes/2 differ only in how one character is a term.
function atomText(id, codes) {
  return (args, [term], env, bind) => {
    if (term.type === ATOM) {
      return bind(args[1], listFromItems(Array.from(term.name, (ch) => codes ? numberTerm(ch.codePointAt(0)) : atom(ch))));
    }
    const items = properListItems(args[1], env)?.map((item) => deref(item, env));
    if (!items) throw new Error(`${id} needs a proper list`);
    const chars = items.map((item) => {
      if (codes) return String.fromCodePoint(boundedInteger(item, 0, 0x10ffff));
      if (item.type !== ATOM || Array.from(item.name).length !== 1) throw new Error('atom_chars/2 needs characters');
      return item.name;
    });
    return bind(args[0], atom(chars.join('')));
  };
}
let functorSerial = 0;
function boundedInteger(term, min, max) {
  if (term.type !== NUMBER || !/^\d+$/.test(term.name)) throw new Error('expected a nonnegative integer');
  const n = Number(term.name);
  if (!Number.isSafeInteger(n) || n < min || n > max) throw new Error(`integer outside ${min}..${max}`);
  return n;
}
