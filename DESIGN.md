# Language profile

Eyel uses a small Prolog reasoning core. Function symbols and recursive Horn
clauses support general symbolic computation. Compound terms carry application
data without dedicated runtime classes. Forward materialization supplies finite
recursive graph closure, and closed dependencies schedule absence and collection
after their prerequisites.

The language separates logical representation from application policies. A term
such as `graph(Triples)` carries a quoted graph, but its equality, variable scope
and interpretation are defined by the program using it. Separate predicates
distinguish external data from inferred relations. Ordered events can be indexed
by state or message identifiers.

| Reasoning pattern | Prolog expression |
| --- | --- |
| Structured facts and variable predicates | `t(S,P,O)` |
| Forward implication | `Head :+ Body` |
| Backward definition | `Head :- Body` |
| Multiple conclusions | `(H1,H2) :+ Body` |
| Positive graph recursion | Recursive `:+` rules |
| Numeric tests and expressions | Arithmetic comparisons and `is/2` |
| Alternatives | Multiple clauses or `;/2` |
| Closed absence checks | Ground `\+/1` in a higher stratum |
| Collection and aggregate inputs | `findall/3`, followed by list clauses |
| Existence with local variables | Collect matches and test for a nonempty list |
| External data | A separate predicate such as `base/3` |
| Inference and union views | Derived predicates plus backward view definitions |
| Quoted triples and graphs | `triple(S,P,O)` and `graph(Triples)` |
| Typed or language-tagged values | Structured `literal/2` terms |
| Per-binding witnesses | Explicit `record(Rule,Binding)` terms |
| Ordered events and state transitions | Indexed facts and recursive transition relations |
| Output selection | `?- Goal`, `--goal`, or `true :+ Body` |
| Integrity constraints | `false :+ Body` |
| Proof and proof checking | Recorded clause instances and certificate verification |

Ordinary `:+` rules are repeatable, deduplicated materialization rules. Programs
that need a witness per binding should construct that identity explicitly in
the head. Residual variables instead receive the local names `sk_0`, `sk_1`,
etc., with sharing preserved within a conclusion.

The core excludes modules, directives, DCGs, cut, conditional commitment,
mutable databases, attributed variables, constraint stores, tabling and host
I/O. Some operations can be expressed as clauses; external services supply
their results as input facts. Backward search is depth-first and bounded.
Forward dependency analysis requires statically named calls and rejects closed
dependency cycles.

Minimality means a narrow language profile and a runtime without dependencies,
not a proven lower bound on source size. Additional native operations should be
justified by a concrete example that cannot reasonably use ordinary clauses
or caller-supplied data.

# Implementation

| File | Responsibility |
| --- | --- |
| `src/kernel/` | Terms, finite-tree unification, parsing, numeric semantics and writing |
| `src/program.js` | Profile validation and term-sensitive dependency stratification |
| `src/builtins.js` | Pure primitive profile |
| `src/engine.js` | Backward resolution, forward fixpoints and proof recording |
| `src/proof.js` | Certificate rendering and checking; no solver dependency |
| `bin/eyel.js` | Source loading and command-line interface |
| `tools/example-artifacts.js` | Example evaluation and artifact generation rules |
| `test/examples.test.js` | Saved-artifact verification and complete CLI runs |

Branch-local maps hold substitutions; unification does not change terms.
A substitution is a layer over the one it was cloned from, flattened once a
chain grows long, because most unification attempts fail and would otherwise
pay for a full copy of the bindings. An occurs check enforces finite trees.
Fresh names are rendered injectively so an internal `X#1` cannot be confused
with a source variable named `X_1`.

Numeric semantics keep integers exact: an integer operand never passes through
a floating-point value, mixed comparisons are decided without rounding either
side, and the standard order of terms is the ISO one, by value before type.
The writer emits a single canonical spelling per term rather than the layout
variants of a general `writeq/1`, so output reads back as the same term without
operator declarations.

Proof nodes carry the terms they were built from and are resolved once, by
whoever consumes a complete answer, so a conjunction does not re-copy the proof
forest for each of its goals.

The reader is a tokenizer and a recursive-descent parser over a fixed operator
table. Excluding directives removes the only mechanisms that could change
parsing mid-file, so a source text has one reading and `test/syntax.test.js`
can state it case by case. A `?- Goal.` is always a goal to run: nothing that
follows it can turn it into something else.

Forward dependency analysis matches full head and body terms. Two relations
using the same predicate name can therefore occupy distinct strata when their
argument patterns do not overlap. A rule runs only after all its closed
prerequisites reach a fixpoint. Positive cycles remain in the same stratum.

Proof steps record the first derivation found for each conclusion. A source
rule must match its conclusion and all premises under one substitution. Pure
primitive results are recomputed without access to theory clauses. Absence and
collection are reported as obligations rather than accepted as fully checked
logical inferences. Proof generation checks its own output and rejects results
whose evaluation-time state cannot be represented by these records.

Check reports are ordinary Prolog facts. `condition/4` records C1-C5 in order:
resolution, well-foundedness, justification, coverage and independent re-decision.
Each condition reports its coverage count and either `ok` or `failed(N)`.
`failure/3` and `obligation/3` carry the relevant conclusion terms, while counters
and `verdict/1` summarize the check. Source-clause verification contributes to
C1; pure primitive recomputation and checked control composition contribute to
C5. Trusted boundaries remain explicit obligations and do not count as
independently recomputed results. CLI and saved artifacts use the same formatter.

# Example artifacts

`examples/manifest.json` lists every source program, its expected halt code and
its permitted proof obligations. Each source has matching `.pl` output, proof
and check-report files. Tests require every source and every saved artifact to be
listed, so additions and obsolete snapshots cannot silently escape coverage.

API tests reproduce all three artifacts and check the saved certificate against
the source. CLI tests execute every example normally, with `--proof`, and with
`--check-proof` on the saved certificate. The integrity example intentionally
returns code 65 when run, while checking its proof succeeds with code 0: a proof
of a violation is still a valid derivation.

Tests compare snapshots without modifying them. `npm run examples:update`
evaluates the entire corpus before writing any artifacts. Artifact changes are
reviewable alongside the source changes that caused them.

The shared test wrapper prints a progress counter and test name before entering
each test body. Test bodies yield after execution so the standard reporter can
display completed results between tests, including those that launch synchronous
CLI subprocesses. Both the full suite and the example-only suite use this wrapper.
