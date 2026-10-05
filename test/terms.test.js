import test from 'node:test';
import assert from 'node:assert/strict';
import { atom, compound, numberTerm, variable, run } from '../index.js';
import { text } from '../src/common.js';
import { Env, unify, copyResolved, compareTerms } from '../src/kernel/term.js';

test('fresh variable rendering cannot collide with source variable names', () => {
  assert.notEqual(text(variable('X#1')), text(variable('X_1')));
  assert.notEqual(text(variable('X#1')), text(variable('EYE_58_23_31')));
  assert.match(text(compound('p', [variable('X#1'), variable('X_1')])), /p\(EYE_58_23_31, X_1\)/);
});
test('the trail restores bindings and occurs checks use existing aliases', () => {
  const env = new Env();
  const x = variable('X'), y = variable('Y');
  assert.equal(unify(x, y, env), true);
  const mark = env.mark();
  assert.equal(unify(y, atom('a'), env), true);
  // Dereferencing X follows the alias and shortens it, which rebinds X.
  assert.equal(copyResolved(x, env).name, 'a');
  env.undo(mark);
  // Undoing restores the alias rather than dropping the rebound name.
  assert.equal(copyResolved(x, env).type, 'var');
  assert.equal(unify(y, compound('f', [x]), env), false);
  env.undo(mark);
  assert.equal(unify(y, atom('b'), env), true);
  assert.equal(copyResolved(x, env).name, 'b');
});
test('numeric identity and order retain exact large integers', () => {
  assert.equal(unify(numberTerm('01'), numberTerm('1'), new Env()), true);
  assert.equal(unify(numberTerm('1.0'), numberTerm('1'), new Env()), false);
  assert.equal(compareTerms(numberTerm('9007199254740993'), numberTerm('9007199254740992')), 1);
});
test('standard order compares numbers by value before type', () => {
  const order = (left, right) => run('', { goal: `compare(O, ${left}, ${right})` }).bindings[0].O;
  assert.equal(order('1.0', '0'), '>');
  assert.equal(order('2', '1.5'), '>');
  assert.equal(order('-1.5', '-2'), '>');
  // Equal value, so the float precedes the integer.
  assert.equal(order('1.0', '1'), '<');
  assert.equal(order('1', '1.0'), '>');
  assert.equal(order('9007199254740993', '9007199254740992.0'), '>');
  assert.equal(order('foo', '1'), '>');
});
