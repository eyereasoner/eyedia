#!/usr/bin/env node
import module from 'node:module';
import { readFile } from 'node:fs/promises';

// Reuse V8's compilation of the engine between runs. The engine is imported
// only after the cache is enabled; a static import would already have been
// compiled by then. enableCompileCache is Node 22.1+, so the call is optional
// for the Node 18 floor, and an unusable cache directory just leaves startup
// as it was.
module.enableCompileCache?.();

// A reader that stops early, as in `eyeris --proof p.pl | head`, is a normal end
// for a command line rather than a crash.
process.stdout.on('error', (error) => {
  if (error?.code === 'EPIPE') process.exit(0);
  throw error;
});

const { run, checkProof, checkReportTerms } = await import('../index.js');

const help = `Usage: eyeris [--proof | --check-proof FILE] [--goal GOAL] [FILE ...]
Facts and rules use Prolog syntax; :+ rules run to a fixpoint.
  --proof             Print claims and clause/3, step/4 proof records
  --check-proof FILE  Print a Prolog C1-C7 check report (- for stdin)
  --json              Print the check report as JSON instead
  --goal GOAL         Ask a backward goal after forward reasoning; with
                      --check-proof, the goal the proof answers
  --strict-proof      Reject proofs relying on absence or collection
  --stats             Print reasoning statistics to stderr
  --max-depth N       Bound backward recursion (default 1000000)
  --max-iterations N  Bound forward rounds per stratum (default 1000)
  --max-inferences N  Bound reasoning work (default 1000000)
  --help              Print this help
Source defaults to stdin; multiple files form one program.
`;
async function stdin() {
  const chunks = [];
  for await (const chunk of process.stdin) chunks.push(chunk);
  return Buffer.concat(chunks).toString('utf8');
}
try {
  const args = process.argv.slice(2);
  const files = [];
  const options = {};
  let proofFile;
  let stats = false;
  let strict = false;
  let json = false;
  let printedHelp = false;
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--help' || arg === '-h') { process.stdout.write(help); printedHelp = true; break; }
    if (arg === '--proof' || arg === '-p') options.proof = true;
    else if (arg === '--stats') stats = true;
    else if (arg === '--strict-proof') strict = true;
    else if (arg === '--json') json = true;
    else if (['--check-proof', '--goal', '--max-depth', '--max-iterations', '--max-inferences'].includes(arg)) {
      const value = args[++i];
      if (value == null) throw new Error(`${arg} needs a value`);
      if (arg === '--check-proof') proofFile = value;
      else if (arg === '--goal') (options.goals ??= []).push(value);
      else {
        const n = Number(value);
        if (!Number.isSafeInteger(n) || n < 1) throw new Error(`${arg} needs a positive integer`);
        options[{'--max-depth':'maxDepth', '--max-iterations':'maxIterations', '--max-inferences':'maxInferences'}[arg]] = n;
      }
    } else if (arg.startsWith('-') && arg !== '-') throw new Error(`unknown option ${arg}`);
    else files.push(arg);
  }
  if (!printedHelp) {
    if (json && proofFile == null) throw new Error('--json requires --check-proof');
    if (proofFile != null && options.proof) throw new Error('--check-proof cannot be combined with --proof');
    if (proofFile === '-' && (!files.length || files.includes('-'))) throw new Error('stdin holds the proof; name the program as files');
    if (!files.length) files.push('-');
    if (files.filter((file) => file === '-').length > 1) throw new Error('stdin can only be read once');
    const sources = [];
    for (const file of files) sources.push(file === '-' ? await stdin() : await readFile(file, 'utf8'));
    const source = sources.join('\n');
    if (proofFile != null) {
      const document = proofFile === '-' ? await stdin() : await readFile(proofFile, 'utf8');
      const report = checkProof(source, document, { allowTrusted: !strict, goals: options.goals });
      process.stdout.write(json ? JSON.stringify(report, null, 2) + '\n' : checkReportTerms(report));
      process.exitCode = report.valid ? 0 : 1;
    } else {
      const result = run(source, options);
      process.stdout.write(result.stdout);
      if (stats) process.stderr.write(JSON.stringify(result.stats) + '\n');
      process.exitCode = result.haltCode ?? 0;
    }
  }
} catch (error) {
  process.stderr.write(`eyeris: ${error.message}\n`);
  process.exitCode = 1;
}
