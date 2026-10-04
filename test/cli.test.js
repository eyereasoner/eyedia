import test from './progress.js';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('..', import.meta.url));
const cli = (args = [], input) => {
  const result = spawnSync(process.execPath, ['bin/eyedia.js', ...args], { cwd: root, input, encoding: 'utf8' });
  if (result.error) throw result.error;
  return result;
};
test('CLI runs files, stdin, multiple sources and goals', () => {
  assert.equal(cli(['examples/socrates.pl']).stdout, 'type(socrates, mortal).\ntype(socrates, human).\n');
  assert.equal(cli([], 'p(a). q(X) :+ p(X).').stdout, 'q(a).\n');
  assert.equal(cli(['examples/socrates.pl', '-', '--goal', 'type(X, mortal)'], 'type(plato, human).').stdout,
    'type(socrates, mortal).\ntype(plato, mortal).\n');
});
test('proof generation pipes into proof checking', () => {
  const generated = cli(['--proof', 'examples/socrates.pl']);
  assert.equal(generated.status, 0, generated.stderr);
  const checked = cli(['--check-proof', '-', 'examples/socrates.pl'], generated.stdout);
  assert.equal(checked.status, 0, checked.stderr);
  assert.match(checked.stdout, /condition\('C1', resolution, ok, 3\)\./);
  assert.match(checked.stdout, /verdict\(checked\)\./);
  const json = cli(['--json', '--check-proof', '-', 'examples/socrates.pl'], generated.stdout);
  assert.equal(json.status, 0);
  assert.equal(JSON.parse(json.stdout).valid, true);
  assert.equal(JSON.parse(json.stdout).conditions.length, 7);
  assert.equal(cli(['--check-proof', '-', 'examples/socrates.pl'], generated.stdout + 'bogus.').status, 1);
});
test('a proof document given as a program says how to check it instead', () => {
  const ran = cli(['examples/proof/socrates.pl']);
  assert.equal(ran.status, 1);
  assert.match(ran.stderr, /this is a proof document, not a program: check it with --check-proof PROOF PROGRAM/);
  assert.match(cli([], 'clause(a, b, c).').stderr, /unsupported or reserved head clause\(a, b, c\)/);
});
test('CLI reports help, errors, stats and fuse exit codes', () => {
  assert.match(cli(['--help']).stdout, /Usage: eyedia/);
  assert.equal(cli(['--unknown']).status, 1);
  assert.equal(cli(['--max-depth', '0']).status, 1);
  assert.equal(cli(['--check-proof', '-'], '').status, 1);
  assert.equal(cli([], 'p. false :+ p.').status, 65);
  const result = cli(['--stats', 'examples/socrates.pl']);
  assert.equal(JSON.parse(result.stderr).derived, 1);
});
test('failed and strict proof checks print Prolog verdicts and exit unsuccessfully', () => {
  const failed = cli(['--check-proof', '-', '--goal', 'is(7, 2+3)', 'examples/socrates.pl'],
    'is(7,+(2,3)). step(is(7,+(2,3)),builtin,[],[]).');
  assert.equal(failed.status, 1);
  assert.equal(failed.stderr, '');
  assert.match(failed.stdout, /condition\('C5', re_decision, failed\(1\), 0\)\./);
  assert.match(failed.stdout, /failure\('C5', is\(7, \+\(2, 3\)\),/);
  assert.match(failed.stdout, /verdict\(failed\(1\)\)\./);
  const strict = cli(['--strict-proof', '--check-proof', 'examples/proof/permissions.pl', 'examples/permissions.pl']);
  assert.equal(strict.status, 1);
  assert.match(strict.stdout, /obligation\(absent, theory_scoped,/);
  assert.match(strict.stdout, /verdict\(failed\(/);
  assert.equal(cli(['--json', 'examples/socrates.pl']).status, 1);
});
