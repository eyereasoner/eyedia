import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { run } from '../index.js';

// A policy written as triples should decide the outcome, not decorate it:
// deleting any one of its ground t/3 facts must change what the program concludes.
function everyTripleMatters(name, count) {
  const lines = readFileSync(new URL(`../examples/${name}.pl`, import.meta.url), 'utf8').split('\n');
  const baseline = run(lines.join('\n')).stdout;
  const triples = lines.flatMap((line, i) => (/^t\('ex:.*\)\.$/.test(line) ? [i] : []));
  assert.equal(triples.length, count);
  for (const i of triples) {
    const without = run(lines.filter((_, j) => j !== i).join('\n')).stdout;
    assert.notEqual(without, baseline, `removing has no effect: ${lines[i]}`);
  }
}

test('every policy triple of package-holiday affects its conclusions', () => everyTripleMatters('package-holiday', 15));
test('every policy triple of research-portal affects its conclusions', () => everyTripleMatters('research-portal', 26));
