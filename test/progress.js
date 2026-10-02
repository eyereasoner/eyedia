import nodeTest from 'node:test';

let registered = 0;
let started = 0;

// Print before entering the test body: synchronous CLI work must not hide the
// currently running test until the default reporter can process its result.
export default function test(name, body) {
  registered++;
  return nodeTest(name, async (context) => {
    // A real event-loop turn lets completed results reach the reporter before
    // another synchronous test starts; resolved promises alone do not do that.
    await new Promise((resolve) => setImmediate(resolve));
    process.stdout.write(`[${++started}/${registered}] ${name}\n`);
    await body(context);
  });
}

// Report the stages of a long test while it runs. The label is written before
// the work starts and the duration when it finishes, so whatever a slow test is
// currently doing is on screen rather than only visible once it is over.
export function phase(label, work) {
  process.stdout.write(`         ${label.padEnd(32)}`);
  const started = performance.now();
  try {
    return work();
  } finally {
    process.stdout.write(`${(performance.now() - started).toFixed(0).padStart(7)} ms\n`);
  }
}
