import test from './progress.js';
import assert from 'node:assert/strict';
import { run, parseTermText, parseGoalText } from '../index.js';
import { parseProgramText } from '../src/kernel/parser.js';
import { text } from '../src/common.js';

// eyelang has no directives, so no program can change how the rest of itself
// is read: the operator table is fixed and the accepted syntax is a property
// of the parser alone. These cases pin that surface, each stating the
// canonical functional notation a source spelling reads as.
const reads = (source, expected) => {
  const clauses = parseProgramText(source);
  assert.equal(clauses.length, 1, `expected one clause from ${JSON.stringify(source)}`);
  const clause = clauses[0];
  const actual = clause.kind
    ? `${clause.kind}:${text(clause.goal)}`
    : `${text(clause.head)}:-${clause.body.map((goal) => text(goal)).join(',')}`;
  assert.equal(actual, expected, `for ${JSON.stringify(source)}`);
};
const rejects = (source, pattern) => assert.throws(() => parseProgramText(source), pattern, source);

test('clause shapes read as the documented terms', () => {
  reads('a.', 'a:-');
  reads('a(b, c).', 'a(b, c):-');
  reads('p(X) :- q(X).', 'p(X):-q(X)');
  reads('p :- q, r, s.', 'p:-q,r,s');
  reads('h :+ b.', "':+'(h, b):-");
  reads('true :+ b.', "':+'(true, b):-");
  reads('(a(X), b(X)) :+ c(X).', "':+'(','(a(X), b(X)), c(X)):-");
  reads('a(X), b(X) :+ c(X).', "':+'(','(a(X), b(X)), c(X)):-");
  reads('?- a.', 'query:a');
  reads('?- a, b.', "query:','(a, b)");
  reads('?-(a).', 'query:a');
  rejects('a(X), b(X), c(X) :+ d.', /expected \., got ,/);
  rejects('a', /expected \./);
  rejects('p :- .', /bad term/);
});

test('operator notation lowers to canonical compounds', () => {
  reads('?- X is 2 + 3 * 4.', 'query:is(X, +(2, *(3, 4)))');
  reads('?- X is (2 + 3) * 4.', 'query:is(X, *(+(2, 3), 4))');
  reads('?- X is 1 - 2 - 3.', 'query:is(X, -(-(1, 2), 3))');
  reads('?- X is 2 ** 3.', 'query:is(X, **(2, 3))');
  reads('?- X is 2 ^ 3 ^ 2.', 'query:is(X, ^(2, ^(3, 2)))');
  reads('?- a ; b.', 'query:;(a, b)');
  reads('?- \\+ a.', 'query:\\+(a)');
  reads('?- X = (a :- b).', "query:=(X, ':-'(a, b))");
  reads('?- X = a:b:c.', "query:=(X, ':'(a, ':'(b, c)))");
  reads('?- X = f(a, (b, c)).', "query:=(X, f(a, ','(b, c)))");
  rejects('?- X is 1 = 2 = 3.', /non-associative operator is requires parentheses/);
  rejects('?- X = a + .', /bad term/);
});

test('numbers keep ISO lexical syntax and canonical spelling', () => {
  const value = (source) => text(parseGoalText(`t(${source})`).args[0]);
  assert.equal(value('0xff'), '255');
  assert.equal(value('0o17'), '15');
  assert.equal(value('0b1011'), '11');
  assert.equal(value("0'a"), '97');
  assert.equal(value("0'''"), '39');
  assert.equal(value("0'\\n"), '10');
  assert.equal(value('1_000_000'), '1000000');
  assert.equal(value('007'), '7');
  assert.equal(value('1.0e3'), '1000.0');
  assert.equal(value('123456789012345678901234567890'), '123456789012345678901234567890');
  // A sign merged into a numeric literal canonicalizes like any other.
  assert.equal(value('-0'), '0');
  assert.equal(value('- 0.0'), '0.0');
  // A minus directly against a digit is lexical; after a term it is infix.
  assert.equal(text(parseGoalText('t(X-1)')), 't(-(X, 1))');
  assert.equal(text(parseGoalText('t(-1)')), 't(-1)');
  rejects('?- t(1.0e).', /expected \), got e/);
  rejects('?- t(0x).', /expected \), got x/);
});

test('atoms, strings and lists read as their canonical forms', () => {
  reads('?- X = "ab".', 'query:=(X, "ab")');
  // A list of one-character atoms is the same term as the double-quoted text.
  reads('?- X = [a, b].', 'query:=(X, "ab")');
  reads('?- X = [1, 2].', "query:=(X, '.'(1, '.'(2, [])))");
  reads('?- X = [a|T].', 'query:=(X, "a"||T)');
  reads('?- X = [].', 'query:=(X, [])');
  reads('?- X = {a, b}.', "query:=(X, {}(','(a, b)))");
  reads('?- X = {}.', 'query:=(X, {})');
  reads("?- X = 'it''s'.", "query:=(X, 'it''s')");
  reads('?- X = f(+).', 'query:=(X, f(+))');
  reads('?- X = (+).', 'query:=(X, +)');
  rejects("?- X = 'unterminated.", /unterminated quoted term/);
  rejects('?- X = [a, b.', /expected \], got \./);
  rejects("?- X = '\\z'.", /bad escape sequence/);
  rejects('?- X = f().', /zero-arity compound syntax is not supported/);
});

test('layout, comments and the end token are distinguished', () => {
  reads('% a comment\na.', 'a:-');
  reads('/* block */ a.', 'a:-');
  reads('a /* mid */ .', 'a:-');
  // A dot that continues a graphic token does not end the term.
  reads('?- t(.*).', 'query:t(.*)');
  assert.equal(parseProgramText('a.\nb.\n').length, 2);
  assert.equal(parseProgramText('').length, 0);
  rejects('/* unterminated\na.', /unterminated block comment/);
  rejects('a.b.', /expected \., got \./);
});

test('a query is never reinterpreted by what follows it', () => {
  // An indented clause after a query is still a clause.
  const clauses = parseProgramText('p(1).\n?- p(X).\n  q(y).\n');
  assert.deepEqual(clauses.map((clause) => clause.kind ?? 'clause'), ['clause', 'query', 'clause']);
  assert.deepEqual(run('p(1).\n?- p(X).\n  q(y).\n').answers, ['p(1)']);
});

test('directives and DCGs parse as terms and are refused by the profile', () => {
  for (const source of [
    ':- op(700, xfx, ===).', ':- dynamic(f/1).', ':- set_prolog_flag(double_quotes, codes).',
    ':- use_module(library(lists)).', ':- unknown_directive.', ':- initialization(main).',
    'a --> b.',
  ]) {
    assert.equal(parseProgramText(source).length, 1, source);
    assert.throws(() => run(source), /directives and DCGs are outside eyelang/, source);
  }
  // op/3 cannot introduce syntax, so a program using a declared operator is a
  // syntax error rather than a silently different reading.
  assert.throws(() => run(':- op(700, xfx, ===).\na === b.\n'), /expected \., got ===/);
});

test('source metadata records the line each clause starts on', () => {
  const clauses = parseProgramText('a.\n\nb :- c.\n?- d.\n');
  assert.deepEqual(clauses.map((clause) => clause.source.line), [1, 3, 4]);
});

test('term and goal entry points read one term', () => {
  assert.equal(text(parseTermText('f(a, [1, 2]).')), "f(a, '.'(1, '.'(2, [])))");
  assert.equal(text(parseGoalText('X = 1, Y = 2')), "','(=(X, 1), =(Y, 2))");
  assert.throws(() => parseTermText('f(a, b)'), /expected \./);
  assert.throws(() => parseTermText('f(a). g(b).'), /expected end of input/);
  assert.throws(() => parseGoalText('a. b.'), /bad goal|expected/);
});
