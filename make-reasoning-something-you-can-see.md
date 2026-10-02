# Make reasoning something you can see

There is a particular satisfaction in understanding *why* something is true.
You can follow the steps. You can point at the assumptions. You can change one
fact and watch what follows. The conclusion stops being something you have to
take on trust and becomes something you can work with: explain to a colleague,
challenge, correct, build on.

Most software does not work that way. A program computes an answer and the
reasoning evaporates. If you want to know why the answer came out as it did,
you read the code, or you add logging, or you ask the person who wrote it.

Eyel is a small rule language built on a different bargain: **an answer can
arrive together with the reasoning that supports it, in a form another program
can check.**

---

## Contents

- [The idea in two lines](#the-idea-in-two-lines)
- [Why this matters](#why-this-matters)
- [Two directions of reasoning](#two-directions-of-reasoning)
- [What you can say](#what-you-can-say)
- [Proofs, and what checking one means](#proofs-and-what-checking-one-means)
- [Where it is honest about not knowing](#where-it-is-honest-about-not-knowing)
- [The examples](#the-examples)
- [Using it from JavaScript](#using-it-from-javascript)
- [How it works inside](#how-it-works-inside)
- [What is deliberately absent](#what-is-deliberately-absent)
- [Start with a question](#start-with-a-question)

---

## The idea in two lines

```prolog
human(socrates).
mortal(X) :+ human(X).
```

A fact and a rule. Eyel concludes `mortal(socrates)`. Ask for the reasoning and
you get a document that names the fact it used, the rule it applied, and the
substitution that connects them:

```prolog
mortal(socrates).

clause(1, human(socrates), true).
clause(2, mortal(var('X')), human(var('X'))).

step(mortal(socrates), rule(2), [=('X', socrates)], [human(socrates)]).
step(human(socrates), fact(1), [], []).
```

That document is itself ordinary Prolog text, written so that it parses back
without any operator declaration or flag. You can read it, store it, send
it to someone else, and — this is the part that matters — hand it to a checker
that re-establishes every step against the program it came from. Save those two
lines and try it:

```sh
printf 'human(socrates).\nmortal(X) :+ human(X).\n' > socrates.pl
node bin/eyel.js --proof socrates.pl | node bin/eyel.js --check-proof - socrates.pl
```

The checker prints a report ending in `verdict(checked).`

You can understand the whole language before you finish a cup of coffee, and
the certificate for a hundred-thousand-step derivation works exactly the same
way as the one above.

## Why this matters

Writing rules down is already valuable before anything is derived. Writing a
rule forces you to decide what you mean. Writing a fact forces you to say what
you actually know. Writing a query forces you to state what you want to learn.
A program becomes a place where a team's understanding takes a precise,
inspectable form instead of living in prose, spreadsheets and habit.

The questions that suit this are the ordinary ones. Which records satisfy a
policy? Which concepts roll up into a reporting category? Which events produced
this balance? Which route connects two airports within a stopover budget? Has
this person passed a given age on a given date?

What a checkable derivation adds is a place for disagreement to land. When a
conclusion is wrong, there are only three possibilities, and a proof tells you
which: the inference was invalid, the rule did not say what you meant, or the
input fact was wrong. Without the derivation those three failures look
identical from the outside, and the argument goes in circles.

A checked derivation establishes what follows **from the source you supplied**.
It does not make your model right. That boundary is a feature: it separates
"did the machine reason correctly" from "is this the right model", and lets you
settle the first question so you can spend your attention on the second.

## Two directions of reasoning

Eyel has two kinds of rule, and they compose.

**Forward rules** use `:+`. They materialize consequences until nothing new
appears — a fixpoint. This is how you build a closure: everything that follows
from what you know.

**Backward rules** use `:-`. They define a relation that is explored when a
question asks for it. This is ordinary Prolog resolution: goal-directed search.

A forward rule's body may call backward definitions. A backward query may use
facts that forward reasoning established. You let knowledge accumulate, then
ask a focused question about it:

```prolog
parent(alice, bob).
parent(bob, carol).

ancestor(X, Y) :+ parent(X, Y).
ancestor(X, Z) :+ ancestor(X, Y), parent(Y, Z).

related(X, Y) :- ancestor(X, Y).
related(X, Y) :- ancestor(Y, X).

true :+ related(alice, carol).
```

The closure establishes ancestry once. The query expresses the relationship you
want to inspect. Each part has one job.

Output follows from how you ask. With nothing asked, the newly materialized
facts are printed. `true :+ Goal.` asks a question: it publishes each instance
of `Goal` it can establish, which is why the example above ends that way rather
than with Prolog's interactive `?-`. A program text contains clauses, and a
goal is one of them. `--goal 'Goal'` asks from outside instead, and then the
program's own goals stay quiet. A `false :+ Body` rule declares a contradiction
and exits with code 65 — an integrity constraint that fails loudly.

## What you can say

The core is small on purpose. Terms are variables, atoms, arbitrary-size
integers, floats, compounds, lists and open lists. Double-quoted text is a list
of characters. The controls are conjunction, disjunction, `call/1`, `once/1`,
`\+/1` and `findall/3`.

The native predicates are the ones below. In a flow pattern, `+` marks an
argument that must be bound when the goal runs, `-` one that must be unbound,
`?` one that may be either, and `@` one that is only inspected. A predicate
with two patterns works in both directions. Calling a predicate outside its
patterns usually stops the run with an error rather than failing quietly.

| Predicate | Flow pattern | What it does |
| --- | --- | --- |
| `true/0` | `true` | Succeeds. |
| `fail/0`, `false/0` | `fail` | Fails. |
| `=/2` | `?X = ?Y` | Unifies `X` and `Y`. |
| `\=/2` | `@X \= @Y` | Succeeds when `X` and `Y` do not unify; binds nothing. |
| `==/2` | `@X == @Y` | Succeeds when `X` and `Y` are identical, variables included. |
| `\==/2` | `@X \== @Y` | Succeeds when `X` and `Y` are not identical. |
| `compare/3` | `compare(?Order, @X, @Y)` | Unifies `Order` with `<`, `=` or `>` in the standard order of terms. |
| `is/2` | `?Value is +Expr` | Evaluates `Expr` and unifies the result with `Value`. |
| `=:=/2`, `=\=/2` | `+Expr1 =:= +Expr2` | Compares two evaluated expressions for equal and unequal. |
| `</2`, `=</2`, `>/2`, `>=/2` | `+Expr1 < +Expr2` | Compares two evaluated expressions by order. |
| `var/1`, `nonvar/1` | `var(@X)` | Tests whether `X` is an unbound variable, or is not. |
| `ground/1` | `ground(@X)` | Tests that `X` contains no unbound variables. |
| `atom/1`, `number/1` | `atom(@X)` | Tests that `X` is an atom, or a number. |
| `integer/1`, `float/1` | `integer(@X)` | Tests that `X` is an integer, or a float. |
| `compound/1` | `compound(@X)` | Tests that `X` is a compound term; a nonempty list is one. |
| `functor/3` | `functor(+Term, ?Name, ?Arity)`<br>`functor(-Term, +Name, +Arity)` | Takes a term apart into name and arity, or builds a term with fresh arguments. |
| `arg/3` | `arg(+N, +Term, ?Arg)` | Unifies `Arg` with the `N`th argument of `Term`, counting from 1. |
| `=../2` | `+Term =.. ?List`<br>`-Term =.. +List` | Converts between a term and the list of its name and arguments. |
| `atom_chars/2` | `atom_chars(+Atom, ?Chars)`<br>`atom_chars(-Atom, +Chars)` | Converts between an atom and its list of one-character atoms. |
| `atom_codes/2` | `atom_codes(+Atom, ?Codes)`<br>`atom_codes(-Atom, +Codes)` | Converts between an atom and its list of character codes. |
| `atom_length/2` | `atom_length(+Atom, ?Length)` | Unifies `Length` with the number of characters in `Atom`. |
| `atom_concat/3` | `atom_concat(+A, +B, ?AB)`<br>`atom_concat(?A, ?B, +AB)` | Joins two atoms, or enumerates every way to split `AB` in two. |

Arithmetic is exact on integers of any size. Expressions may use `+`, `-`,
`*`, `/`, `//`, `div`, `mod`, `rem`, `^`, `**`, `min`, `max`, `gcd`, `atan2`,
the bitwise `/\`, `\/`, `xor`, `\`, `<<` and `>>`, the functions `abs`, `sign`,
`float`, `truncate`, `round`, `ceiling`, `floor`, `float_integer_part`,
`float_fractional_part`, `sqrt`, `exp`, `log`, `sin`, `cos`, `tan`, `asin`,
`acos` and `atan`, and the constants `pi` and `e`. The definitions are in
[src/builtins.js](src/builtins.js) and
[src/kernel/iso-arithmetic.js](src/kernel/iso-arithmetic.js).

Everything else — membership, mapping, sorting, graph traversal, formula
inspection — is written as ordinary clauses rather than added to the engine. A
new native operation has to be justified by an example that genuinely cannot be
a clause.

That restraint is what keeps the language learnable, and it reaches further
than it looks. These are the patterns the examples are built from:

| Reasoning pattern | How you write it |
| --- | --- |
| Structured facts, variable predicates | `t(S, P, O)` |
| Forward implication | `Head :+ Body` |
| Backward definition | `Head :- Body` |
| Several conclusions at once | `(H1, H2) :+ Body` |
| Recursion over a graph | Recursive `:+` rules |
| Numeric tests and expressions | Comparisons and `is/2` |
| Alternatives | Several clauses, or `;/2` |
| Closed absence checks | Ground `\+/1` in a higher stratum |
| Collection and aggregates | `findall/3`, then list clauses |
| Existence with local variables | Collect matches, test for a nonempty list |
| External data | A separate predicate such as `base/3` |
| Inference plus union views | Derived predicates with backward view definitions |
| Quoted triples and graphs | `triple(S, P, O)` and `graph(Triples)` |
| Typed or language-tagged values | Structured `literal/2` terms |
| Per-binding witnesses | Explicit `record(Rule, Binding)` terms |
| Ordered events and state changes | Indexed facts, recursive transition relations |
| Asking a goal | `true :+ Goal`, or `--goal` from outside |
| Integrity constraints | `false :+ Body` |

### Numbers behave

Integers are unbounded and never pass through a floating-point value.
`truncate/1`, `round/1`, `ceiling/1`, `floor/1` and `abs/1` return an exact
integer argument unchanged, and `/` on two integers is exact when the division
is. Comparison is exact across the integer/float boundary, and so is the
standard order of terms, which orders numbers by value and places a float
before an integer of equal value. The Fibonacci example computes F(10000) — a
2,090-digit integer — exactly.

### Output you can read back

Every term is written in one canonical spelling, chosen so that reading it back
gives the same term in any ISO Prolog — not just in eyel. Compound terms use
functional notation, `f(a, b)`, rather than operator notation, because operator
notation depends on a table the reader has to agree with. Lists use list
notation, `[a, b]` and `[a, b|T]`, because that is core syntax (ISO 6.3.5) and
needs no table at all.

Double-quoted text is *input* syntax for a list of characters, and it is not
used on output. `"ab"` only means `[a, b]` when the `double_quotes` flag says
so, and the ISO default says `codes`, so a certificate containing `"ab"` would
read as a different term elsewhere. Written as `[a, b]`, it cannot.

### Representing a domain

Eyel has no built-in notion of RDF, or of anything else. Domains get
representations rather than syntax:

```prolog
base(alice, parent_of, bob).
t(S, P, O) :- base(S, P, O).
t(C, child_of, P) :+ t(P, parent_of, C).
allowed(C) :+ t(C, child_of, alice), \+ t(C, blocked, true).
```

`base/3` is external data; `t/3` is the union view. The engine attaches no
special meaning to either name — the separation is yours, and it is what keeps
the base graph isolated from inference. IRIs, typed literals, language tags,
triple terms and quoted formulas are just terms: `iri(I)`,
`literal(V, datatype(D))`, `literal(V, lang(L))`, `triple(S, P, O)`,
`graph(Triples)`.

A forward head may contain variables the body never binds. Those become
`sk_0`, `sk_1` and so on within each conclusion, with sharing preserved. If you
want a distinct witness per rule and binding, say so explicitly —
`blank(rule_name, X)` in the head. This is deliberately not the same as minting
a fresh blank node on every firing: it keeps conclusions deduplicated and
stable across runs.

## Proofs, and what checking one means

A proof document holds claims, the source clauses it displays, and one
inference record per step. `checkProof(source, document)` establishes seven
conditions:

| | Condition | What it establishes |
| --- | --- | --- |
| **C1** | resolution | Every step is an instance of a clause in the supplied source, with conclusion and premises agreeing under one substitution |
| **C2** | well-foundedness | The derivation has no cycles |
| **C3** | justification | Every step's justification is known, well-formed and unique |
| **C4** | coverage | Every claim and every premise is accounted for |
| **C5** | re-decision | Pure primitive results are recomputed independently |
| **C6** | boundary consistency | No trusted absence or collection is contradicted by the source or the certificate |
| **C7** | relevance | Every claim answers a goal that was asked, and every step serves a claim |

Two properties make this worth more than a log.

**The checker follows the certificate.** It never calls the solver to fill a
gap. If a step is missing, the check fails; it does not quietly re-derive the
answer. Checking is a genuinely separate activity from reasoning, and
[src/proof.js](src/proof.js) has no dependency on the solver.

**The source is the authority.** A certificate displays the clauses it used,
but those display records cannot override the program. If they disagree with
the source you check against, C1 fails. You cannot smuggle in a rule by writing
it into the proof, and you cannot pad it either: C7 rejects a step that no
claim uses and a claim that answers no goal.

The report is itself ordinary Prolog data:

```prolog
condition('C1', resolution, ok, 2).
condition('C2', well_founded, ok, 2).
condition('C3', justification, ok, 2).
condition('C4', coverage, ok, 2).
condition('C5', re_decision, ok, 0).
condition('C6', boundary_consistency, ok, 0).
condition('C7', relevance, ok, 3).
steps(2).
verified(2).
recomputed(0).
composed(0).
trusted(0).
claims(1).
verdict(checked).
```

So one program's evidence is material another program can reason over. A
workflow can accept only certain verdicts, collect unresolved obligations, or
attach a verified derivation to a generated report. Failures appear as
`failed(N)` outcomes with `failure(Condition, Conclusion, Detail)` facts; an
invalid certificate gives `verdict(failed(N))` and CLI exit code 1. A coverage
count of zero means that condition had nothing to check. `--json` gives the
same report as JSON.

Clause numbers refer to the supplied program's rules in source order, so check
a saved proof against the program that produced it. A proof made with `--goal`
answers that goal rather than the program's own, so pass the same `--goal` with
`--check-proof`, or `goals` to `checkProof`, or C7 rejects its claims.

## Where it is honest about not knowing

Two things in the language cannot be certified the way a resolution step can.

**Negation** (`\+`) says a search finished without finding anything.
**Collection** (`findall/3`) says a search found exactly these answers. Both are
claims about the *absence* of further results, and a certificate cannot
demonstrate an absence the way it demonstrates a derivation.

Eyel does not paper over this. Each one is recorded as an explicit `absent` or
`collected` boundary, listed in the report as an obligation, and
`--strict-proof` rejects any proof that leans on one. What the checker can do is
refute a boundary, and that is C6. An absence fails when a source fact, a step
of the same certificate or a recomputed primitive is a solution after all; a
collection fails when such a solution is missing from its list. A boundary C6
cannot decide, such as an absence over a conjunction with shared variables,
simply stays an obligation. A valid proof carrying
obligations is exactly that: valid *conditional on* those obligations, and the
report tells you where. You get to decide whether that is good enough for the
task in front of you.

The same honesty applies elsewhere. A mode test such as `var(X)` followed by
`X = a` cannot be represented faithfully by recording only the final
substitution, so proof generation refuses rather than emitting something
misleading. And every generated proof is checked before it is returned — the
language does not hand you a certificate it has not verified.

## The examples

The [example collection](examples/README.md) is 67 complete programs. Each one
ships with its conclusions, its proof and its C1–C7 check report, all saved to
disk:

```text
examples/socrates.pl           Source program
examples/output/socrates.pl    Conclusions
examples/proof/socrates.pl     Conclusions with proof records
examples/check/socrates.pl     C1-C7 proof-check report
```

| Examples | What they demonstrate |
| --- | --- |
| `socrates`, `family`, `backward` | Basic inference, recursive relationships and mixed chaining |
| `deep-taxonomy-10` through `deep-taxonomy-100000` | A subclass chain whose branches lead nowhere, at five sizes |
| `reachability`, `shortest-path`, `path-discovery` | Cyclic graph closure, weighted paths and airport routes with bounded stopovers |
| `fibonacci`, `arithmetic`, `lists` | Recursive computation, exact integers and list operations |
| `strings`, `unification`, `alternatives` | Unicode, structural matching and goal-directed choices |
| `graphs`, `terms`, `witnesses` | Separate graph views, quoted data and structured witnesses |
| `inventory`, `permissions`, `state-transitions`, `integrity` | Aggregation, policy checks, event logs and constraints |
| `schema-inference`, `equivalence`, `annotation-evidence`, `property-paths` | Schema rules, identity closure, statement evidence and composed paths |
| `nested-collections`, `flat-map`, `scoped-audit`, `variable-predicates` | Structured collections, mapping, scoped checks and relation renaming |
| `family-cousins`, `dog-license`, `paraconsistent-animals`, `record-scopes` | Family branches, counted policies, conflicting observations and witness scope |
| `hanoi`, `collatz`, `metric-classification`, `control-system`, `sudoku`, `age` | Recursive puzzles, numerical classification, actuator control, a 9x9 Sudoku solver and calendar age checks |
| `good-cobbler`, `peano`, `expression-eval`, `complex` | Structured descriptions, symbolic arithmetic, expression graphs and a complex-number domain |
| `modexp`, `queens`, `interval-relations` | Modular powers, constraint search and all thirteen interval relations |
| `concept-alignment`, `bayes-diagnosis`, `policy-risk` | Reporting rollups, normalized fault scores and ranked policy findings |
| `ackermann`, `peasant`, `padovan`, `sieve`, `goldbach`, `kaprekar` | Exact hyperoperations, ancient arithmetic, number sequences and number-theory checks |
| `easter`, `turing`, `superdense-coding`, `teleportation` | Calendar arithmetic, a Turing machine interpreter and discrete quantum protocols |
| `zebra`, `four-color`, `wolf-goat-cabbage`, `monkey-bananas`, `enigma1225` | Classic constraint puzzles, planning problems and a combinatorial board puzzle |

A few are worth singling out. [Ackermann](examples/ackermann.pl) computes
A(4, 2), a number with 19,729 digits, exactly. The [zebra puzzle](examples/zebra.pl)
is Einstein's riddle solved by unification alone. The [airport search](examples/path-discovery.pl)
works over 7,698 airports and 37,505 connections; change the endpoints and the
stopover budget and ask again. The [interval example](examples/interval-relations.pl)
distinguishes all thirteen basic relations between two intervals. The
[policy example](examples/policy-risk.pl) carries scores, ranks, reasons and
suggested mitigations into its conclusions. The
[deep-taxonomy benchmark](examples/deep-taxonomy-100000.pl) follows a
hundred-thousand-step chain and produces a certificate in which every one of
those 100,001 steps is independently verified.

These are meant to be edited. Read one, change a fact, run it, look at what
changed. The [playground](https://eyereasoner.github.io/eyel/playground/) does that in a browser: load any
example, edit it, run it, check its proof, and copy a link that reopens exactly
what you see. Add a clause. Ask a narrower question. Each example is a small
repeatable experiment, and because the artifacts are saved, you can see exactly
what your change did:

```sh
npm test                   # every example through the API and the CLI
npm run test:examples      # just the corpus
npm run examples:update    # regenerate artifacts after an intended change
```

Tests never overwrite the saved artifacts. When you intend a change, you
regenerate and review the artifact diff alongside the source diff.
`examples/manifest.json` lists every program with its expected halt code and
permitted obligations, and the suite requires every source and every artifact
to be listed, so nothing can quietly fall out of coverage.

## Using it from JavaScript

```js
import { run, checkProof } from './index.js';

const source = 'human(socrates). mortal(X) :+ human(X).';
const result = run(source, { goal: 'mortal(X)', proof: true });
console.log(result.answers);                            // ['mortal(socrates)']
console.log(result.bindings);                           // [{ X: 'socrates' }]
console.log(checkProof(source, result.proof).valid);    // true
```

`run()` returns `answers`, `bindings`, `inferred`, `stdout`, `proof`,
`proofReport`, `stats` and `haltCode`. Bindings and answers are printable
Prolog text. Because a generated proof is always checked before it is returned,
`proofReport` hands you that report rather than making you check the same
document twice. `Program.parse()` gives you a reusable parsed program; each run
has its own inference state.

Options are `goal`, `goals`, `proof`, `maxDepth` (1000000), `maxIterations`
(1000 per stratum) and `maxInferences` (1000000). Exceeding a bound throws — a
partial closure is never returned as though it were complete.

`checkReportTerms(report)` formats a full Prolog report and
`verdictTermText(report)` just its verdict.

## How it works inside

None of this needs a large implementation. The runtime has no dependencies and
there is no build step.

| File | Responsibility |
| --- | --- |
| [src/kernel/](src/kernel/) | Terms, unification, parsing, numeric semantics, writing |
| [src/program.js](src/program.js) | Profile validation and dependency stratification |
| [src/builtins.js](src/builtins.js) | The pure primitive profile |
| [src/engine.js](src/engine.js) | Backward resolution, forward fixpoints, proof recording |
| [src/proof.js](src/proof.js) | Certificate rendering and checking, with no solver dependency |
| [bin/eyel.js](bin/eyel.js) | Source loading and the command-line interface |

**Search is an explicit machine, not nested host calls.** A frame is one body
being worked through; frames are immutable, so a choice point only has to
remember the frame it was created in and backtracking is a pointer assignment.
Depth is therefore bounded by `maxDepth` and by memory rather than by the host
call stack. A derivation a hundred thousand steps deep is an ordinary run.

**One substitution is threaded through a search**, restored by an undo trail
when a branch fails, so an alternative costs the bindings it actually made
instead of a copy of the whole map. The trail records each name's previous
value, which also makes it safe for a dereference to shorten a chain of
variable-to-variable bindings as it walks one. Together these make an N-step
derivation cost O(N); without either it costs O(N²). One consequence worth
knowing: an answer's bindings are valid only until the next answer is
requested.

**Unification is on finite trees.** An occurs check rejects a binding that
would create a cycle. Fresh variable names are rendered injectively, so an
internal `X#1` can never be confused with a source variable named `X_1`.

**The reader has a fixed operator table.** Because there are no directives,
nothing in a program can change how the rest of itself — or any program loaded
beside it — is read. A source text has exactly one reading, which is why
[test/syntax.test.js](test/syntax.test.js) can state that reading case by case.
Large generated programs are mostly one-line clauses of plain names, variables
and small integers, so those are read directly rather than token by token; the
test suite checks that the direct reading and the general one agree on every
example and on thousands of edge cases, errors included.
There is no separate query syntax to interact with it either: a goal is the
ordinary clause `true :+ Goal.`, so nothing around it can change how it reads.

**Stratification matches whole terms, not just predicate names.** Forward rules
that use negation or collection run only after everything they inspect has
reached its fixpoint. Because the analysis compares complete head and body
terms, two relations sharing a predicate name can occupy different strata when
their argument patterns do not overlap — which is exactly what you need when
everything is `t/3`. Positive cycles stay in one stratum; closed dependency
cycles are rejected, as are dynamic meta-calls reachable from forward rules.

**Proof steps record the first derivation found** for each conclusion, and are
recorded only when a proof is asked for: without one, the search keeps just what
it needs to find answers. Nodes carry the terms they were built from and are
resolved once, by whoever consumes a complete answer, so a conjunction does not
re-copy the proof forest for each of its goals. Renaming a clause apart shares
every subterm that holds no variable, since terms never change once built.

## What is deliberately absent

Modules, directives, DCGs, cut, conditional commitment, mutable databases,
attributed variables, constraint libraries, tabling, filesystem and network
built-ins, RDF parsers, streaming adapters, browser packaging.

Some of these are omissions of convenience; several are load-bearing. No
directives means a fixed operator table and one reading per source text. No cut
and no mutable database means a derivation is a function of the program and its
input, which is what makes a certificate meaningful. A program using `op/3`,
`set_prolog_flag/2` or `char_conversion/2` is refused rather than parsed under
different rules.

Applications supply external data as facts. Undefined user predicates fail,
under the closed-world convention.

Minimality here means a narrow language profile and a runtime without
dependencies. It is not a claim about source size.

## Start with a question

Perhaps you have a policy spread across several documents. Perhaps there is a
graph whose relationships you keep tracing by hand. Perhaps a calculation needs
an explanation that can travel with its result.

Begin with one question and a few facts. Give the relationships names. Write
the rules you already believe. Then let the program show you what they imply.

The first answer may be small. The first *unexpected* answer is often worth
more, because it points at a specific rule or assumption to revisit. As the
model grows you accumulate a body of executable knowledge you can inspect,
test and explain.

That is the whole promise, and it is a practical one: programs whose
conclusions arrive with a story precise enough to check.
