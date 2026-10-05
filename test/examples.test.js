import test from './progress.js';
import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { run, checkProof, checkReportTerms } from '../index.js';
import { examplesRoot, manifest, parseExample, certifyExample } from '../tools/example-artifacts.js';

const root = fileURLToPath(new URL('..', import.meta.url));
const read = (path) => readFileSync(new URL(path, examplesRoot), 'utf8');
function cli(args) {
  // A deep derivation's certificate is tens of megabytes, well past the
  // default subprocess buffer.
  const result = spawnSync(process.execPath, ['bin/eyedia.js', ...args],
    { cwd: root, encoding: 'utf8', maxBuffer: 1 << 28 });
  if (result.error) throw result.error;
  assert.equal(result.stderr, '', result.stderr);
  return result;
}
// npm test runs the manifest test and then each example's tests in a process of
// their own, naming them in EYEDIA_EXAMPLE_TEST as manifest or NAME; without it,
// all run. test/run.js counts the exampleTest calls below to know how many
// tests an example has, so keep one per line.
const only = process.env.EYEDIA_EXAMPLE_TEST;
const selected = (id) => !only || only === id;
// Work several tests share is done by whichever needs it first, then reused.
const once = (make) => {
  let made = false, value;
  return () => { if (!made) { value = make(); made = true; } return value; };
};
if (selected('manifest')) test('example manifest covers every source, all three artifact directories and the decks', () => {
  const expected = manifest.map((entry) => `${entry.name}.pl`).sort();
  assert.deepEqual(readdirSync(examplesRoot).filter((file) => file.endsWith('.pl')).sort(), expected);
  for (const kind of ['output', 'proof', 'check']) {
    assert.deepEqual(readdirSync(new URL(`${kind}/`, examplesRoot)).sort(), expected);
  }
  const decks = manifest.map((entry) => `${entry.name}.md`).concat('README.md').sort();
  assert.deepEqual(readdirSync(new URL('deck/', examplesRoot)).sort(), decks);
});
const changed = (kind) => `${kind} changed; review before running npm run examples:update`;
for (const entry of [...manifest].sort((a, b) => a.name.localeCompare(b.name))) {
  const { name } = entry;
  const file = `examples/${name}.pl`;
  const exampleTest = (title, body) => { if (selected(name)) test(`${name}: ${title}`, body); };
  const program = once(() => parseExample(entry));
  const output = once(() => run(program()));
  const proved = once(() => certifyExample(entry, program(), output()));

  exampleTest('reasoning gives the saved output', () => assert.equal(output().stdout, read(`output/${name}.pl`), changed('output')));
  exampleTest('proving gives the saved certificate', () => assert.equal(proved().proof, read(`proof/${name}.pl`), changed('proof')));
  exampleTest('checking gives the saved report', () => assert.equal(checkReportTerms(proved().proofReport), read(`check/${name}.pl`), changed('check')));
  // The saved certificate was just shown to be the one this run generated, and
  // generating it checked it. Verifying the file on disk from scratch is the
  // --check-proof test below. What is left here is that the checker refuses a
  // document it has not justified.
  exampleTest('a tampered certificate is refused', () => {
    const tampered = read(`proof/${name}.pl`) + '\nunjustified_example_claim.\n';
    assert.equal(checkProof(program(), tampered).valid, false);
  });
  exampleTest('eyedia FILE', () => {
    const result = cli([file]);
    assert.equal(result.status, entry.haltCode ?? 0);
    assert.equal(result.stdout, read(`output/${name}.pl`));
  });
  exampleTest('eyedia --proof FILE', () => {
    const result = cli(['--proof', file]);
    assert.equal(result.status, entry.haltCode ?? 0);
    assert.equal(result.stdout, read(`proof/${name}.pl`));
  });
  exampleTest('eyedia --check-proof PROOF FILE', () => {
    const result = cli(['--check-proof', `examples/proof/${name}.pl`, file]);
    assert.equal(result.status, 0);
    assert.equal(result.stdout, read(`check/${name}.pl`));
  });
}
