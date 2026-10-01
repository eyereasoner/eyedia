import test from './progress.js';
import assert from 'node:assert/strict';
import { run, checkProof } from '../index.js';

const source = 'p(a). q(X) :+ p(X). r(X) :+ q(X).';
const proof = () => run(source, { proof: true }).proof;
const invalid = (document, condition, program = source) => {
  const report = checkProof(program, document);
  assert.equal(report.valid, false);
  assert.ok(report.failures.some((failure) => failure.condition === condition), JSON.stringify(report));
};
test('proofs are checked against source rather than display records', () => {
  invalid(proof().replace('clause(1, p(a), true)', 'clause(1, p(b), true)'), 'C1');
  invalid(proof(), 'C1', source.replace('p(a)', 'p(b)'));
});
test('altered conclusion, premise, binding and source citation fail resolution', () => {
  invalid(proof().replace('step(q(a)', 'step(q(b)'), 'C1');
  invalid(proof().replace("'.'(p(a), [])", "'.'(p(b), [])"), 'C1');
  invalid(proof().replace("=('X', a)", "=('X', b)"), 'C1');
  invalid(proof().replace('rule(2)', 'rule(999)'), 'C1');
});
test('omitted steps, missing premises and unrelated claims fail coverage', () => {
  invalid(proof().replace(/^step\(q\(a\).*\n/m, ''), 'C4');
  invalid(proof() + 'unrelated(a).\n', 'C4');
  invalid('', 'C4');
});
test('unknown, duplicate and malformed justifications are rejected', () => {
  invalid(proof().replace('rule(2)', 'magic'), 'C3');
  invalid(proof() + 'step(q(a),rule(2),[],[]).\n', 'C3');
  invalid('q(a). step(q(a),rule(2),broken,[]).', 'C3');
  invalid('q(a). step(q(a),rule(2),[],[]):-true.', 'C3');
  invalid('unterminated(', 'C3');
});
test('cyclic certificates cannot justify their own conclusions', () => {
  invalid('p. step(p,rule(1),[],[p]).', 'C2', 'p :- p.');
});
test('primitive results are recomputed with no theory clauses', () => {
  invalid('is(7, +(2,3)). step(is(7, +(2,3)),builtin,[],[]).', 'C5');
  invalid('evil. step(evil,builtin,[],[]).', 'C3', 'evil.');
  const report = checkProof('', 'is(5, +(2,3)). step(is(5, +(2,3)),builtin,[],[]).');
  assert.equal(report.valid, true);
  assert.equal(report.redecided, 1);
});
test('source variable sharing cannot be forged', () => {
  invalid('same(a,b). step(same(a,b),fact(1),[],[]).', 'C1', 'same(X,X).');
});
test('absence and collection obligations remain visible', () => {
  const s = 'p(a). out(X) :+ p(X), \\+ missing(X).';
  const document = run(s, { proof: true }).proof;
  assert.equal(checkProof(s, document).trusted.length, 1);
  assert.equal(checkProof(s, document, { allowTrusted: false }).valid, false);
});
