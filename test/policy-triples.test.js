import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { run } from '../index.js';

// A policy written as triples should decide the outcome, not decorate it:
// deleting any one of its t/3 facts must change what the program concludes.
test('every policy triple of package-holiday affects its conclusions', () => {
  const lines = readFileSync(new URL('../examples/package-holiday.pl', import.meta.url), 'utf8').split('\n');
  const baseline = run(lines.join('\n')).stdout;
  const triples = lines.flatMap((line, i) => (/^t\('ex:.*\)\.$/.test(line) ? [i] : []));
  assert.equal(triples.length, 15);
  for (const i of triples) {
    const without = run(lines.filter((_, j) => j !== i).join('\n')).stdout;
    assert.notEqual(without, baseline, `removing has no effect: ${lines[i]}`);
  }
});
