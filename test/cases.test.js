import test from 'node:test';
import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import { run } from '../index.js';

// examples/cases/NAME.pl holds outcomes expected from the sources behind
// examples/NAME.pl. Run together, every expected case must pass.
test('every expected case in examples/cases passes against its example', () => {
  const cases = new URL('../examples/cases/', import.meta.url);
  const files = readdirSync(cases).filter((file) => file.endsWith('.pl'));
  assert.ok(files.length > 0);
  for (const file of files) {
    const expectations = readFileSync(new URL(file, cases), 'utf8');
    const program = readFileSync(new URL(`../examples/${file}`, import.meta.url), 'utf8');
    const { answers } = run(`${program}\n${expectations}`);
    const expected = (expectations.match(/^expected\w*\(/gm) ?? []).length;
    assert.equal(answers.length, expected, `${file}: one result per expected case`);
    for (const answer of answers) assert.match(answer, /, pass\)$/, `${file}: ${answer}`);
  }
});
