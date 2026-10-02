import {
  VAR, ATOM, COMPOUND, NUMBER, compound, atom, numberTerm, variable,
  deref, unify, termIsGround, properListItems, listFromItems, compareTerms, copyResolved,
} from './kernel/term.js';
import { evaluateArithmetic, arithmeticValueTerm, compareArithmeticValues } from './kernel/iso-arithmetic.js';
import { key } from './common.js';

// Only pure primitives belong here. Collections, call and negation are controls
// handled by the solver and explicitly distinguished in proof documents.
const comparisons = new Map([
  ['=:=/2', (n) => n === 0], ['=\\=/2', (n) => n !== 0],
  ['</2', (n) => n < 0], ['=</2', (n) => n <= 0],
  ['>/2', (n) => n > 0], ['>=/2', (n) => n >= 0],
]);
export const primitiveKeys = new Set([
  'true/0', 'fail/0', 'false/0', '=/2', '\\=/2', '==/2', '\\==/2',
  'is/2', ...comparisons.keys(), 'var/1', 'nonvar/1', 'ground/1',
  'atom/1', 'number/1', 'integer/1', 'float/1', 'compound/1',
  'functor/3', 'arg/3', '=../2', 'atom_chars/2', 'atom_codes/2',
  'atom_length/2', 'atom_concat/3', 'compare/3',
]);
export function* primitive(goal, env) {
  const id = key(goal);
  if (!primitiveKeys.has(id)) throw new Error(`unsupported primitive ${id}`);
  const args = goal.args;
  const resolved = args.map((arg) => deref(arg, env));
  const mark = env.mark();
  const bind = (a, b) => unify(a, b, env);
  let success = false;
  if (id === 'true/0') success = true;
  else if (id === 'fail/0' || id === 'false/0') success = false;
  else if (id === '=/2') success = bind(args[0], args[1]);
  else if (id === '\\=/2') { success = !unify(args[0], args[1], env); env.undo(mark); }
  else if (id === '==/2' || id === '\\==/2') {
    const equal = compareTerms(copyResolved(args[0], env), copyResolved(args[1], env)) === 0;
    success = id === '==/2' ? equal : !equal;
  } else if (id === 'is/2') success = bind(args[0], arithmeticValueTerm(evaluateArithmetic(args[1], env)));
  else if (comparisons.has(id)) success = comparisons.get(id)(compareArithmeticValues(
    evaluateArithmetic(args[0], env), evaluateArithmetic(args[1], env),
  ));
  else if (id === 'var/1') success = resolved[0].type === VAR;
  else if (id === 'nonvar/1') success = resolved[0].type !== VAR;
  else if (id === 'ground/1') success = termIsGround(args[0], env);
  else if (id === 'atom/1') success = resolved[0].type === ATOM;
  else if (id === 'number/1') success = resolved[0].type === NUMBER;
  else if (id === 'integer/1') success = resolved[0].type === NUMBER && /^-?\d+$/.test(resolved[0].name);
  else if (id === 'float/1') success = resolved[0].type === NUMBER && !/^-?\d+$/.test(resolved[0].name);
  else if (id === 'compound/1') success = resolved[0].type === COMPOUND;
  else if (id === 'functor/3') {
    if (resolved[0].type !== VAR) {
      success = bind(args[1], resolved[0].arity ? atom(resolved[0].name) : resolved[0]) && bind(args[2], numberTerm(resolved[0].arity));
    } else {
      const arity = boundedInteger(resolved[2], 0, 1024);
      if (arity > 0 && resolved[1].type !== ATOM) throw new Error('functor/3 needs an atom name');
      if (resolved[1].type === VAR) throw new Error('functor/3 needs a bound name');
      // Unique names across primitive invocations preserve variable isolation.
      const serial = ++functorSerial;
      success = bind(args[0], arity === 0 ? resolved[1] : compound(resolved[1].name, Array.from({ length: arity }, (_, i) => variable(`_functor${serial}_${i}`))));
    }
  } else if (id === 'arg/3') {
    const index = boundedInteger(resolved[0], 1, 1024);
    success = index <= resolved[1].arity && bind(args[2], resolved[1].args[index - 1]);
  } else if (id === '=../2') {
    if (resolved[0].type !== VAR) success = bind(args[1], listFromItems([resolved[0].arity ? atom(resolved[0].name) : resolved[0], ...resolved[0].args]));
    else {
      const items = properListItems(args[1], env)?.map((item) => deref(item, env));
      if (!items?.length || items[0].type === VAR || (items.length > 1 && items[0].type !== ATOM)) throw new Error('=../2 needs a nonempty bound term list');
      success = bind(args[0], items.length === 1 ? items[0] : compound(items[0].name, items.slice(1)));
    }
  } else if (id === 'atom_chars/2' || id === 'atom_codes/2') {
    const codes = id === 'atom_codes/2';
    if (resolved[0].type === ATOM) {
      success = bind(args[1], listFromItems(Array.from(resolved[0].name, (ch) => codes ? numberTerm(ch.codePointAt(0)) : atom(ch))));
    } else {
      const items = properListItems(args[1], env)?.map((item) => deref(item, env));
      if (!items) throw new Error(`${id} needs a proper list`);
      const chars = items.map((item) => {
        if (codes) return String.fromCodePoint(boundedInteger(item, 0, 0x10ffff));
        if (item.type !== ATOM || Array.from(item.name).length !== 1) throw new Error('atom_chars/2 needs characters');
        return item.name;
      });
      success = bind(args[0], atom(chars.join('')));
    }
  } else if (id === 'atom_length/2') {
    if (resolved[0].type !== ATOM) throw new Error('atom_length/2 needs a bound atom');
    success = bind(args[1], numberTerm(Array.from(resolved[0].name).length));
  } else if (id === 'atom_concat/3') {
    if (resolved[0].type === ATOM && resolved[1].type === ATOM) success = bind(args[2], atom(resolved[0].name + resolved[1].name));
    else if (resolved[2].type === ATOM) {
      const chars = Array.from(resolved[2].name);
      for (let i = 0; i <= chars.length; i++) {
        if (unify(args[0], atom(chars.slice(0, i).join('')), env) &&
            unify(args[1], atom(chars.slice(i).join('')), env)) yield env;
        env.undo(mark);
      }
      return;
    } else throw new Error('atom_concat/3 needs the result or both operands bound');
  } else if (id === 'compare/3') {
    const comparison = compareTerms(copyResolved(args[1], env), copyResolved(args[2], env));
    success = bind(args[0], atom(comparison < 0 ? '<' : comparison > 0 ? '>' : '='));
  }
  if (success) yield env;
  else env.undo(mark);
}
let functorSerial = 0;
function boundedInteger(term, min, max) {
  if (term.type !== NUMBER || !/^\d+$/.test(term.name)) throw new Error('expected a nonnegative integer');
  const n = Number(term.name);
  if (!Number.isSafeInteger(n) || n < min || n > max) throw new Error(`integer outside ${min}..${max}`);
  return n;
}
