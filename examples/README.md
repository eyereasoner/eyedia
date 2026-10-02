# Examples

Run a source, generate its proof, or check its saved proof:

```sh
node bin/eyel.js examples/socrates.pl
node bin/eyel.js --proof examples/socrates.pl
node bin/eyel.js --check-proof examples/proof/socrates.pl examples/socrates.pl
```

Each program has a matching conclusion file in `output/`, a certificate in
`proof/`, and a Prolog C1-C7 verification report in `check/`. The names match the
source: `lists.pl` has `output/lists.pl`, `proof/lists.pl` and `check/lists.pl`.

| Program | Demonstrates |
| --- | --- |
| [socrates.pl](socrates.pl) | Class membership derived through a subclass rule |
| [deep-taxonomy-10.pl](deep-taxonomy-10.pl) | A ten-level subclass chain with branches that lead nowhere |
| [deep-taxonomy-100.pl](deep-taxonomy-100.pl) | The same taxonomy benchmark at a hundred levels |
| [deep-taxonomy-1000.pl](deep-taxonomy-1000.pl) | The same taxonomy benchmark at a thousand levels |
| [deep-taxonomy-10000.pl](deep-taxonomy-10000.pl) | The same taxonomy benchmark at ten thousand levels |
| [deep-taxonomy-100000.pl](deep-taxonomy-100000.pl) | The same taxonomy benchmark at a hundred thousand levels |
| [family.pl](family.pl) | Recursive family relationships |
| [backward.pl](backward.pl) | Backward definitions inside forward bodies |
| [fibonacci.pl](fibonacci.pl) | Fast doubling for exact Fibonacci numbers, and the golden ratio |
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
| [collatz.pl](collatz.pl) | Parity-based recursive trajectories over a range of starts |
| [flat-map.pl](flat-map.pl) | Predicate-based mapping with multiple or missing values |
| [property-paths.pl](property-paths.pl) | Composed, inverse and repeatable relationship paths |
| [paraconsistent-animals.pl](paraconsistent-animals.pl) | Local summaries of conflicting observations |
| [scoped-audit.pl](scoped-audit.pl) | Presence and absence within separate quoted graphs |
| [metric-classification.pl](metric-classification.pl) | Measurement normalization and numerical classification |
| [variable-predicates.pl](variable-predicates.pl) | Relations selected and renamed through data bindings |
| [record-scopes.pl](record-scopes.pl) | Distinct per-rule structured witnesses |
| [sudoku.pl](sudoku.pl) | A 9x9 Sudoku solved by backtracking, most constrained cells first |
| [good-cobbler.pl](good-cobbler.pl) | Trade-specific classification from structured descriptions |
| [peano.pl](peano.pl) | Symbolic arithmetic, relational addition and a chained derivation |
| [expression-eval.pl](expression-eval.pl) | Recursive expression graphs used in forward inference |
| [complex.pl](complex.pl) | Complex arithmetic, exact over Gaussian integers and polar beyond them |
| [modexp.pl](modexp.pl) | Exact modular exponentiation by repeated squaring |
| [concept-alignment.pl](concept-alignment.pl) | Vocabulary alignment and reporting rollups |
| [interval-relations.pl](interval-relations.pl) | All thirteen interval relations and endpoint completion |
| [bayes-diagnosis.pl](bayes-diagnosis.pl) | Normalized probabilities for illustrative printer faults |
| [policy-risk.pl](policy-risk.pl) | Ranked findings with explanations and suggested mitigations |
| [queens.pl](queens.pl) | Configurable N-queens search with diagonal constraints |
| [age.pl](age.pl) | Calendar-year and elapsed-day age checks at an explicit reference date |
| [ackermann.pl](ackermann.pl) | The Ackermann function through the hyperoperation sequence, exactly |
| [peasant.pl](peasant.pl) | Peasant multiplication and exponentiation by halving and doubling |
| [padovan.pl](padovan.pl) | The Padovan sequence and its convergence on the plastic ratio |
| [sieve.pl](sieve.pl) | The sieve of Eratosthenes over an explicit list of integers |
| [goldbach.pl](goldbach.pl) | Goldbach splits of every power of two up to 2^25 |
| [kaprekar.pl](kaprekar.pl) | Every four-digit Kaprekar routine reaches 6174 within seven steps |
| [easter.pl](easter.pl) | Easter Sunday by the anonymous Gregorian algorithm, 2021 to 2050 |
| [turing.pl](turing.pl) | A Turing machine interpreter running a binary incrementer |
| [zebra.pl](zebra.pl) | The zebra puzzle solved by narrowing five partially known houses |
| [four-color.pl](four-color.pl) | Four-colouring the map of the European Union |
| [wolf-goat-cabbage.pl](wolf-goat-cabbage.pl) | The river crossing, with seven crossings shown to be minimal |
| [monkey-bananas.pl](monkey-bananas.pl) | Every plan of up to five moves that gets the monkey the bananas |

`integrity.pl` intentionally exits with code 65 because it concludes `false`.
Its proof-check report is valid: the certificate explains why the constraint was
violated. Negation and collection examples list their `absent` and `collected`
obligations in the check report; `--strict-proof` rejects those obligations.
Every check file includes `condition/4` facts for C1-C7, verification counts and
a `verdict/1` fact. Reports with failures include `failure/3`; reports with
trusted boundaries include `obligation/3`. Add `--json` to the check command
for JSON output instead of Prolog facts.

`fibonacci.pl` answers F(0), F(1), F(10), F(100), F(1000) and F(10000), the
last a 2090-digit integer, then divides successive values to watch the ratio
converge on the golden ratio. It uses fast doubling, which halves the index at
each recursive step and fits within the default reasoning limits. Its saved
proof records the arithmetic and recursive clause instances without trusted
obligations.

The `deep-taxonomy` examples are the deep-taxonomy benchmark: one individual, a
chain of subclass rules, and two sibling branches at every level that lead
nowhere. The goal has to follow the single productive branch the whole way
down, so the chain length is also the backward recursion depth. The five sizes
run from ten to a hundred thousand levels, and each costs exactly one
resolution step per level, which `--stats` reports and the saved check report
confirms: `deep-taxonomy-100000` verifies 100001 steps. Backward search is an
explicit machine, so the depth costs heap rather than host stack.

```sh
node bin/eyel.js --stats examples/deep-taxonomy-100000.pl
```

These are among the largest artifacts in the corpus: the hundred-thousand-level
source is about 10 MB and its certificate about 14 MB, since a certificate
records every step it claims. Only `padovan.pl` has a larger one, at about
22 MB, because each of its steps carries integers hundreds of digits long.
Running `npm test` or `npm run examples:update` spends much of its time on these
two examples.

`path-discovery.pl` contains 7,698 airport records and 37,505 directed
connections. Its default goal finds three routes from Ostend to Prague with
at most two stopovers. Use any airport-name atoms and a nonnegative integer
limit with `path_discovery(From, To, MaxStopovers, Path)`:

```sh
node bin/eyel.js --goal "path_discovery('Liège Airport', 'Václav Havel Airport Prague', 1, Path)" examples/path-discovery.pl
node bin/eyel.js --proof --goal "path_discovery('Ostend-Bruges International Airport', 'Liège Airport', 0, Path)" examples/path-discovery.pl > /tmp/route-proof.pl
node bin/eyel.js --strict-proof --check-proof /tmp/route-proof.pl examples/path-discovery.pl
```

`--goal` replaces the default goal. Zero stopovers allows only direct flights;
N stopovers allows at most N+1 flights. Routes follow the recorded direction
and never repeat an airport. Equal endpoints and unknown names return no
routes. Negative or noninteger limits also return no routes. You can leave
`From` or `To` as a variable to discover endpoints; keep `MaxStopovers` bound.
List the available names with `--goal "airport(Id, Name)"`. These are historical
network records, rather than current flight schedules. The search uses explicit
disequalities to prevent cycles, so its proofs have no trusted obligations.
Large bounds on a dense network may still reach the configured reasoning limits.

`peano.pl` represents natural numbers as `zero`, `s(zero)`, and so on. Its
addition goal enumerates every split of a known sum, and a second goal chains
all three relations: `(1*2)+3` is 5, whose factorial is 120 nested successors.
`expression-eval.pl` evaluates a graph for `(2*3)+(10-4)` and emits
`result(example, 12)`.
`concept-alignment.pl` rolls up five concepts to a shared reporting class,
including a source concept reached through multiple broader links.

`complex.pl` adds a numeric domain the engine knows nothing about. A complex
number is the ordinary term `complex(Real, Imaginary)`, and addition,
multiplication, conjugation, division, norm, modulus and integer powers are all
ordinary clauses over integer arithmetic. Components stay exact wherever the
arithmetic allows it: dividing `complex(-5, 10)` by `complex(1, 2)` recovers
`complex(3, 4)` as integers because the norm divides both parts, while the same
division applied to `complex(3, 4)` yields the float pair `complex(2.2, -0.4)`.
The example also derives `i*i = -1` from the multiplication clause rather than
assuming it, confirms that the Gaussian norm is multiplicative, and raises
`complex(1, 1)` to the eighth power by repeated squaring.

Polar form then leaves the integers altogether, so a complex number can be
raised to a complex power. The square root of -1 is `i`, `e` to the power `i*pi`
is -1, `i` to the power `i` is the real number 0.20787957635076193, and the
inverse sine and cosine of 2 are complex. Logarithm, sine, cosine, tangent and
arctangent follow, each applied to the answer of its own inverse so the
round trip is visible: the sine of the arcsine of 2 comes back as 2. The example
passes strict proof checking, so every component of every conclusion is
recomputed by the checker:

```sh
node bin/eyel.js --goal "complex_power(complex(1, 1), 16, Result)" examples/complex.pl
node bin/eyel.js --goal "complex_div(complex(1, 0), complex(0, 1), Inverse)" examples/complex.pl
```

`modexp.pl` handles billion-sized exponents by repeated squaring without
constructing the full power. Supply an integer base, a nonnegative integer
exponent and a positive integer modulus. `queens.pl` returns the first solution
for an 8x8 board by default; another goal enumerates other board sizes:

```sh
node bin/eyel.js --goal "mod_pow(7, 1000000000, 1000000007, Result)" examples/modexp.pl
node bin/eyel.js --goal "queens(4, Columns)" examples/queens.pl
node bin/eyel.js --goal "add(A, B, s(s(s(zero))))" examples/peano.pl
```

`sudoku.pl` solves the 9x9 puzzle from Wikipedia's Sudoku article with nothing
but backtracking. The given digits are placed first, then the blanks that see
the most givens, so the search meets contradictions early: it takes about
136,000 inferences, against 586,000 when the blanks are filled in row order. Each blank is
checked only against the cells placed before it in its row, column or box, and
that plan is worked out once before the search starts. Every check is
arithmetic, so the proof passes strict checking without trusted obligations. It
is also one of the larger certificates, about 13 MB, because each step of the
plan carries the lists it walks.

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
obligations, and policy findings also expose absence obligations.

`age.pl` checks whether a person's age strictly exceeds `years(N)` or `days(N)`.
It uses `as_of(date(2026, 10, 1))` for reproducible output and proofs. Edit that
fact to change the default date, or pass a reference date directly:

```sh
node bin/eyel.js examples/age.pl
node bin/eyel.js --goal "age_above(pat_h, years(80), date(2024, 8, 22))" examples/age.pl
node bin/eyel.js --goal "age_days(pat_h, date(2026, 10, 1), Days)" examples/age.pl
```

Exactly on the threshold anniversary, `age_above/3` fails; it succeeds on the
following day. A February 29 anniversary falls on February 28 in a non-leap
year. Elapsed days follow the Gregorian calendar, including century leap-year
rules. Invalid dates, future births, unknown people, and negative or noninteger
thresholds return no answers. Reference dates are explicit source data rather
than clock readings, and the example passes strict proof checking.

The classics from `ackermann.pl` to `monkey-bananas.pl` are written without a
library. Relations such as `between/3`, `member/2` or `length/2` are defined in
each program as ordinary clauses, and a search commits with `once/1`, or with
guards that make its alternatives exclusive, where Prolog would use cut.

`ackermann.pl` computes A(4, 2), a number with 19,729 digits, through the
hyperoperation sequence: addition, multiplication and exponentiation have closed
forms, and every higher level is the one below it iterated. `peasant.pl`
multiplies and raises to powers using only halving, doubling and addition, and
`padovan.pl` follows the Padovan sequence to its 3674th value before showing
successive ratios converge on the plastic ratio, about 1.3247. `sieve.pl` lists
the primes below 100 by striking out multiples from an explicit list; it stops
there because its certificate records every intermediate list, which grows far
faster than the answer.

`goldbach.pl` splits every power of two from 4 to 2^25 into two primes, taking
the split with the smallest prime. `easter.pl` dates Easter Sunday for 2021 to
2050 with the anonymous Gregorian algorithm, every step integer arithmetic on
the year. `turing.pl` is a Turing machine interpreter running a machine that
adds one to a binary number.

`zebra.pl` solves Einstein's riddle by narrowing a list of five partially known
houses with unification alone. `four-color.pl` colours the 27 countries of the
European Union so that no neighbours share a colour. `wolf-goat-cabbage.pl`
shows that a safe crossing takes seven trips and that no shorter one exists,
then prints both seven-trip plans. `monkey-bananas.pl` lists every plan of up
to five moves that gets the monkey the bananas, shortest first.

Certificates that lean on a completed search say so. In `kaprekar.pl` the whole
verification sits inside one negation, so its certificate is two steps plus an
`absent` obligation: the exhaustive check over 705 digit multisets is exactly
what the obligation names. `four-color.pl` collects the countries with
`findall/3` and rules out conflicts with negation, so it carries both kinds.

Run `npm test` for the full suite or `npm run test:examples` for this corpus.
Every example runs through the API and all three CLI modes. The test log prints
`[current/total]` and the name of each test before executing it. Tests compare
results with saved artifacts and do not overwrite them.

After an intentional behavior change, run `npm run examples:update` and review
the source and artifact changes together. When adding an example, register its
name, description, expected halt code (if any) and proof obligations in
[manifest.json](manifest.json), then generate its artifacts.
