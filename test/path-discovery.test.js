import test from './progress.js';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { Program, run, checkProof, atom, compound, numberTerm, variable, listFromItems } from '../index.js';
import { text } from '../src/common.js';

const source = readFileSync(new URL('../examples/path-discovery.pl', import.meta.url), 'utf8');
let network;
const program = () => network ??= Program.parse(source);
const goal = (from, to, max) => text(compound('path_discovery', [atom(from), atom(to), numberTerm(max), variable('Path')]));
function routes(program, from, to, max) {
  const names = new Map(), edges = new Map();
  for (const { head } of program.clauses) {
    if (head.name === 'airport') names.set(head.args[0].name, head.args[1].name);
    if (head.name === 'flight') {
      const [a, b] = head.args.map((arg) => arg.name);
      if (!edges.has(a)) edges.set(a, []);
      edges.get(a).push(b);
    }
  }
  const answers = [];
  for (const [start, name] of names) {
    if (name !== from) continue;
    function visit(path) {
      for (const next of edges.get(path.at(-1)) ?? []) {
        if (path.includes(next)) continue;
        const extended = [...path, next];
        if (names.get(next) === to) {
          answers.push(text(compound('path_discovery', [atom(from), atom(to), numberTerm(max), listFromItems(extended.map((id) => atom(names.get(id))))])));
        } else if (extended.length < max + 2) visit(extended);
      }
    }
    visit([start]);
  }
  return answers.sort();
}

test('full airport network: 11 queries, 8 independent graph comparisons and strict proof checks', (context) => {
  const p = program();
  assert.equal(p.clauses.filter(({ head }) => head.name === 'airport').length, 7698);
  assert.equal(p.clauses.filter(({ head }) => head.name === 'flight').length, 37505);
  const ostend = 'Ostend-Bruges International Airport', prague = 'Václav Havel Airport Prague';
  let strictChecks = 0;
  for (const [from, to, max] of [
    [ostend, prague, 0], [ostend, prague, 1], [ostend, prague, 2],
    ['Liège Airport', prague, 1], [prague, ostend, 2],
    [ostend, 'Liège Airport', 0], [ostend, ostend, 3],
    ['Unknown Airport', prague, 2],
  ]) {
    const result = run(p, { goal: goal(from, to, max), proof: true });
    assert.deepEqual(result.answers.slice().sort(), routes(p, from, to, max));
    if (result.answers.length) {
      assert.equal(checkProof(p, result.proof, { allowTrusted: false }).valid, true);
      strictChecks++;
    }
  }
  assert.equal(run(p, { goal: goal(ostend, prague, 2) }).answers.length, 3);
  assert.deepEqual(run(p, { goal: goal(ostend, prague, -1) }).answers, []);
  assert.deepEqual(run(p, { goal: goal(ostend, prague, '1.5') }).answers, []);
  context.diagnostic(`Total duration includes one network parse, 8 queries with proof generation and automatic proof verification, 8 independent graph searches, ${strictChecks} additional strict C1-C5 checks, and 3 ordinary queries.`);
});

test('path discovery enumerates simple routes in a cyclic graph and handles arbitrary bounds', () => {
  const rules = source.slice(source.indexOf('% Find simple directed routes')).split('?-')[0];
  const p = Program.parse(`
    airport(a, 'A'). airport(b, 'B'). airport(c, 'C'). airport(d, 'D').
    flight(a, b). flight(b, a). flight(a, a). flight(b, c).
    flight(a, c). flight(c, d). flight(b, d).
    ${rules}
  `);
  for (const max of [0, 1, 2, 3, 10000]) {
    const result = run(p, { goal: goal('A', 'D', max), proof: true });
    assert.deepEqual(result.answers.slice().sort(), routes(p, 'A', 'D', max));
    if (result.answers.length) assert.equal(checkProof(p, result.proof, { allowTrusted: false }).valid, true);
  }
  assert.equal(run(p, { goal: goal('A', 'D', 2) }).answers.length, 3);
  assert.deepEqual(run(p, { goal: goal('D', 'A', 2) }).answers, []);
  assert.deepEqual(run(p, { goal: goal('A', 'A', 2) }).answers, []);
  assert.equal(run(p, { goal: "path_discovery(From, 'D', 0, Path)" }).answers.length, 2);
  assert.equal(run(p, { goal: "path_discovery('A', To, 0, Path)" }).answers.length, 2);
});
