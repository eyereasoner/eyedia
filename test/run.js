// npm test: the regression tests, then the example corpus. Each regression test
// file runs in its own process, a few at a time; the examples run one after
// another in name order, each in its own process. Every test is reported on a
// line of its own as soon as it finishes, numbered across the whole run and in
// name order: the results of a file that finishes early wait for the files
// before it. EYEDIA_TEST_JOBS sets how many regression files run at once; the
// default leaves a core free.
import { spawn } from 'node:child_process';
import { readdirSync, readFileSync } from 'node:fs';
import { availableParallelism } from 'node:os';
import { fileURLToPath } from 'node:url';
import { manifest } from '../tools/example-artifacts.js';

const root = fileURLToPath(new URL('..', import.meta.url));
const jobs = Number(process.env.EYEDIA_TEST_JOBS) || Math.max(1, availableParallelism() - 1);
const count = (file, pattern) => (readFileSync(new URL(file, import.meta.url), 'utf8').match(pattern) ?? []).length;

// Every regression test is a top-level test(...) call and every example test an
// exampleTest(...) call, so counting those gives the total before anything runs.
const files = readdirSync(new URL('.', import.meta.url))
  .filter((file) => file.endsWith('.test.js') && file !== 'examples.test.js').sort();
const regression = files.map((file) => ({
  label: `${file.replace(/\.test\.js$/, '')}: `, file: `test/${file}`, tests: count(file, /^test\(/gm),
}));
const perExample = count('examples.test.js', /^\s*exampleTest\(/gm);
const examples = [{ label: '', file: 'test/examples.test.js', test: 'manifest', tests: 1 }];
for (const { name } of [...manifest].sort((a, b) => a.name.localeCompare(b.name))) {
  examples.push({ label: '', file: 'test/examples.test.js', test: name, tests: perExample });
}
const groups = [
  { title: `regression tests: ${files.length} files`, jobs: regression, parallel: jobs },
  { title: `examples: ${manifest.length} programs`, jobs: examples, parallel: 1 },
];
const total = groups.reduce((sum, group) => sum + group.jobs.reduce((n, job) => n + job.tests, 0), 0);
const width = String(total).length;

// A passing mark is green, a failing one red and a summary line yellow, on a
// terminal that shows color. ✓, ✗ and ● have no emoji form, so unlike ✔, ✖ and
// ℹ no terminal draws them from a color emoji font that ignores the color.
const colors = process.stdout.hasColors?.() ?? false;
const paint = (code, mark) => (colors ? `\x1b[${code}m${mark}\x1b[0m` : mark);
const marks = { '✔': paint('1;92', '✓'), '✖': paint('1;91', '✗'), 'ℹ': paint('1;93', '●') };
const DIFF_LINES = 12;

const totals = { tests: 0, pass: 0, fail: 0 };
const failed = [];
const started = performance.now();
let reported = 0;

// Print a test result line from a job's output as one numbered line.
function report(job, line) {
  const result = line.slice(2).replace(/ \(([\d.]+)ms\)$/, (_, ms) => `  ${Math.round(Number(ms))} ms`);
  process.stdout.write(`[${String(++reported).padStart(width)}/${total}] ${marks[line[0]]} ${job.label}${result}\n`);
}
// Run a job, handing each of its result lines to show as soon as it arrives.
function run(job, show) {
  return new Promise((resolve) => {
    const env = { ...process.env, EYEDIA_EXAMPLE_TEST: job.test ?? '' };
    if (!job.test) delete env.EYEDIA_EXAMPLE_TEST;
    delete env.FORCE_COLOR;
    const child = spawn(process.execPath, ['--test-reporter=spec', job.file], { cwd: root, env });
    let text = '';
    let pending = '';
    let summary = false;
    const take = (chunk) => {
      text += chunk;
      pending += chunk;
      const lines = pending.split('\n');
      pending = lines.pop();
      for (const raw of lines) {
        const line = raw.replace(/\x1b\[[0-9;]*m/g, '');
        // The reporter repeats failures in a closing summary; they are counted once.
        if (line === '✖ failing tests:') summary = true;
        if (!summary && /^[✔✖] /.test(line)) show(line);
      }
    };
    child.stdout.setEncoding('utf8').on('data', take);
    child.stderr.setEncoding('utf8').on('data', take);
    child.on('close', (code) => {
      text = text.replace(/\x1b\[[0-9;]*m/g, '');
      for (const key of Object.keys(totals)) totals[key] += Number(text.match(new RegExp(`^ℹ ${key} (\\d+)`, 'm'))?.[1] ?? 0);
      if (code !== 0) failed.push({ job, text });
      resolve();
    });
  });
}
// The part of a failed job's output that explains it: each failing test with
// its message, a diff cut to DIFF_LINES lines and the stack frames in this
// repository. Progress lines, passing tests, counters, Node's internal frames
// and the error's own properties, which repeat the diff, are left out.
function explain(text) {
  const start = text.indexOf('✖ failing tests:');
  // Without a closing summary the process died before reporting: show it all.
  if (start < 0) return text.trimEnd();
  const out = [];
  let skipping = false;
  let diff = 0;
  for (const raw of text.slice(start).split('\n').slice(1)) {
    if (skipping) { if (raw === '  }') skipping = false; continue; }
    let line = raw;
    if (line.endsWith(' {') && /^\s+at /.test(line)) { skipping = true; line = line.slice(0, -2); }
    const diffLine = /^ {2}[+-] /.test(line) || (diff > 0 && /^ {2}[+-] {3}/.test(line));
    if (!diffLine && diff > DIFF_LINES) out.push(paint('2', `  … ${diff - DIFF_LINES} more diff lines`));
    diff = diffLine ? diff + 1 : 0;
    if (diffLine && diff > DIFF_LINES) continue;
    if (/^test at /.test(line) || /^\s+at .*(node:internal|test\/progress\.js)/.test(line)) continue;
    if (/^✖ /.test(line)) out.push(`${marks['✖']} ${paint('1', line.slice(2).replace(/ \(([\d.]+)ms\)$/, (_, ms) => `  ${Math.round(Number(ms))} ms`))}`);
    else if (/^\s+at /.test(line)) out.push(paint('2', line));
    else if (/^ {2}\+ /.test(line) && !/^ {2}\+ actual - expected$/.test(line)) out.push(paint('32', line));
    else if (/^ {2}- /.test(line)) out.push(paint('31', line));
    else out.push(line);
  }
  return out.join('\n').replace(/\n{3,}/g, '\n\n').trim();
}

for (const group of groups) {
  const tests = group.jobs.reduce((n, job) => n + job.tests, 0);
  process.stdout.write(`\n── ${group.title}, ${tests} tests ${'─'.repeat(Math.max(3, 60 - group.title.length))}\n`);
  // The first unfinished job in name order prints its results live; a later
  // job holds its results until every job before it has finished.
  const held = group.jobs.map(() => []);
  const finished = group.jobs.map(() => false);
  let head = 0;
  const advance = () => {
    while (head < group.jobs.length && finished[head]) {
      head++;
      if (head < group.jobs.length) for (const line of held[head].splice(0)) report(group.jobs[head], line);
    }
  };
  const queue = group.jobs.map((job, index) => ({ job, index }));
  await Promise.all(Array.from({ length: Math.min(group.parallel, queue.length) }, async () => {
    while (queue.length) {
      const { job, index } = queue.shift();
      await run(job, (line) => (index === head ? report(job, line) : held[index].push(line)));
      finished[index] = true;
      advance();
    }
  }));
}
for (const { job, text } of failed) {
  process.stdout.write(`\n${paint('1;91', `── failed: ${job.test ?? job.file} ${'─'.repeat(40)}`)}\n${explain(text)}\n`);
}
const info = marks['ℹ'];
process.stdout.write(`\n${info} tests ${totals.tests}\n${info} pass ${totals.pass}\n${info} fail ${totals.fail}\n`);
process.stdout.write(`${info} duration_ms ${(performance.now() - started).toFixed(0)}\n`);
if (failed.length) process.exitCode = 1;
