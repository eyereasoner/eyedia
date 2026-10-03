// npm test: every test file, and every example test, as a separate process, a
// few at a time. The example corpus is nearly all of the work and its largest
// examples dominate it, so the jobs are handed out heaviest first, judged by
// source and certificate size, and each prints its output as one block when it
// finishes. EYEL_TEST_JOBS sets how many run at once; the default leaves a
// core free and allows about 1.25 GB per job, since the largest examples need
// that much while proving.
import { spawn } from 'node:child_process';
import { readdirSync, statSync } from 'node:fs';
import { availableParallelism, totalmem } from 'node:os';
import { fileURLToPath } from 'node:url';
import { manifest } from '../tools/example-artifacts.js';

const root = fileURLToPath(new URL('..', import.meta.url));
const size = (path) => statSync(new URL(`../${path}`, import.meta.url)).size;
const jobs = Number(process.env.EYEL_TEST_JOBS) ||
  Math.max(1, Math.min(availableParallelism() - 1, Math.floor(totalmem() / 1.25e9)));

// Weights are rough milliseconds: about one per kilobyte of an example's source
// and certificate, and a second for each other test file.
const work = readdirSync(new URL('.', import.meta.url))
  .filter((file) => file.endsWith('.test.js') && file !== 'examples.test.js')
  .map((file) => ({ label: file, file: `test/${file}`, weight: 1000 }));
work.push({ label: 'example manifest', file: 'test/examples.test.js', test: 'manifest', weight: 0 });
for (const { name } of manifest) {
  const weight = (size(`examples/${name}.pl`) + size(`examples/proof/${name}.pl`)) / 1000;
  for (const part of ['snapshot', 'cli']) {
    work.push({ label: `${name} ${part}`, file: 'test/examples.test.js', test: `${name}:${part}`, weight });
  }
}
work.sort((a, b) => b.weight - a.weight);

const totals = { tests: 0, pass: 0, fail: 0 };
const failed = [];
const started = performance.now();
let next = 0;
let done = 0;
const color = process.stdout.isTTY ? { FORCE_COLOR: '1' } : {};

function run(job) {
  return new Promise((resolve) => {
    const env = { ...process.env, ...color, EYEL_EXAMPLE_TEST: job.test ?? '' };
    if (!job.test) delete env.EYEL_EXAMPLE_TEST;
    const child = spawn(process.execPath, ['--test-reporter=spec', job.file], { cwd: root, env });
    let text = '';
    child.stdout.on('data', (chunk) => { text += chunk; });
    child.stderr.on('data', (chunk) => { text += chunk; });
    child.on('close', (code) => {
      const plain = text.replace(/\x1b\[[0-9;]*m/g, '');
      for (const key of Object.keys(totals)) totals[key] += Number(plain.match(new RegExp(`^ℹ ${key} (\\d+)`, 'm'))?.[1] ?? 0);
      if (code !== 0) failed.push(job.label);
      // The per-job summary is repeated in the totals below, so leave it out.
      const body = text.split('\n').filter((line) => !/^(\x1b\[[0-9;]*m)*ℹ /.test(line)).join('\n').trimEnd();
      process.stdout.write(`── ${job.label} (${++done}/${work.length}, ${((performance.now() - started) / 1000).toFixed(1)} s)\n${body}\n`);
      resolve();
    });
  });
}
async function worker() {
  while (next < work.length) await run(work[next++]);
}
process.stdout.write(`running ${work.length} jobs, ${jobs} at a time\n`);
await Promise.all(Array.from({ length: Math.min(jobs, work.length) }, worker));
process.stdout.write(`ℹ tests ${totals.tests}\nℹ pass ${totals.pass}\nℹ fail ${totals.fail}\n`);
process.stdout.write(`ℹ duration_ms ${(performance.now() - started).toFixed(0)}\n`);
if (failed.length) {
  process.stdout.write(`failed: ${failed.join(', ')}\n`);
  process.exitCode = 1;
}
