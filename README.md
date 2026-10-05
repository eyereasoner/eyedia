# eyedia

[![npm version](https://img.shields.io/npm/v/eyedia.svg)](https://www.npmjs.com/package/eyedia)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.23144792-blue.svg)](https://doi.org/10.5281/zenodo.23144792)

![EYE](https://josd.github.io/images/eye.png)

*Eyedia — reasoning you can see.*

A standalone, dependency-free **Prolog rule language** with forward and backward
reasoning and checkable proofs.

Eyedia turns explicit facts and rules into conclusions whose derivations can be
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

## The thread

Eyedia is built around one idea: **reasoning you can see**. You write facts and
rules; Eyedia draws conclusions, forward until nothing new follows and backward
on request, and every answer can come with a proof. A separate checker verifies
that proof against the program, independently of the reasoner, and does more
than a classic proof checker:

- **The derivation:** every step is an instance of a program clause (C1),
  nothing is circular (C2), and every claim and every use is justified (C4).
- **The form (C3):** every step has exactly one justification of an allowed
  kind, in the right shape, so the report shows at once whether a proof fails
  on form or on content.
- **Recomputation (C5):** built-in calculations are redone rather than trusted.
- **Honesty about absence:** "there is nothing that …" and "these are *all* the
  answers" cannot be proved; they become explicit obligations, which the
  checker tries to refute with the evidence at hand (C6).
- **The right question (C7):** the proof answers the question asked and
  contains nothing beside it.

The report is itself Prolog, and every generated proof is checked before it is
returned. Around that core, [59 examples](https://eyereasoner.github.io/eyedia/examples/)
grew, from Socrates and the zebra puzzle to EU rules such as the Digital Omnibus
proposal and the Package Travel Directive, each with a [deck](https://eyereasoner.github.io/eyedia/examples/deck/)
for a wide audience and a [playground](https://eyereasoner.github.io/eyedia/playground/) in the browser.

A proof guarantees that the conclusions follow from the rules, not that the
rules say what the law or the policy says. So `eyedia --unused` shows which
parts of a translation make no difference to the conclusions, and an expert
knows [where to look](https://eyereasoner.github.io/eyedia/make-reasoning-something-you-can-see#checking-the-translation-not-just-the-reasoning).

## Run it

Node.js 18 or newer. No install, no build step:

```sh
node bin/eyedia.js examples/socrates.pl
node bin/eyedia.js --proof examples/socrates.pl
node bin/eyedia.js --proof examples/socrates.pl | node bin/eyedia.js --check-proof - examples/socrates.pl
npm test
```

The executable becomes `eyedia` when the package is installed. Run `eyedia --help`
for the full command line.

Or in the browser: the [playground](https://eyereasoner.github.io/eyedia/playground/) edits, runs and checks any
example. To run it from a checkout, serve it (`python3 -m http.server`) and open
`/playground/`.

## From JavaScript

```js
import { run, checkProof } from './index.js';

const source = 'human(socrates). mortal(X) :+ human(X).';
const result = run(source, { goal: 'mortal(X)', proof: true });
console.log(result.answers);                            // ['mortal(socrates)']
console.log(checkProof(source, result.proof).valid);    // true
```

## Read on

- **[Make reasoning something you can see](https://eyereasoner.github.io/eyedia/make-reasoning-something-you-can-see)** —
  what the language is for, how to write it, what a checked proof does and does
  not establish, and how the engine works.
- **[Examples](https://eyereasoner.github.io/eyedia/examples/)** — 59 complete programs, each with its saved
  conclusions, proof and C1-C7 check report.
- **[Example decks](https://eyereasoner.github.io/eyedia/examples/deck/)** — a short card deck for every
  example, explaining it for a wide audience: the question, what Eyedia
  concludes, why, and what the proof checker confirms.
- **[Playground](https://eyereasoner.github.io/eyedia/playground/)** — write a program in the browser, run it, check
  its proof, and share a link to exactly what you see.

## License

[MIT](https://eyereasoner.github.io/eyedia/LICENSE.md)
