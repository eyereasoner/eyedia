import test from './progress.js';
import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { Program, checkProof } from '../index.js';
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
test('example manifest covers every source and all three artifact directories', () => {
  const expected = manifest.map((entry) => `${entry.name}.pl`).sort();
  assert.deepEqual(readdirSync(examplesRoot).filter((file) => file.endsWith('.pl')).sort(), expected);
  for (const kind of ['output', 'proof', 'check']) {
    assert.deepEqual(readdirSync(new URL(`${kind}/`, examplesRoot)).sort(), expected);
  }
});
for (const entry of manifest) {
  test(`example ${entry.name}: output, proof and check snapshots`, () => {
    const artifacts = evaluateExample(entry);
    for (const kind of ['output', 'proof', 'check']) {
      assert.equal(artifacts[kind], read(`${kind}/${entry.name}.pl`), `${kind} changed; review before running npm run examples:update`);
    }
    const program = Program.parse(read(`${entry.name}.pl`));
    const savedProof = read(`proof/${entry.name}.pl`);
    const report = checkProof(program, savedProof, { allowTrusted: entry.trusted.length > 0 });
    assert.equal(report.valid, true, JSON.stringify(report.failures));
    assert.equal(checkProof(program, savedProof + '\nunjustified_example_claim.\n').valid, false);
  });
  test(`example ${entry.name}: CLI output, proof and saved-proof checking`, () => {
    const file = `examples/${entry.name}.pl`;
    const output = cli([file]);
    assert.equal(output.status, entry.haltCode ?? 0);
    assert.equal(output.stdout, read(`output/${entry.name}.pl`));
    const proof = cli(['--proof', file]);
    assert.equal(proof.status, entry.haltCode ?? 0);
    assert.equal(proof.stdout, read(`proof/${entry.name}.pl`));
    const check = cli(['--check-proof', `examples/proof/${entry.name}.pl`, file]);
    assert.equal(check.status, 0);
    assert.equal(check.stdout, read(`check/${entry.name}.pl`));
  });
}
