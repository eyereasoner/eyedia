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
