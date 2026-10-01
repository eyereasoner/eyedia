# Examples

Run a source, generate its proof, or check its saved proof:

```sh
node bin/eyelang.js examples/socrates.pl
node bin/eyelang.js --proof examples/socrates.pl
node bin/eyelang.js --check-proof examples/proof/socrates.pl examples/socrates.pl
```

Each program has a matching conclusion file in `output/`, a certificate in
`proof/`, and a Prolog C1-C5 verification report in `check/`. The names match the
source: `lists.pl` has `output/lists.pl`, `proof/lists.pl` and `check/lists.pl`.

| Program | Demonstrates |
| --- | --- |
| [socrates.pl](socrates.pl) | A first forward inference |
| [family.pl](family.pl) | Recursive family relationships |
| [backward.pl](backward.pl) | Backward definitions inside forward bodies |
| [fibonacci.pl](fibonacci.pl) | Fast doubling for exact Fibonacci numbers, including F(10000) |
| [graphs.pl](graphs.pl) | Base data, negation and collection |
| [terms.pl](terms.pl) | Quoted graphs, triple terms and residual witnesses |
| [reachability.pl](reachability.pl) | Finite closure in a graph containing a cycle |
| [shortest-path.pl](shortest-path.pl) | Weighted paths and stratified minimum selection |
| [path-discovery.pl](path-discovery.pl) | Full airport network with configurable endpoints and maximum stopovers |
| [lists.pl](lists.pl) | Concatenation, mapping and summation |
| [arithmetic.pl](arithmetic.pl) | Factorial, greatest common divisor and large integers |
| [strings.pl](strings.pl) | Text construction and Unicode inspection |
| [inventory.pl](inventory.pl) | An invoice from collected line totals |
| [permissions.pl](permissions.pl) | Role permissions with exclusions |
| [witnesses.pl](witnesses.pl) | Structured witnesses and shared multi-head conclusions |
| [state-transitions.pl](state-transitions.pl) | Account balances from an ordered event log |
| [integrity.pl](integrity.pl) | A provable integrity violation |
| [alternatives.pl](alternatives.pl) | Alternative routes, disjunction and once |
| [unification.pl](unification.pl) | Open lists and repeated-variable constraints |
| [schema-inference.pl](schema-inference.pl) | Subclasses, subproperties, domains and ranges |
| [equivalence.pl](equivalence.pl) | Explicit identity closure and name propagation |
| [annotation-evidence.pl](annotation-evidence.pl) | Authors and dates attached to quoted statements |
| [nested-collections.pl](nested-collections.pl) | Lists containing property records and other lists |
| [family-cousins.pl](family-cousins.pl) | Generations, family branches and cousin relationships |
| [dog-license.pl](dog-license.pl) | A licensing threshold based on collected dog counts |
| [hanoi.pl](hanoi.pl) | Recursive construction of a disk-move sequence |
| [collatz.pl](collatz.pl) | A parity-based recursive trajectory |
| [flat-map.pl](flat-map.pl) | Predicate-based mapping with multiple or missing values |
| [property-paths.pl](property-paths.pl) | Composed and repeatable relationship paths |
| [paraconsistent-animals.pl](paraconsistent-animals.pl) | Local summaries of conflicting observations |
| [scoped-audit.pl](scoped-audit.pl) | Presence and absence within separate quoted graphs |
| [metric-classification.pl](metric-classification.pl) | Measurement normalization and numerical classification |
| [variable-predicates.pl](variable-predicates.pl) | Relations selected and renamed through data bindings |
| [record-scopes.pl](record-scopes.pl) | Distinct per-rule structured witnesses |
| [sudoku.pl](sudoku.pl) | A finite 4x4 grid solved with ordinary clauses |
| [good-cobbler.pl](good-cobbler.pl) | Trade-specific classification from structured descriptions |
| [peano.pl](peano.pl) | Symbolic arithmetic and relational addition |
| [expression-eval.pl](expression-eval.pl) | Recursive expression graphs used in forward inference |
| [modexp.pl](modexp.pl) | Exact modular exponentiation by repeated squaring |
| [concept-alignment.pl](concept-alignment.pl) | Vocabulary alignment and reporting rollups |
| [interval-relations.pl](interval-relations.pl) | All thirteen interval relations and endpoint completion |
| [bayes-diagnosis.pl](bayes-diagnosis.pl) | Normalized probabilities for illustrative printer faults |
| [policy-risk.pl](policy-risk.pl) | Ranked findings with explanations and suggested mitigations |
| [queens.pl](queens.pl) | Configurable N-queens search with diagonal constraints |

`integrity.pl` intentionally exits with code 65 because it concludes `false`.
Its proof-check report is valid: the certificate explains why the constraint was
violated. Negation and collection examples list their `absent` and `collected`
obligations in the check report; `--strict-proof` rejects those obligations.
Every check file includes `condition/4` facts for C1-C5, verification counts and
a `verdict/1` fact. Reports with failures include `failure/3`; reports with
trusted boundaries include `obligation/3`. Add `--json` to the check command
for JSON output instead of Prolog facts.

`fibonacci.pl` computes F(10000), a 2090-digit integer. It uses fast doubling,
which halves the index at each recursive step and fits within the default
reasoning limits. Its saved proof records the arithmetic and recursive clause
instances without trusted obligations.

`path-discovery.pl` contains 7,698 airport records and 37,505 directed
connections. Its default query finds three routes from Ostend to Prague with
at most two stopovers. Use any airport-name atoms and a nonnegative integer
limit with `path_discovery(From, To, MaxStopovers, Path)`:

```sh
node bin/eyelang.js --goal "path_discovery('Liège Airport', 'Václav Havel Airport Prague', 1, Path)" examples/path-discovery.pl
node bin/eyelang.js --proof --goal "path_discovery('Ostend-Bruges International Airport', 'Liège Airport', 0, Path)" examples/path-discovery.pl > /tmp/route-proof.pl
node bin/eyelang.js --strict-proof --check-proof /tmp/route-proof.pl examples/path-discovery.pl
```

`--goal` replaces the default query. Zero stopovers allows only direct flights;
N stopovers allows at most N+1 flights. Routes follow the recorded direction
and never repeat an airport. Equal endpoints and unknown names return no
routes. Negative or noninteger limits also return no routes. You can leave
`From` or `To` as a variable to discover endpoints; keep `MaxStopovers` bound.
List the available names with `--goal "airport(Id, Name)"`. These are historical
network records, rather than current flight schedules. The search uses explicit
disequalities to prevent cycles, so its proofs have no trusted obligations.
Large bounds on a dense network may still reach the configured reasoning limits.

`peano.pl` represents natural numbers as `zero`, `s(zero)`, and so on. Its
addition query enumerates every split of a known sum. `expression-eval.pl`
evaluates a graph for `(2*3)+(10-4)` and emits `result(example, 12)`.
`concept-alignment.pl` rolls up five concepts to a shared reporting class,
including a source concept reached through multiple broader links.

`modexp.pl` handles billion-sized exponents by repeated squaring without
constructing the full power. Supply an integer base, a nonnegative integer
exponent and a positive integer modulus. `queens.pl` returns the first solution
for an 8x8 board by default; replacing the query enumerates other board sizes:

```sh
node bin/eyelang.js --goal "mod_pow(7, 1000000000, 1000000007, Result)" examples/modexp.pl
node bin/eyelang.js --goal "queens(4, Columns)" examples/queens.pl
node bin/eyelang.js --goal "add(A, B, s(s(s(zero))))" examples/peano.pl
```

`interval-relations.pl` uses half-open intervals with integer-minute endpoints.
It completes endpoints from durations and classifies each valid interval pair
into exactly one of thirteen relations. Empty and reversed intervals are
excluded from classification.

`bayes-diagnosis.pl` models printer faults using illustrative priors and two
conditionally independent observations. It keeps exact integer likelihood
weights and their collected total alongside a floating-point probability.
`policy-risk.pl` reports a rank, clause, clamped score, severity, reason and
mitigation. Rank 1 has the highest score; equal scores share a rank. Output
follows inference order, with ranks recorded explicitly. Adding the missing
safeguards removes the affected findings. Both examples expose their collection
obligations, and policy findings also expose absence obligations. The other
seven new examples pass strict proof checking.

Run `npm test` for the full suite or `npm run test:examples` for this corpus.
Every example runs through the API and all three CLI modes. The test log prints
`[current/total]` and the name of each test before executing it. Tests compare
results with saved artifacts and do not overwrite them.

After an intentional behavior change, run `npm run examples:update` and review
the source and artifact changes together. When adding an example, register its
name, description, expected halt code (if any) and proof obligations in
[manifest.json](manifest.json), then generate its artifacts.
