import test from './progress.js';
import assert from 'node:assert/strict';
import { run, checkProof, checkReportTerms, verdictTermText } from '../index.js';
import { parseProgramText } from '../src/kernel/parser.js';
import { text } from '../src/common.js';

const facts = (report) => parseProgramText(checkReportTerms(report)).map((clause) => {
  assert.equal(clause.body.length, 0);
  return clause.head;
});
test('check reports expose C1-C5 coverage and source/primitive counts', () => {
  const source = 'p(a). q(X) :- p(X), X=a.';
  const report = checkProof(source, run(source, { goal: 'q(X)', proof: true }).proof);
  assert.deepEqual(report.conditions, [
    { id: 'C1', name: 'resolution', covered: 2, failed: 0 },
    { id: 'C2', name: 'well_founded', covered: 3, failed: 0 },
    { id: 'C3', name: 'justification', covered: 3, failed: 0 },
    { id: 'C4', name: 'coverage', covered: 3, failed: 0 },
    { id: 'C5', name: 're_decision', covered: 1, failed: 0 },
  ]);
  assert.equal(report.uses, 2);
  assert.equal(verdictTermText(report), 'verdict(checked).\n');
  assert.equal(facts(report).filter((fact) => fact.name === 'condition').length, 5);
  assert.match(checkReportTerms(report), /recomputed\(1\)\./);
});
test('each failed condition is represented with counts and a failure conclusion', () => {
  const cases = [
    ['C1', 'p(a).', 'p(b). step(p(b),fact(1),[],[]).'],
    ['C2', 'p :- p.', 'p. step(p,rule(1),[],[p]).'],
    ['C3', '', 'p. step(p,magic,[],[]).'],
    ['C4', '', 'missing. true. step(true,builtin,[],[]).'],
    ['C5', '', 'is(7,+(2,3)). step(is(7,+(2,3)),builtin,[],[]).'],
  ];
  for (const [id, source, document] of cases) {
    const report = checkProof(source, document);
    const records = facts(report);
    const condition = records.find((fact) => fact.name === 'condition' && fact.args[0].name === id);
    assert.equal(condition.args[2].name, 'failed');
    assert.equal(Number(condition.args[2].args[0].name), report.failures.filter((failure) => failure.condition === id).length);
    const failure = records.find((fact) => fact.name === 'failure' && fact.args[0].name === id);
    assert.ok(failure);
    assert.notEqual(failure.args[1].name, 'proof_document');
    assert.equal(records.at(-1).args[0].name, 'failed');
    assert.equal(Number(records.at(-1).args[0].args[0].name), report.failures.length);
  }
});
test('control composition is counted under C5 independently of source resolution', () => {
  const source = 'p(a).';
  const report = checkProof(source, run(source, { goal: 'call(p(a))', proof: true }).proof);
  assert.equal(report.verified, 1);
  assert.equal(report.composed, 1);
  assert.equal(report.conditions[0].covered, 1);
  assert.equal(report.conditions[4].covered, 1);
  assert.match(checkReportTerms(report), /composed\(1\)\./);
  const invalid = checkProof(source, 'call(p(b)). step(call(p(b)),control,[],[p(a)]).');
  assert.ok(invalid.conditions[4].failed > 0);
});
test('obligations carry actual goal terms and strict checking records C5 failures', () => {
  const source = 'p(a). out(X) :+ p(X), \\+ missing(X).';
  const proof = run(source, { proof: true }).proof;
  const report = checkProof(source, proof);
  const obligation = facts(report).find((fact) => fact.name === 'obligation');
  assert.equal(obligation.args[0].name, 'absent');
  assert.equal(obligation.args[1].name, 'theory_scoped');
  assert.equal(obligation.args[2].type, 'compound');
  assert.equal(obligation.args[2].name, '\\+');
  assert.equal(verdictTermText(report), 'verdict(checked_with_obligations).\n');
  const strict = checkProof(source, proof, { allowTrusted: false });
  assert.equal(strict.conditions[4].failed, 1);
  assert.match(checkReportTerms(strict), /condition\('C5', re_decision, failed\(1\), 0\)\./);
});
test('Prolog check reports can be loaded and queried as ordinary data', () => {
  const source = 'p(a). q(X) :+ p(X).';
  const report = checkProof(source, run(source, { proof: true }).proof);
  const data = checkReportTerms(report);
  assert.deepEqual(run(data, { goal: "condition('C1', Name, ok, Count)" }).answers,
    ["condition('C1', resolution, ok, 2)"]);
  assert.deepEqual(run(data, { goal: 'verdict(Result)' }).answers, ['verdict(checked)']);
});
test('malformed-document diagnostics remain valid Prolog atoms', () => {
  const report = checkProof('', "p('unterminated");
  const records = facts(report);
  assert.equal(records.filter((fact) => fact.name === 'condition').length, 5);
  const failure = records.find((fact) => fact.name === 'failure');
  assert.equal(failure.args[1].name, 'proof_document');
  assert.equal(failure.args[2].name, report.failures[0].detail);
  assert.equal(text(records.at(-1)), `verdict(failed(${report.failures.length}))`);
});
