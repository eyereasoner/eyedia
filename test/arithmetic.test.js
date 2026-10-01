import test from './progress.js';
import assert from 'node:assert/strict';
import { run } from '../index.js';

const value = (expression) => run(`?- X is ${expression}.`).bindings[0].X;
const fails = (expression) => {
  try { run(`?- X is ${expression}.`); } catch (error) { return error.message; }
  return null;
};

test('integer results never round through a double', () => {
  assert.equal(value('truncate(10000000000000000001)'), '10000000000000000001');
  assert.equal(value('ceiling(123456789012345678901234567890)'), '123456789012345678901234567890');
  assert.equal(value('floor(-99999999999999999999)'), '-99999999999999999999');
  assert.equal(value('round(10000000000000000001)'), '10000000000000000001');
  assert.equal(value('abs(-123456789012345678901234567890)'), '123456789012345678901234567890');
  assert.equal(value('2 ^ 100'), '1267650600228229401496703205376');
  assert.equal(value('1 << 200'), '1606938044258990275541962092341162602522202993782792835301376');
});

test('rounding follows the ISO functions on floats', () => {
  assert.equal(value('round(2.5)'), '3');
  assert.equal(value('round(-2.5)'), '-3');
  assert.equal(value('round(-2.4)'), '-2');
  assert.equal(value('truncate(-2.7)'), '-2');
  assert.equal(value('floor(-2.5)'), '-3');
  assert.equal(value('ceiling(-2.5)'), '-2');
  assert.equal(value('float_integer_part(2.75)'), '2.0');
  assert.equal(value('float_fractional_part(2.75)'), '0.75');
});

test('division of integers stays integral when it is exact', () => {
  assert.equal(value('4 / 2'), '2');
  assert.equal(value('-4 / 2'), '-2');
  assert.equal(value('7 / 2'), '3.5');
  assert.equal(value('4 / 2.0'), '2.0');
  assert.equal(value('-7 // 3'), '-2');
  assert.equal(value('-7 div 3'), '-3');
  assert.equal(value('-7 mod 3'), '2');
  assert.equal(value('-7 rem 3'), '-1');
});

test('exceptional conditions are reported as ISO error terms', () => {
  assert.match(fails('1 / 0'), /zero_divisor/);
  assert.match(fails('1 mod 0'), /zero_divisor/);
  assert.match(fails('0 ^ (-1)'), /undefined/);
  assert.match(fails('log(0)'), /undefined/);
  assert.match(fails('gcd(1, 2.0)'), /type_error\(integer\)/);
  assert.match(fails('float_integer_part(3)'), /type_error\(float\)/);
  assert.match(fails('foo + 1'), /type_error\(evaluable\)/);
  assert.match(fails('Y + 1'), /instantiation_error/);
});

test('arithmetic comparison stays exact across the integer/float boundary', () => {
  assert.deepEqual(run('?- 9007199254740993 > 9007199254740992.0.').answers,
    ['>(9007199254740993, 9007199254740992.0)']);
  assert.deepEqual(run('?- 2 > 1.5.').answers, ['>(2, 1.5)']);
  assert.deepEqual(run('?- 1 =:= 1.0.').answers, ["'=:='(1, 1.0)"]);
});
