// npm test: the regression tests, then the example corpus, each test file and
// each example test in its own process, a few at a time. Within a group the
// jobs are handed out heaviest first, judged by source and certificate size,
// and every test is reported as it completes, numbered across the whole run,
// with the stages of a long test indented beneath it. EYERIS_TEST_JOBS sets how
// many run at once; the default leaves a core free and allows about 1.25 GB
// per job, since the largest examples need that much while proving.
import { spawn } from 'node:child_process';
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { availableParallelism, totalmem } from 'node:os';
import { fileURLToPath } from 'node:url';
import { manifest } from '../tools/example-artifacts.js';

const root = fileURLToPath(new URL('..', import.meta.url));
const size = (path) => statSync(new URL(`../${path}`, import.meta.url)).size;
const jobs = Number(process.env.EYERIS_TEST_JOBS) ||
  Math.max(1, Math.min(availableParallelism() - 1, Math.floor(totalmem() / 1.25e9)));

// Every regression test is a top-level test(...) call, so counting those gives
// the total before anything runs.
const files = readdirSync(new URL('.', import.meta.url))
  .filter((file) => file.endsWith('.test.js') && file !== 'examples.test.js').sort();
const regression = files.map((file) => ({
  label: file.replace(/\.test\.js$/, ''), file: `test/${file}`, weight: 1,
  tests: (readFileSync(new URL(file, import.meta.url), 'utf8').match(/^test\(/gm) ?? []).length,
}));
const examples = [{ label: 'manifest', file: 'test/examples.test.js', test: 'manifest', weight: 0, tests: 1 }];
for (const { name } of manifest) {
  const weight = size(`examples/${name}.pl`) + size(`examples/proof/${name}.pl`);
  for (const part of ['snapshot', 'cli']) {
    examples.push({ label: name, file: 'test/examples.test.js', test: `${name}:${part}`, weight, tests: 1 });
  }
}
const groups = [
  { title: `regression tests: ${files.length} files`, jobs: regression },
  { title: `examples: ${manifest.length} programs`, jobs: examples },
];
const total = groups.reduce((sum, group) => sum + group.jobs.reduce((n, job) => n + job.tests, 0), 0);
const width = String(total).length;

// A passing mark is green, a failing one red and a summary line yellow, on a
// terminal that shows color. ✓, ✗ and ● have no emoji form, so unlike ✔, ✖ and
// ℹ no terminal draws them from a color emoji font that ignores the color.
const colors = process.stdout.hasColors?.() ?? false;
const paint = (code, mark) => (colors ? `\x1b[${code}m${mark}\x1b[0m` : mark);
const marks = { '✔': paint('1;92', '✓'), '✖': paint('1;91', '✗'), 'ℹ': paint('1;93', '●') };

const totals = { tests: 0, pass: 0, fail: 0 };
const failed = [];
const started = performance.now();
let reported = 0;

// A test's result line comes after the stages it printed while running; report
// the result first, numbered, with those stages beneath it.
function report(job, text) {
  let stages = [];
  for (const line of text.split('\n')) {
    // The reporter repeats failures in a closing summary; they are counted once.
    if (line === '✖ failing tests:') break;
    if (/^\[\d+\/\d+\] /.test(line)) stages = [];
    else if (/^ {9}\S/.test(line)) stages.push(line);
    else if (/^[✔✖] /.test(line)) {
      const label = job.file.endsWith('examples.test.js') ? '' : `${job.label}: `;
      const result = line.slice(2).replace(/ \(([\d.]+)ms\)$/, (_, ms) => `  ${Math.round(Number(ms))} ms`);
      process.stdout.write(`[${String(++reported).padStart(width)}/${total}] ${marks[line[0]]} ${label}${result}\n`);
      for (const stage of stages) process.stdout.write(`${' '.repeat(2 * width + 7)}${stage.trimStart()}\n`);
      stages = [];
    }
  }
}
function run(job) {
  return new Promise((resolve) => {
    const env = { ...process.env, EYERIS_EXAMPLE_TEST: job.test ?? '' };
    if (!job.test) delete env.EYERIS_EXAMPLE_TEST;
    delete env.FORCE_COLOR;
    const child = spawn(process.execPath, ['--test-reporter=spec', job.file], { cwd: root, env });
    let text = '';
    child.stdout.on('data', (chunk) => { text += chunk; });
    child.stderr.on('data', (chunk) => { text += chunk; });
    child.on('close', (code) => {
      text = text.replace(/\x1b\[[0-9;]*m/g, '');
      for (const key of Object.keys(totals)) totals[key] += Number(text.match(new RegExp(`^ℹ ${key} (\\d+)`, 'm'))?.[1] ?? 0);
      report(job, text);
      if (code !== 0) failed.push({ job, text });
      resolve();
    });
  });
}
for (const group of groups) {
  const count = group.jobs.reduce((n, job) => n + job.tests, 0);
  process.stdout.write(`\n── ${group.title}, ${count} tests ${'─'.repeat(Math.max(3, 60 - group.title.length))}\n`);
  const queue = group.jobs.slice().sort((a, b) => b.weight - a.weight);
  await Promise.all(Array.from({ length: Math.min(jobs, queue.length) }, async () => {
    while (queue.length) await run(queue.shift());
  }));
}
for (const { job, text } of failed) {
  process.stdout.write(`\n── failed: ${job.test ?? job.file} ${'─'.repeat(40)}\n${text.trimEnd()}\n`);
}
const info = marks['ℹ'];
process.stdout.write(`\n${info} tests ${totals.tests}\n${info} pass ${totals.pass}\n${info} fail ${totals.fail}\n`);
process.stdout.write(`${info} duration_ms ${(performance.now() - started).toFixed(0)}\n`);
if (failed.length) process.exitCode = 1;
