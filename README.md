# eyelang

A standalone, dependency-free **Prolog rule language** with forward and backward
reasoning and checkable proofs.

Eyelang turns explicit facts and rules into conclusions whose derivations can
be inspected and checked. Its compact core supports structured terms, recursive
relations, arithmetic, stratified negation and collection. Data models and
reusable operations are expressed with ordinary Prolog clauses.

Run with Node.js 18 or newer. No install or build step is needed:

```sh
node bin/eyelang.js examples/socrates.pl
node bin/eyelang.js --proof examples/socrates.pl
node bin/eyelang.js --proof examples/socrates.pl | node bin/eyelang.js --check-proof - examples/socrates.pl
npm test
```

The executable becomes `eyelang` when the package is installed.

Facts and rules use Prolog syntax:

```prolog
human(socrates).
mortal(X) :+ human(X).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).
```

`Head :+ Body` materializes conclusions until a fixpoint. `Head :- Body` defines
a predicate that is evaluated when called. A forward body can call backward
definitions and pure built-ins. Ordinary facts and derived facts are both
available to backward goals.

Forward rules run before queries. Use `?- Goal.` in the program, or pass
`--goal 'Goal'`. With no query, newly materialized facts are printed. A
`true :+ Body` rule selects its instantiated body for output. A `false :+ Body`
rule concludes a contradiction and exits with code 65. Multiple forward heads
can be written as `(first(X), second(X)) :+ body(X)`.

Terms support variables, atoms, arbitrary-size integers, floats, compounds,
lists and open lists. Double-quoted text is a list of characters.
Output uses canonical Prolog functional notation, including
`'.'(Head, Tail)` for list cells, so it can be parsed without custom operators.
Unification operates on finite trees and rejects cyclic bindings.

The core controls are conjunction, disjunction, `call/1`, `once/1`, `\+/1`
and `findall/3`. Negation requires a ground goal. Forward rules with negation
or collection run after the predicates they inspect reach their fixpoint.
Dependency analysis matches complete head/body terms, so distinct RDF predicate
positions can occupy distinct strata even when they share `t/3`. Closed
dependency cycles and dynamic meta-calls reachable from forward rules are
rejected.

The pure primitive profile includes unification and identity tests, arithmetic
evaluation and comparisons, type tests, `functor/3`, `arg/3`, `=../2`,
`compare/3`, `atom_chars/2`, `atom_codes/2`, `atom_length/2` and `atom_concat/3`.
The exact native predicate list is in [src/builtins.js](src/builtins.js).
List membership, mapping, sorting, graph traversal, formula inspection and other
relations can be defined with ordinary clauses rather than extending the engine.

RDF concepts need representations rather than new language syntax:

```prolog
base(alice, parent_of, bob).
t(S, P, O) :- base(S, P, O).
t(C, child_of, P) :+ t(P, parent_of, C).
allowed(C) :+ t(C, child_of, alice), \+ t(C, blocked, true).
```

Here `base/3` is external data and `t/3` is the union view. To preserve base graph
isolation, write forward heads to `t/3` or separate inference predicates, and
read `base/3` for data-only conditions. The engine does not assign special
semantics to these names. IRIs, typed literals, language tags, triple terms and
quoted formulas can be represented as `iri(I)`, `literal(V, datatype(D))`,
`literal(V, lang(L))`, `triple(S,P,O)` and `graph(Triples)`.

Residual forward-head variables become
`sk_0`, `sk_1`, etc. within each instantiated conclusion. For a distinct witness
per rule and body binding, use explicit structured terms such as
`blank(rule_name, X)` in the head. These conventions are different from automatically
allocating fresh RDF blank nodes on every firing.

From JavaScript:

```js
import { run, checkProof } from './index.js';

const source = 'human(socrates). mortal(X) :+ human(X).';
const result = run(source, { goal: 'mortal(X)', proof: true });
console.log(result.answers); // ['mortal(socrates)']
console.log(result.bindings); // [{ X: 'socrates' }]
console.log(checkProof(source, result.proof).valid); // true
```

`run()` returns `answers`, `bindings`, `inferred`, `stdout`, `proof`, `stats`
and `haltCode`. Bindings and answers contain printable Prolog text. `Program.parse()`
creates a reusable parsed program; each run has its own inference state.
Options include `goal`, `goals`, `proof`, `maxDepth` (256), `maxIterations`
(1000 per stratum) and `maxInferences` (1000000). Exceeding a bound throws;
partial closure is not returned as a completed result. Backward search is ordinary
depth-first Prolog search. Use forward rules for finite recursive closure;
left-recursive backward programs need reformulation and can hit the depth bound.

Recursion limits depend on the algorithm used by the program. The Fibonacci
example uses fast doubling to compute F(10000) exactly with logarithmic recursion
depth. The direct two-call recurrence needs linear depth and repeats exponentially
many subcomputations; increasing `--max-depth` alone does not make large indices
practical.

Proof documents contain claims, source-clause display records and inference
records:

```prolog
mortal(socrates).
clause(1, human(socrates), true).
clause(2, mortal(var('X')), human(var('X'))).
step(mortal(socrates), rule(2), ['X'=socrates], [human(socrates)]).
step(human(socrates), fact(1), [], []).
```

`checkProof(source, document)` checks source resolution (C1), acyclicity (C2),
known and unique justifications (C3), claims and premise coverage (C4), and
independent pure-primitive recomputation (C5). Clause display records must agree
with the supplied program; they cannot override it. The checker follows the
certificate and does not invoke the reasoning solver to supply missing steps.

Negation and collection remain explicit `absent` and `collected`
trust boundaries. The report lists them in `trusted`; `{ allowTrusted: false }`
or CLI `--strict-proof` rejects them. A valid proof with trusted boundaries is
conditional on those obligations. Mode tests such as `var(X)` followed by
`X=a` cannot be certified by recording only the final substitution; proof
generation fails explicitly for such results. Generated nonempty proofs are
checked before being returned.

Clause numbers refer to the supplied program's normalized rules, in source
order. Check a saved proof against the same source program that produced it.

The [examples](examples/README.md) include 34 complete programs:

| Examples | What they demonstrate |
| --- | --- |
| `socrates`, `family`, `backward` | Basic inference, recursive relationships and mixed chaining |
| `reachability`, `shortest-path` | Cyclic graph closure and weighted path selection |
| `fibonacci`, `arithmetic`, `lists` | Recursive computation, exact integers and list operations |
| `strings`, `unification`, `alternatives` | Unicode, structural matching and goal-directed choices |
| `graphs`, `terms`, `witnesses` | Separate graph views, quoted data and structured witnesses |
| `inventory`, `permissions`, `state-transitions`, `integrity` | Aggregation, policy checks, event logs and constraints |
| `schema-inference`, `equivalence`, `annotation-evidence`, `property-paths` | Schema rules, identity closure, statement evidence and composed paths |
| `nested-collections`, `flat-map`, `scoped-audit`, `variable-predicates` | Structured collections, mapping, scoped checks and relation renaming |
| `family-cousins`, `dog-license`, `paraconsistent-animals`, `record-scopes` | Family branches, counted policies, conflicting observations and witness scope |
| `hanoi`, `collatz`, `metric-classification`, `sudoku` | Recursive puzzles, numerical classification and a finite 4x4 grid solver |

Each source has three saved artifacts:

```text
examples/socrates.pl           Source program
examples/output/socrates.pl    Conclusions
examples/proof/socrates.pl     Conclusions with proof records
examples/check/socrates.pl     C1-C5 proof-check report
```

`npm test` runs all examples through the API and CLI, compares the output and
proof with the saved artifacts, and checks every saved proof against its source.
It also exercises proof tampering, term semantics and CLI errors. Each test
prints `[current/total]` and its name before running, followed by the test
reporter's result, so progress remains visible during CLI checks. Run only the
corpus with `npm run test:examples`. After intentionally changing a program or
its expected behavior, run `npm run examples:update` and review the artifacts;
tests never overwrite them.

`--check-proof` prints Prolog facts that can themselves be loaded and queried:

```prolog
condition('C1', resolution, ok, 2).
condition('C2', well_founded, ok, 2).
condition('C3', justification, ok, 2).
condition('C4', coverage, ok, 2).
condition('C5', re_decision, ok, 0).
steps(2).
verified(2).
recomputed(0).
composed(0).
trusted(0).
claims(1).
verdict(checked).
```

Each condition includes its outcome and coverage count. Failures produce
`failed(N)` outcomes and `failure(Condition, Conclusion, Detail)` facts.
Trusted boundaries produce `obligation(Kind, Reason, Conclusion)` facts and the
verdict `checked_with_obligations`; an invalid certificate produces
`verdict(failed(N))` and CLI exit code 1. A coverage count of zero means that
condition had no checked instances. Control compositions are counted under C5,
separately from source-clause resolution and pure primitive recomputation.

The JavaScript report includes a `conditions` array for C1-C5. Use
`checkReportTerms(report)` to format the complete Prolog report or
`verdictTermText(report)` for its verdict alone. Add `--json` to `--check-proof`
when a JSON report is needed.

Modules, directives, DCGs, cut, conditional commitment, mutable databases,
attributed variables, constraint libraries, tabling, filesystem/network
built-ins, RDF parsers, streaming adapters and browser packaging are outside
this profile. Applications supply external data as Prolog facts. Undefined
user predicates fail under the closed-world convention.

See [DESIGN.md](DESIGN.md) for the language profile and implementation model.
