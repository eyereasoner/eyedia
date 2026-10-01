import test from './progress.js';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { run, checkProof, Program } from '../index.js';

const example = (name) => readFileSync(new URL(`../examples/${name}.pl`, import.meta.url), 'utf8');
function proven(source, options = {}) {
  const result = run(source, { ...options, proof: true });
  const report = checkProof(source, result.proof);
  assert.equal(report.valid, true, JSON.stringify(report.failures));
  return result;
}
test('standalone forward inference and proof', () => {
  assert.deepEqual(proven(example('socrates')).answers, ['mortal(socrates)']);
});
test('mixed forward and backward reasoning', () => {
  const source = example('backward');
  assert.deepEqual(proven(source).answers, ['indeed_more_interesting(5, 3)']);
  assert.deepEqual(proven(source, { goal: 'more_interesting(9, 2)' }).answers, ['more_interesting(9, 2)']);
});
test('recursive graph closure terminates on cycles and suppresses duplicates', () => {
  const source = 'edge(a,b). edge(b,a). path(X,Y) :+ edge(X,Y). path(X,Z) :+ path(X,Y), edge(Y,Z).';
  assert.deepEqual(new Set(proven(source).answers), new Set(['path(a, b)', 'path(b, a)', 'path(a, a)', 'path(b, b)']));
});
test('family translation computes transitive ancestry', () => {
  const result = proven(example('family'));
  assert.equal(result.answers.length, 7);
  assert.ok(result.answers.includes('t(x, descended_from, c)'));
});
test('lists, quoted formulas, triple terms and existential conclusion sharing', () => {
  const result = proven(example('terms'));
  assert.equal(result.answers.length, 2);
  assert.match(result.answers[0], /^found\(triple/);
  assert.match(result.answers[1], /sk_0\)$/);
  assert.deepEqual(proven('in(a). pair(X,Y,Y) :+ in(X).').answers, ['pair(a, sk_0, sk_0)']);
});
test('recursive arithmetic and embedded query', () => {
  assert.deepEqual(proven(example('fibonacci'), { goal: 'fib(10, F)' }).answers, ['fib(10, 55)']);
});
test('large Fibonacci indices are exact and stay within small reasoning budgets', () => {
  const program = Program.parse(example('fibonacci'));
  let current = 0n, next = 1n;
  const indices = new Set([0, 1, 2, 3, 10, 100, 1000, 10000]);
  for (let n = 0; n <= 10000; n++) {
    if (indices.has(n)) {
      const result = proven(program, { goal: `fib(${n}, F)`, maxDepth: 32, maxInferences: 1000 });
      assert.deepEqual(result.answers, [`fib(${n}, ${current})`]);
    }
    [current, next] = [next, current + next];
  }
  assert.deepEqual(run(program, { goal: 'fib(-1, F)' }).answers, []);
});
test('base graph isolation, stratified absence and completed collection', () => {
  const source = example('graphs');
  const result = proven(source);
  assert.ok(result.answers.includes('allowed(carol)'));
  assert.ok(!result.answers.includes('allowed(bob)'));
  assert.ok(result.answers.some((answer) => answer.startsWith('children(alice,')));
  assert.deepEqual(run(source, { goal: 'base(bob, child_of, alice)' }).answers, []);
  const report = checkProof(source, result.proof);
  assert.deepEqual(new Set(report.trusted.map((item) => item.kind)), new Set(['absent', 'collected']));
  assert.equal(checkProof(source, result.proof, { allowTrusted: false }).valid, false);
});
test('negative dependencies through backward definitions run after lower closure', () => {
  const source = 'seed(a). clear(a) :+ \\+ blocked(a). blocked(X) :- derived(X). derived(X) :+ seed(X).';
  assert.deepEqual(proven(source).answers, ['derived(a)']);
});
test('closed dependency cycles are rejected', () => {
  assert.throws(() => Program.parse('p :+ \\+ q. q :+ p.'), /unstratified/);
  assert.throws(() => Program.parse('p(X) :+ findall(Y,p(Y),X).'), /unstratified/);
});
test('RDF predicate positions distinguish unrelated open and closed dependencies', () => {
  const source = `
    t(a,seed,true).
    t(X,allowed,true) :+ t(X,seed,true), \\+ t(X,blocked,true).
    t(X,blocked,true) :+ t(X,seed,true).
  `;
  assert.deepEqual(proven(source).answers, ['t(a, blocked, true)']);
});
test('conjunction, disjunction, meta-call and once preserve proof uses', () => {
  proven('p(a). p(b). q(X) :- (p(X), X=a).', { goal: 'q(X)' });
  proven('p(a). p(b).', { goal: '(p(a); p(b))' });
  proven('p(a). p(b).', { goal: 'call((p(a),p(b)))' });
  assert.equal(proven('p(a). p(b).', { goal: 'once(p(X))' }).answers.length, 1);
  proven('p(a). p(b).', { goal: 'p(a),p(b)' });
});
test('true :+ selects output and false :+ trips the inference fuse', () => {
  const source = 'p(a). q(X) :+ p(X). true :+ q(X).';
  assert.deepEqual(proven(source).answers, ['q(a)']);
  const result = proven('p(a). false :+ p(a).');
  assert.equal(result.haltCode, 65);
  assert.deepEqual(result.answers, ['false']);
});
test('nonground answers retain shared variables', () => {
  const result = proven('same(X,X).', { goal: 'same(A,B)' });
  assert.equal(result.answers.length, 1);
  assert.equal(result.bindings[0].A, result.bindings[0].B);
});
test('unsupported constructs and resource exhaustion fail explicitly', () => {
  assert.throws(() => run(':- use_module(library(lists)).'), /directives/);
  assert.throws(() => run('p --> q.'), /DCGs/);
  assert.throws(() => run('p :- p.', { goal: 'p', maxDepth: 10 }), /maxDepth/);
  assert.throws(() => run('p(0). p(N) :+ p(M), N is M+1.', { maxIterations: 3 }), /maxIterations/);
  assert.throws(() => run('p(a). q(X) :+ p(X).', { maxInferences: 1 }), /maxInferences/);
  assert.throws(() => run('', { goal: '\\+ p(X)' }), /ground/);
});
test('pure term and text operations', () => {
  const source = `
    out(C,N) :- atom_concat(ab,cd,C), atom_length(C,N).
    term(T) :- T =.. [pair,a,b], functor(T,pair,2), arg(2,T,b).
    chars(C) :- atom_chars('😀a',C).
    codes(C) :- atom_codes('😀a',C).
  `;
  assert.deepEqual(proven(source, { goal: 'out(C,N)' }).answers, ['out(abcd, 4)']);
  assert.deepEqual(proven(source, { goal: 'term(T)' }).answers, ['term(pair(a, b))']);
  proven(source, { goal: 'chars(C)' });
  proven(source, { goal: 'codes(C)' });
});
test('arithmetic preserves unbounded integers and numeric types', () => {
  assert.deepEqual(proven('out(N) :- N is 9007199254740993+1.', { goal: 'out(N)' }).answers, ['out(9007199254740994)']);
  assert.deepEqual(run('p(1).', { goal: 'p(1.0)' }).answers, []);
});
test('finite-tree unification rejects cycles and nested identity resolves bindings', () => {
  assert.deepEqual(run('', { goal: 'X=f(X)' }).answers, []);
  proven('p :- X=a, f(X)==f(a).', { goal: 'p' });
  proven('p(T) :- X=pair, T =.. [X,a,b].', { goal: 'p(T)' });
  proven("p(C) :- C=a, atom_chars(A,[C]), A=a.", { goal: 'p(C)' });
});
test('computed calls work backward and forward dependency analysis rejects hidden calls', () => {
  assert.deepEqual(proven('p(a). apply(G) :- call(G).', { goal: 'apply(p(a))' }).answers, ['apply(p(a))']);
  assert.throws(() => run('p(a). apply(G) :- call(G). q :+ apply(p(a)).'), /statically named/);
  assert.throws(() => run('p :- !.', { goal: 'p' }), /outside eyelang/);
  assert.throws(() => run('apply(G) :- call(G).', { goal: 'apply(!)' }), /outside eyelang/);
});
test('parsed programs can be reused without sharing derived state', () => {
  const program = Program.parse('p(a). q(X) :+ p(X).');
  assert.deepEqual(run(program).answers, ['q(a)']);
  assert.deepEqual(run(program).answers, ['q(a)']);
});
test('atom clause indexing preserves source order, generic clauses and bound arguments', () => {
  const source = `
    p(a, first). p(X, generic_before). p(b, other).
    p(a, second). p(X, generic_after). p(f(a), structured). p(1, numeric).
  `;
  assert.deepEqual(proven(source, { goal: 'p(a, Y)' }).answers, [
    'p(a, first)', 'p(a, generic_before)', 'p(a, second)', 'p(a, generic_after)',
  ]);
  assert.deepEqual(proven(source, { goal: 'p(missing, Y)' }).answers, [
    'p(missing, generic_before)', 'p(missing, generic_after)',
  ]);
  assert.equal(proven(source, { goal: 'p(X, Y)' }).answers.length, 7);
  assert.equal(proven(source, { goal: 'p(f(a), Y)' }).answers.length, 3);
  assert.equal(proven(source, { goal: 'p(1, Y)' }).answers.length, 3);
  assert.deepEqual(proven(source, { goal: 'p(X, structured)' }).answers, ['p(f(a), structured)']);
  assert.equal(proven(source, { goal: 'X=a, p(X, Y)' }).answers.length, 4);
});
test('proofs fail explicitly when mode tests lose their evaluation-time state', () => {
  assert.deepEqual(run('p(X) :- var(X), X=a.', { goal: 'p(X)' }).answers, ['p(a)']);
  assert.throws(() => run('p(X) :- var(X), X=a.', { goal: 'p(X)', proof: true }), /cannot certify/);
});
