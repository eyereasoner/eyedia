import test from './progress.js';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { Program, run, checkProof, parseTermText } from '../index.js';

const source = readFileSync(new URL('../examples/research-portal.pl', import.meta.url), 'utf8');
function evaluate(input = source) {
  const program = Program.parse(input);
  const result = run(program, { proof: true });
  assert.equal(checkProof(program, result.proof).valid, true);
  assert.deepEqual([...new Set(result.proofReport.trusted.map(item => item.kind))], ['collected']);
  return result.answers.map(answer => parseTermText(`${answer}.`));
}
function assessment(terms, regime, id) {
  const found = terms.filter(term => term.name === 'assessment' && term.args[0].name === regime && term.args[1].name === `ex:${id}`);
  assert.equal(found.length, 1, `${regime}/${id}`);
  return found[0].args[2];
}

test('research portal produces one assessment per session and regime and exactly five changes', () => {
  const terms = evaluate();
  assert.equal(terms.length, 35);
  for (const regime of ['in_force', 'omnibus_proposal']) {
    for (let i = 1; i <= 10; i++) assessment(terms, regime, `r${i}`);
  }
  const changes = terms.filter(term => term.name === 'changed').map(term => `${term.args[0].name}:${term.args[0].args[0].name}`).sort();
  assert.deepEqual(changes, ['breach:b2', 'breach:b3', 'session:ex:r1', 'session:ex:r7', 'session:ex:r8']);
});

test('research portal device exemptions never override withdrawn research consent or policy prohibition', () => {
  const terms = evaluate();
  assert.equal(assessment(terms, 'in_force', 'r1').name, 'await_device_consent');
  assert.equal(assessment(terms, 'omnibus_proposal', 'r1').name, 'permit');
  for (const regime of ['in_force', 'omnibus_proposal']) {
    for (const id of ['r2', 'r3', 'r4', 'r5', 'r6']) assert.equal(assessment(terms, regime, id).name, 'deny_policy');
  }
  const repaired = evaluate(source.replace("'dpv:CommercialResearch', 'dpv:ConsentWithdrawn'", "'dpv:CommercialResearch', 'dpv:ConsentGiven'"));
  assert.equal(assessment(repaired, 'in_force', 'r4').name, 'await_device_consent');
  assert.equal(assessment(repaired, 'omnibus_proposal', 'r4').name, 'permit');
});

test('research portal respects the device signal and refusal boundary and allows removal of optional tracking', () => {
  const terms = evaluate();
  assert.equal(assessment(terms, 'omnibus_proposal', 'r7').args[0].name, 'refused_by_signal');
  assert.equal(assessment(terms, 'omnibus_proposal', 'r8').args[0].name, 'do_not_ask_again');
  assert.equal(assessment(terms, 'omnibus_proposal', 'r9').name, 'await_device_consent');
  const untracked = evaluate(source.replace("session('ex:r7', advertising,", "session('ex:r7', requested_service,"));
  for (const regime of ['in_force', 'omnibus_proposal']) assert.equal(assessment(untracked, regime, 'r7').name, 'permit');
});

test('research portal attaches duties only to final permits and records the overriding prohibition', () => {
  const terms = evaluate();
  const duties = terms.filter(term => term.name === 'planned_duty');
  assert.equal(duties.length, 3);
  for (const duty of duties) {
    assert.equal(assessment(terms, duty.args[0].name, duty.args[1].name.slice(3)).name, 'permit');
    assert.equal(duty.args[2].name, 'odrl:delete');
    assert.equal(duty.args[3].args[0].name, '90');
  }
  assert.equal(terms.filter(term => term.name === 'policy_conflict' && term.args[0].name === 'ex:r6').length, 1);
  const missing = evaluate(source + "\nt('ex:research', 'odrl:constraint', 'ex:undefined').");
  assert.equal(assessment(missing, 'omnibus_proposal', 'r1').name, 'deny_policy');
  assert.equal(missing.filter(term => term.name === 'planned_duty').length, 0);
});

test('research portal documents every breach and preserves communication to people across regimes', () => {
  const plans = evaluate().filter(term => term.name === 'breach_plan');
  assert.equal(plans.length, 6);
  for (const id of ['b1', 'b2', 'b3']) {
    const pair = plans.filter(term => term.args[1].name === id);
    assert.equal(pair.length, 2);
    for (const plan of pair) assert.equal(plan.args[3].name, 'document_breach');
    assert.equal(pair[0].args[2].args[1].args[0].name, pair[1].args[2].args[1].args[0].name);
  }
  const some = plans.find(term => term.args[0].name === 'omnibus_proposal' && term.args[1].name === 'b2');
  assert.equal(some.args[2].args[0].args[0].name, 'none');
  const high = plans.find(term => term.args[0].name === 'omnibus_proposal' && term.args[1].name === 'b3');
  assert.equal(high.args[2].args[0].args[0].name, 'within_hours_via_single_entry_point');
  assert.equal(high.args[2].args[0].args[0].args[0].name, '96');
});

test('research portal refuses incomplete descriptions and unmatched parties with explicit reasons', () => {
  const incomplete = source + `
    t('ex:incomplete', 'rdf:type', 'dpv:Process').
    t('ex:incomplete', 'ex:requestedBy', 'ex:partnerBE').
    t('ex:incomplete', 'dpv:hasProcessing', 'dpv:Use').
    t('ex:incomplete', 'dpv:hasPersonalData', 'ex:labResults').
    t('ex:incomplete', 'dpv:hasPurpose', 'dpv:AcademicResearch').
    t('ex:incomplete', 'dpv:hasLegalBasis', 'dpv:Consent').
    t('ex:incomplete', 'dpv:hasConsentStatus', 'dpv:ConsentGiven').
    t('ex:incomplete', 'ex:requestDate', 20261115).
    session('ex:incomplete', own_audience_measurement, first_visit).
    process('ex:outsider', 'ex:outsider', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
    session('ex:outsider', requested_service, first_visit).
  `;
  const terms = evaluate(incomplete);
  for (const regime of ['in_force', 'omnibus_proposal']) {
    const missing = assessment(terms, regime, 'incomplete');
    assert.equal(missing.name, 'deny_policy');
    const reasons = missing.args[0].args[0];
    assert.equal(reasons.args[0].name, 'missing_value');
    assert.equal(reasons.args[0].args[0].name, 'ex:pseudonymised');
    assert.equal(assessment(terms, regime, 'outsider').args[0].name, 'no_matching_permission');
  }
});

test('research portal rejects unsupported or missing conflict declarations explicitly', () => {
  const declaration = "t('ex:policy', 'odrl:conflict', 'odrl:prohibit').";
  for (const replacement of ["t('ex:policy', 'odrl:conflict', 'odrl:perm').", '', declaration + "\nt('ex:policy', 'odrl:conflict', 'odrl:invalid')."]) {
    const terms = evaluate(source.replace(declaration, replacement));
    const assessments = terms.filter(term => term.name === 'assessment');
    assert.equal(assessments.length, 20);
    assert.ok(assessments.every(term => term.args[2].name === 'deny_policy' && term.args[2].args[0].name === 'unsupported_conflict_strategy'));
    assert.equal(terms.filter(term => ['planned_duty', 'policy_conflict'].includes(term.name)).length, 0);
    assert.equal(terms.filter(term => term.name === 'breach_plan').length, 6);
  }
});

test('research portal treats the expiry date as exclusive and requires device consent for nonexempt measurement', () => {
  const terms = evaluate(source.replace("'dpv:Encryption', 20270301", "'dpv:Pseudonymisation', 20270101"));
  for (const regime of ['in_force', 'omnibus_proposal']) {
    assert.equal(assessment(terms, regime, 'r5').name, 'deny_policy');
  }
  for (const kind of ['shared_measurement', 'unaggregated_measurement']) {
    const changed = evaluate(source.replace("session('ex:r1', own_audience_measurement,", `session('ex:r1', ${kind},`));
    for (const regime of ['in_force', 'omnibus_proposal']) assert.equal(assessment(changed, regime, 'r1').name, 'await_device_consent');
  }
});
