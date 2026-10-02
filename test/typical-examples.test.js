import test from './progress.js';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { Program, run, checkProof, parseTermText } from '../index.js';

const source = (name) => readFileSync(new URL(`../examples/${name}.pl`, import.meta.url), 'utf8');
function proved(input, options = {}, strict = true) {
  const result = run(input, { ...options, proof: true });
  if (result.answers.length) {
    const report = checkProof(input, result.proof, { allowTrusted: !strict });
    assert.equal(report.valid, true, JSON.stringify(report.failures));
  }
  return result;
}
const terms = (result) => result.answers.map((answer) => parseTermText(`${answer}.`));
function list(term) {
  const items = [];
  while (term.name === '.') { items.push(term.args[0]); term = term.args[1]; }
  assert.equal(term.name, '[]');
  return items;
}
const nat = (n) => 's('.repeat(n) + 'zero' + ')'.repeat(n);
function natural(term) {
  let n = 0;
  while (term.name === 's') { n++; term = term.args[0]; }
  assert.equal(term.name, 'zero');
  return n;
}

test('structured descriptions classify the trade without classifying novices', () => {
  const input = source('good-cobbler') + '\ndescription(alex, [good, cobbler]).';
  assert.deepEqual(new Set(proved(input).answers), new Set([
    'good_at(joe, cobbler)', 'good_at(jane, carpenter)', 'good_at(alex, cobbler)',
    'classified_as(joe, cobbler)', 'classified_as(jane, carpenter)', 'classified_as(alex, cobbler)',
  ]));
});

test('Peano addition enumerates all splits and symbolic multiplication and factorial agree with integers', () => {
  const p = Program.parse(source('peano'));
  for (let n = 0; n <= 5; n++) {
    const splits = terms(proved(p, { goal: `add(A, B, ${nat(n)})` }));
    assert.equal(splits.length, n + 1);
    assert.deepEqual(new Set(splits.map((t) => natural(t.args[0]))), new Set(Array.from({ length: n + 1 }, (_, i) => i)));
    for (const t of splits) assert.equal(natural(t.args[0]) + natural(t.args[1]), n);
  }
  const product = terms(proved(p, { goal: `multiply(${nat(3)}, ${nat(4)}, P)` }))[0];
  assert.equal(natural(product.args[2]), 12);
  const factorial = terms(proved(p, { goal: `factorial(${nat(4)}, F)` }))[0];
  assert.equal(natural(factorial.args[1]), 24);
});

test('recursive expression graphs reuse subexpressions and reject unknown operations', () => {
  const input = source('expression-eval') + `
    expression(double, add, total, total). root(shared, double).
    expression(negative, sub, n2, n10). root(negative_example, negative).
    expression(unknown, unknown_operation, n2, n3). root(unsupported, unknown).
  `;
  assert.deepEqual(new Set(proved(input).answers), new Set([
    'result(example, 12)', 'result(shared, 24)', 'result(negative_example, -8)',
  ]));
});

test('modular exponentiation agrees with exact powers and validates its integer domain', () => {
  const p = Program.parse(source('modexp'));
  for (const base of [-7n, 0n, 3n, 9007199254740993n]) {
    for (const exponent of [0n, 1n, 2n, 13n, 30n]) {
      for (const modulus of [1n, 97n]) {
        const expected = ((base ** exponent) % modulus + modulus) % modulus;
        const query = `mod_pow(${base}, ${exponent}, ${modulus}, R)`;
        assert.deepEqual(proved(p, { goal: query }).answers, [`mod_pow(${base}, ${exponent}, ${modulus}, ${expected})`]);
      }
    }
  }
  const lastDigits = (2n ** 1048576n) % 1000000000000n;
  assert.deepEqual(proved(p, { goal: 'mod_pow(2, 1048576, 1000000000000, R)' }).answers,
    [`mod_pow(2, 1048576, 1000000000000, ${lastDigits})`]);
  for (const query of ['mod_pow(2, -1, 97, R)', 'mod_pow(2, 10, 0, R)', 'mod_pow(2, 1.5, 97, R)']) {
    assert.deepEqual(run(p, { goal: query }).answers, []);
  }
});

test('concept alignment handles multilevel links and cycles with finite rollup results', () => {
  const input = source('concept-alignment') + `
    concept(electric_car). broader(electric_car, passenger_car).
    broader(vehicle_with_plate, passenger_car).
    concept(unrelated).
  `;
  assert.deepEqual(new Set(proved(input).answers), new Set([
    'rolls_up_to(reference_car, reference_car)', 'rolls_up_to(sensor_car, reference_car)',
    'rolls_up_to(sensor_heavy_vehicle, reference_car)', 'rolls_up_to(vehicle_with_plate, reference_car)',
    'rolls_up_to(passenger_car, reference_car)', 'rolls_up_to(electric_car, reference_car)',
  ]));
});

test('interval classification assigns one of all thirteen relations to every valid pair', () => {
  const input = source('interval-relations') + '\ninterval(empty, 10, 10). interval(reversed, 20, 10).';
  const result = proved(input);
  const relations = terms(result);
  assert.equal(relations.length, 100);
  assert.equal(new Set(relations.map((t) => t.args[1].name)).size, 13);
  const pairs = new Map();
  for (const t of relations) {
    const [a, r, b] = t.args.map((arg) => arg.name);
    assert.ok(!['empty', 'reversed'].includes(a));
    assert.ok(!['empty', 'reversed'].includes(b));
    const key = `${a}/${b}`;
    assert.equal(pairs.has(key), false, `multiple relations for ${key}`);
    pairs.set(key, r);
  }
  assert.equal(pairs.get('a/c'), 'meets');
  assert.equal(pairs.get('a/d'), 'overlaps');
  assert.equal(pairs.get('f/a'), 'starts');
  assert.equal(pairs.get('g/a'), 'finishes');
  assert.equal(pairs.get('a/h'), 'during');
  assert.equal(pairs.get('a/e'), 'equals');
  assert.equal(pairs.get('j/i'), 'meets');
  const inverses = { before: 'after', meets: 'met_by', overlaps: 'overlapped_by', starts: 'started_by', during: 'contains', finishes: 'finished_by', equals: 'equals' };
  for (const [key, relation] of pairs) {
    if (inverses[relation]) assert.equal(pairs.get(key.split('/').reverse().join('/')), inverses[relation]);
  }
});

test('Bayesian fault scores preserve exact weights and normalize after the complete collection', () => {
  const input = source('bayes-diagnosis') + '\nfault(toner_fault, 10, 100, 100).';
  const result = proved(input, {}, false);
  const expected = new Map([['paper_jam', 18000], ['network_loss', 14250], ['power_loss', 4950], ['toner_fault', 100000]]);
  const denominator = [...expected.values()].reduce((sum, n) => sum + n, 0);
  let total = 0;
  for (const t of terms(result)) {
    const [fault, numerator, divisor, probability] = t.args;
    assert.equal(Number(numerator.name), expected.get(fault.name));
    assert.equal(Number(divisor.name), denominator);
    assert.ok(Math.abs(Number(probability.name) - expected.get(fault.name)/denominator) < 1e-12);
    total += Number(probability.name);
  }
  assert.equal(result.answers.length, 4);
  assert.ok(Math.abs(total - 1) < 1e-12);
  assert.equal(checkProof(input, result.proof, { allowTrusted: false }).valid, false);
});

test('policy findings retain reasons, clamp scores and disappear when safeguards are supplied', () => {
  const input = source('policy-risk');
  assert.deepEqual(new Set(proved(input, {}, false).answers), new Set([
    'report(1, c1, 100, high, no_removal_safeguards, add_notice_and_inform)',
    'report(2, c3, 97, high, sharing_without_consent, require_consent)',
    'report(3, c2, 85, high, short_notice(3, 14), increase_notice(14))',
    'report(4, c4, 70, moderate, export_prohibited, permit_export)',
  ]));
  const repaired = input + '\nnotice_days(c1, 14). safeguard(c1, inform). safeguard(c3, consent).';
  assert.deepEqual(new Set(proved(repaired, {}, false).answers), new Set([
    'report(1, c2, 85, high, short_notice(3, 14), increase_notice(14))',
    'report(2, c4, 70, moderate, export_prohibited, permit_export)',
  ]));
});

test('N-queens enumerates both 4x4 solutions and yields a valid 8x8 board', () => {
  const p = Program.parse(source('queens'));
  const four = terms(proved(p, { goal: 'queens(4, Columns)' })).map((t) => list(t.args[1]).map((n) => Number(n.name)));
  assert.deepEqual(four, [[2, 4, 1, 3], [3, 1, 4, 2]]);
  const eight = terms(proved(p))[0].args[0];
  const columns = list(eight.args[1]).map((n) => Number(n.name));
  assert.equal(columns.length, 8);
  assert.deepEqual([...columns].sort((a, b) => a-b), [1, 2, 3, 4, 5, 6, 7, 8]);
  for (let a = 0; a < 8; a++) for (let b = a+1; b < 8; b++) assert.notEqual(Math.abs(columns[a]-columns[b]), b-a);
  assert.deepEqual(proved(p, { goal: 'queens(0, Columns)' }).answers, ['queens(0, [])']);
  assert.deepEqual(run(p, { goal: 'queens(2, Columns)' }).answers, []);
  assert.deepEqual(run(p, { goal: 'queens(-1, Columns)' }).answers, []);
});

test('complex arithmetic obeys the field laws and keeps Gaussian integers exact', () => {
  const p = Program.parse(source('complex'));
  const answer = (goal) => {
    const result = run(p, { goal });
    assert.equal(result.answers.length, 1, goal);
    // A conjunctive goal answers with the whole conjunction; the value asked
    // for is the last argument of its rightmost conjunct.
    let term = parseTermText(`${result.answers[0]}.`);
    while (term.name === ',' && term.arity === 2) term = term.args[1];
    return term.args.at(-1);
  };
  const c = (re, im) => `complex(${re}, ${im})`;
  const pair = (term) => {
    assert.equal(term.name, 'complex');
    return term.args.map((arg) => Number(arg.name));
  };
  const samples = [[1, 2], [3, -4], [-2, 5], [0, 1]];

  // The fixed conclusions the example publishes.
  assert.deepEqual(new Set(proved(p).answers), new Set([
    'sum(complex(4, 6))', 'product(complex(-5, 10))', 'quotient(complex(3, 4))',
    'ratio(complex(2.2, -0.4))', 'unit_square(complex(-1, 0))',
    'conjugate_product(z, complex(25, 0))', 'conjugate_product(w, complex(5, 0))',
    'norm_multiplicative(25, 5, 125)', 'integer_power(8, complex(16, 0))',
    'modulus(z, 5.0)', 'modulus(w, 2.23606797749979)',
    'power(root, complex(6.123233995736766e-17, 1.0))',
    'power(euler, complex(-1.0, 1.2246467991473532e-16))',
    'power(self_power, complex(0.20787957635076193, 0.0))',
    'power(real_power, complex(0.20787957635177984, 0.0))',
    'arcsine(complex(2, 0), complex(1.5707963267948966, 1.3169578969248166))',
    'arccosine(complex(2, 0), complex(0.0, -1.3169578969248166))',
    'logarithm(natural, complex(0.0, 3.141592653589793))',
    'logarithm(imaginary, complex(1.0, 0.0))',
    'sine(complex(1.9999999999999998, 1.0605752387249067e-16))',
    'cosine(complex(1.9999999999999998, 0.0))',
    'arctangent(complex(1.3389725222944935, 0.402359478108525))',
    'tangent(complex(1.0, 1.9999999999999996))',
  ]));

  for (const [a, b] of samples) {
    // Multiplying by the conjugate leaves the norm on the real axis.
    assert.deepEqual(pair(answer(`complex_conjugate(${c(a, b)}, C), complex_mul(${c(a, b)}, C, P)`)),
      [a * a + b * b, 0]);
    for (const [x, y] of samples) {
      const sum = pair(answer(`complex_add(${c(a, b)}, ${c(x, y)}, S)`));
      const product = pair(answer(`complex_mul(${c(a, b)}, ${c(x, y)}, P)`));
      assert.deepEqual(sum, [a + x, b + y]);
      assert.deepEqual(product, [a * x - b * y, a * y + b * x]);
      // Addition and multiplication commute.
      assert.deepEqual(pair(answer(`complex_mul(${c(x, y)}, ${c(a, b)}, P)`)), product);
      assert.deepEqual(pair(answer(`complex_add(${c(x, y)}, ${c(a, b)}, S)`)), sum);
      // Subtraction inverts addition, and every component stays an integer.
      assert.deepEqual(pair(answer(`complex_sub(${c(...sum)}, ${c(x, y)}, D)`)), [a, b]);
      assert.ok(sum.every(Number.isInteger) && product.every(Number.isInteger));
      // The norm is multiplicative, so dividing a product by a factor is exact.
      assert.equal(Number(answer(`complex_norm(${c(...product)}, N)`).name),
        (a * a + b * b) * (x * x + y * y));
      if (x || y) assert.deepEqual(pair(answer(`complex_div(${c(...product)}, ${c(x, y)}, Q)`)), [a, b]);
    }
  }

  // Repeated squaring agrees with repeated multiplication.
  let expected = [1, 0];
  for (let exponent = 0; exponent <= 12; exponent++) {
    assert.deepEqual(pair(answer(`complex_power(${c(1, 1)}, ${exponent}, P)`)), expected);
    expected = [expected[0] - expected[1], expected[0] + expected[1]];
  }
  // Division by zero and a negative exponent have no answer.
  assert.deepEqual(run(p, { goal: `complex_div(${c(1, 1)}, ${c(0, 0)}, Q)` }).answers, []);
  assert.deepEqual(run(p, { goal: `complex_power(${c(1, 1)}, -1, P)` }).answers, []);
});
