import { readFileSync } from 'node:fs';
import { run, checkProof, checkReportTerms } from '../index.js';

export const examplesRoot = new URL('../examples/', import.meta.url);
export const manifest = JSON.parse(readFileSync(new URL('manifest.json', examplesRoot), 'utf8'));
if (!Array.isArray(manifest) || !manifest.length) throw new Error('the example manifest must be a nonempty array');
const names = new Set();
for (const entry of manifest) {
  if (!/^[a-z][a-z0-9-]*$/.test(entry.name) || names.has(entry.name) ||
      typeof entry.description !== 'string' || !Array.isArray(entry.trusted)) {
    throw new Error(`invalid example manifest entry: ${JSON.stringify(entry)}`);
  }
  names.add(entry.name);
}

export function evaluateExample(entry) {
  const source = readFileSync(new URL(`${entry.name}.pl`, examplesRoot), 'utf8');
  const output = run(source);
  const proved = run(source, { proof: true });
  const report = checkProof(source, proved.proof);
  if (!report.valid || !report.steps || !report.claims) throw new Error(`${entry.name}: no valid nonempty proof`);
  if (output.haltCode !== (entry.haltCode ?? null) || proved.haltCode !== output.haltCode) {
    throw new Error(`${entry.name}: unexpected halt code`);
  }
  if (JSON.stringify(output.answers) !== JSON.stringify(proved.answers)) throw new Error(`${entry.name}: proof changed the answers`);
  const trusted = [...new Set(report.trusted.map((boundary) => boundary.kind))].sort();
  if (JSON.stringify(trusted) !== JSON.stringify([...entry.trusted].sort())) throw new Error(`${entry.name}: unexpected proof obligations`);
  return {
    output: output.stdout,
    proof: proved.proof,
    check: checkReportTerms(report),
  };
}
