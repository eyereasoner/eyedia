import test, { phase } from './progress.js';
import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { checkProof } from '../index.js';
import { examplesRoot, manifest, evaluateExample } from '../tools/example-artifacts.js';

const root = fileURLToPath(new URL('..', import.meta.url));
const read = (path) => readFileSync(new URL(path, examplesRoot), 'utf8');
function cli(args) {
  // A deep derivation's certificate is tens of megabytes, well past the
  // default subprocess buffer.
  const result = spawnSync(process.execPath, ['bin/eyel.js', ...args],
    { cwd: root, encoding: 'utf8', maxBuffer: 1 << 28 });
  if (result.error) throw result.error;
  assert.equal(result.stderr, '', result.stderr);
  return result;
}
// npm test runs each of these tests in its own process, naming it in
// EYEL_EXAMPLE_TEST as manifest, NAME:snapshot or NAME:cli; without it, all run.
const only = process.env.EYEL_EXAMPLE_TEST;
const selected = (id) => !only || only === id;
if (selected('manifest')) test('example manifest covers every source and all three artifact directories', () => {
  const expected = manifest.map((entry) => `${entry.name}.pl`).sort();
  assert.deepEqual(readdirSync(examplesRoot).filter((file) => file.endsWith('.pl')).sort(), expected);
  for (const kind of ['output', 'proof', 'check']) {
    assert.deepEqual(readdirSync(new URL(`${kind}/`, examplesRoot)).sort(), expected);
  }
});
for (const entry of manifest) {
  if (selected(`${entry.name}:snapshot`)) test(`example ${entry.name}: output, proof and check snapshots`, () => {
    const artifacts = evaluateExample(entry, phase);
    phase('compare saved artifacts', () => {
      for (const kind of ['output', 'proof', 'check']) {
        assert.equal(artifacts[kind], read(`${kind}/${entry.name}.pl`), `${kind} changed; review before running npm run examples:update`);
      }
    });
    // The saved certificate was just shown to be the one this run generated,
    // and generating it checked it. Verifying the file on disk from scratch is
    // the CLI test below. What is left to establish here is that the checker
    // refuses a document it has not justified.
    phase('refuse a tampered certificate', () => {
      const tampered = read(`proof/${entry.name}.pl`) + '\nunjustified_example_claim.\n';
      assert.equal(checkProof(artifacts.program, tampered).valid, false);
    });
  });
  if (selected(`${entry.name}:cli`)) test(`example ${entry.name}: CLI output, proof and saved-proof checking`, () => {
    const file = `examples/${entry.name}.pl`;
    phase('eyel FILE', () => {
      const output = cli([file]);
      assert.equal(output.status, entry.haltCode ?? 0);
      assert.equal(output.stdout, read(`output/${entry.name}.pl`));
    });
    phase('eyel --proof FILE', () => {
      const proof = cli(['--proof', file]);
      assert.equal(proof.status, entry.haltCode ?? 0);
      assert.equal(proof.stdout, read(`proof/${entry.name}.pl`));
    });
    phase('eyel --check-proof PROOF FILE', () => {
      const check = cli(['--check-proof', `examples/proof/${entry.name}.pl`, file]);
      assert.equal(check.status, 0);
      assert.equal(check.stdout, read(`check/${entry.name}.pl`));
    });
  });
}
