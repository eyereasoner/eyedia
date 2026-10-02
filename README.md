# eyel

A standalone, dependency-free **Prolog rule language** with forward and backward
reasoning and checkable proofs.

Eyel turns explicit facts and rules into conclusions whose derivations can be
inspected and checked. An answer can arrive together with a certificate, and
that certificate can be verified against the program that produced it.

Facts and rules use Prolog syntax:

```prolog
human(socrates).
mortal(X) :+ human(X).
```

`Head :+ Body` materializes conclusions until a fixpoint. `Head :- Body`
defines a predicate evaluated when called. The two compose: a forward body may
call backward definitions, and a backward goal may use facts that forward
reasoning established.

## Run it

Node.js 18 or newer. No install, no build step:

```sh
node bin/eyel.js examples/socrates.pl
node bin/eyel.js --proof examples/socrates.pl
node bin/eyel.js --proof examples/socrates.pl | node bin/eyel.js --check-proof - examples/socrates.pl
npm test
```

The executable becomes `eyel` when the package is installed. Run `eyel --help`
for the full command line.

Or in the browser: serve the checkout (`python3 -m http.server`) and open
[playground.html](playground.html) to edit, run and check any example.

## From JavaScript

```js
import { run, checkProof } from './index.js';

const source = 'human(socrates). mortal(X) :+ human(X).';
const result = run(source, { goal: 'mortal(X)', proof: true });
console.log(result.answers);                            // ['mortal(socrates)']
console.log(checkProof(source, result.proof).valid);    // true
```

## Read on

- **[Make reasoning something you can see](make-reasoning-something-you-can-see.md)** —
  what the language is for, how to write it, what a checked proof does and does
  not establish, and how the engine works.
- **[Examples](examples/README.md)** — 63 complete programs, each with its saved
  conclusions, proof and C1-C5 check report.
- **[src/builtins.js](src/builtins.js)** — the exact native predicate list.

## License

[MIT](LICENSE.md)
