import { mkdirSync, writeFileSync, existsSync, unlinkSync } from 'node:fs';
import { examplesRoot, manifest, evaluateExample } from './example-artifacts.js';

// Evaluate every example before writing any snapshots, so a reasoning failure
// does not leave a partially refreshed corpus.
const results = manifest.map((entry) => ({ entry, artifacts: evaluateExample(entry) }));
for (const directory of ['output', 'proof', 'check']) mkdirSync(new URL(`${directory}/`, examplesRoot), { recursive: true });
for (const { entry, artifacts } of results) {
  for (const kind of ['output', 'proof', 'check']) {
    writeFileSync(new URL(`${kind}/${entry.name}.pl`, examplesRoot), artifacts[kind]);
  }
  // Migrate only the registered generated report for this example.
  const obsolete = new URL(`check/${entry.name}.json`, examplesRoot);
  if (existsSync(obsolete)) unlinkSync(obsolete);
  console.log(`updated ${entry.name}: output, proof, check`);
}
