import test from './progress.js';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { Program, run, checkProof } from '../index.js';

const source = readFileSync(new URL('../examples/age.pl', import.meta.url), 'utf8');
function ask(program, goal) {
  const result = run(program, { goal, proof: true });
  if (result.answers.length) assert.equal(checkProof(program, result.proof, { allowTrusted: false, goals: [goal] }).valid, true);
  return result.answers;
}

test('age checker uses a reproducible reference date and strictly exceeds year thresholds', () => {
  const p = Program.parse(source);
  assert.deepEqual(ask(p, 'age_above(Person, years(80))'), ['age_above(pat_h, years(80))']);
  for (const day of [20, 21, 22]) {
    const goal = `age_above(pat_h, years(80), date(2024, 8, ${day}))`;
    assert.equal(ask(p, goal).length, day > 21 ? 1 : 0);
  }
  assert.deepEqual(ask(p, 'age_above(pat_h, years(83))'), []);
  assert.deepEqual(ask(p, 'age_days(pat_h, date(1944, 8, 21), Days)'), ['age_days(pat_h, date(1944, 8, 21), 0)']);
  for (const goal of [
    'age_above(pat_h, years(-1))', 'age_above(pat_h, years(1.5))',
    'age_above(pat_h, days(-1))', 'age_above(pat_h, days(1.5))',
    'age_above(unknown, years(80))', 'age_days(pat_h, date(1944, 8, 20), Days)',
    'age_above(pat_h, years(0), date(1944, 8, 20))',
  ]) assert.deepEqual(ask(p, goal), []);
});

test('age checker handles leap-day anniversaries and exact elapsed-day boundaries', () => {
  const p = Program.parse(source + '\nbirth_date(leap_child, date(2020, 2, 29)).');
  for (const [date, years, expected] of [
    ['date(2021, 2, 27)', 1, 0], ['date(2021, 2, 28)', 1, 0], ['date(2021, 3, 1)', 1, 1],
    ['date(2024, 2, 28)', 4, 0], ['date(2024, 2, 29)', 4, 0], ['date(2024, 3, 1)', 4, 1],
  ]) assert.equal(ask(p, `age_above(leap_child, years(${years}), ${date})`).length, expected);
  assert.deepEqual(ask(p, 'age_days(leap_child, date(2021, 2, 28), Days)'), ['age_days(leap_child, date(2021, 2, 28), 365)']);
  assert.deepEqual(ask(p, 'age_above(leap_child, days(365), date(2021, 2, 28))'), []);
  assert.equal(ask(p, 'age_above(leap_child, days(365), date(2021, 3, 1))').length, 1);
  assert.deepEqual(ask(p, 'age_above(leap_child, days(0), date(2020, 2, 29))'), []);
});

test('Gregorian day arithmetic agrees with an independent UTC calendar and rejects invalid dates', () => {
  const p = Program.parse(source);
  const first = Date.parse('0001-01-01T00:00:00Z');
  for (const year of [1899, 1900, 2000, 2024, 2100, 2400]) {
    for (let month = 1; month <= 12; month++) {
      const last = new Date(Date.UTC(year, month, 0)).getUTCDate();
      for (const day of [1, last]) {
        const expected = (Date.UTC(year, month - 1, day) - first)/86400000 + 1;
        assert.deepEqual(ask(p, `date_day(date(${year}, ${month}, ${day}), N)`), [`date_day(date(${year}, ${month}, ${day}), ${expected})`]);
      }
      assert.deepEqual(ask(p, `date_day(date(${year}, ${month}, ${last + 1}), N)`), []);
    }
  }
  for (const date of ['date(0, 1, 1)', 'date(2024, 0, 1)', 'date(2024, 13, 1)', 'date(2024, 1, 0)', 'date(2024, 1, 1.5)']) {
    assert.deepEqual(ask(p, `date_day(${date}, N)`), []);
  }
});
