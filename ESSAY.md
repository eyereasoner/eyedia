# eyel: Make reasoning something you can see

There is a particular kind of satisfaction in understanding why something is
true. You can follow the steps. You can point to the assumptions. You can change
one fact and see what follows. The result becomes something you can work with:
explain it to a colleague, challenge it, improve it, and build on it.

Eyel brings that experience to programming. You write facts and rules in
Prolog syntax, ask questions, and derive conclusions. When you need an
explanation, the language can produce a proof. When you receive a proof, you can
check it against the program that gives it meaning.

That is a compelling place to begin: a language in which an answer can arrive
with the reasoning that supports it.

Start with something small:

```prolog
human(socrates).
mortal(X) :+ human(X).
```

Two lines express a fact and a rule. Eyel derives `mortal(socrates)`. Its proof
records the source fact, the rule, and the substitution that connects them. You
can see the entire argument. You can understand the whole program before you
have finished your first cup of coffee.

The same experience extends to questions that matter in everyday work. Which
records satisfy a policy? Which concepts belong to a reporting category? Which
events lead to an account balance? Which route connects two airports within a
stopover budget? Has a person exceeded a particular age on a particular date?
Each question invites you to make the relevant knowledge explicit.

That act is already useful. Writing a rule asks you to choose what you mean.
Writing a fact asks you to identify what you know. Writing a query asks you to
state what you want to learn. A program becomes a place where a team's
understanding can take a precise, inspectable form.

Eyel gives that understanding two ways to move. Forward rules, written with
`:+`, materialize consequences until they reach a fixpoint. Backward rules,
written with `:-`, define relations that are explored when a question calls
them. A forward rule can use a backward definition, and a backward query can
use facts established by forward reasoning.

You can let knowledge accumulate and then ask a focused question about it.

```prolog
parent(alice, bob).
parent(bob, carol).

ancestor(X, Y) :+ parent(X, Y).
ancestor(X, Z) :+ ancestor(X, Y), parent(Y, Z).

related(X, Y) :- ancestor(X, Y).
related(X, Y) :- ancestor(Y, X).

?- related(alice, carol).
```

The closure establishes ancestry. The query expresses the relationship you
want to inspect. Each part has a clear job, and the language lets them compose.
The [expression evaluator](examples/expression-eval.pl) uses that same
combination to evaluate a graph recursively and publish its result through a
forward rule. A modest vocabulary reaches surprisingly far.

This is one of eyel's most encouraging qualities. Its core stays small while
the programs become interesting. Lists, compound terms, variables, recursive
clauses, and arithmetic provide materials you can combine into your own
representations. An expression can be a graph of nodes. An event can carry an
identifier and a previous state. A quoted statement can be a structured term.
A proposed mitigation can appear alongside the finding it addresses.

You have room to give your domain a vocabulary that people can read.

The examples show how much can grow from those materials. The
[airport search](examples/path-discovery.pl) works with thousands of airports
and tens of thousands of directed connections. Change the endpoints and the
maximum stopovers, and ask another question of the same network. The
[interval example](examples/interval-relations.pl) distinguishes all thirteen
basic interval relations. The [policy example](examples/policy-risk.pl) carries
scores, ranks, reasons, and suggested changes into its conclusions.

These programs offer starting points for your own work. Read one, change a
fact, run it, and inspect the consequences. Add a clause. Ask a more specific
question. Each experiment can teach you something about both the language and
the problem you are trying to describe.

Computation has its place here too. The [Fibonacci example](examples/fibonacci.pl)
computes F(10000), an exact integer with 2,090 digits, using fast doubling. The
[modular exponentiation example](examples/modexp.pl) handles a billion-sized
exponent through repeated squaring. The [queens program](examples/queens.pl)
expresses a search through ordinary recursive clauses and diagonal checks.

These examples make an enjoyable point about small languages: a good algorithm
can be expressed clearly, and the arithmetic and clause instances behind its
answer can become part of a checkable derivation. You can learn the algorithm
and inspect the evidence in the same place.

Proof checking makes that evidence more useful. Eyel's checker follows the
recorded derivation against the supplied source program. It checks rule
resolution, acyclicity, justifications, coverage, and pure primitive results
under conditions C1 through C5. It recomputes primitive operations and checks
that a rule's premises and conclusion agree under one substitution.

The checker works from the certificate. Missing reasoning has to be supplied
by the certificate's producer. This gives the person receiving a result a
concrete procedure for examining its support.

The result is still rooted in your chosen facts and rules. A checked derivation
establishes what follows from that source; the quality of the model and its
input data remains a responsibility you can discuss and review. This makes the
conversation precise. You can ask whether the inference is valid, whether the
rule expresses the intended policy, and whether the source fact is accurate.
Those questions have identifiable places to land.

Eyel also gives absence and collection visible places in that conversation.
Their certificates carry explicit obligations, and strict checking rejects
proofs that depend on them. A report can tell you exactly where a conclusion
relies on a completed search for missing facts or collected answers. That
visibility helps you decide whether the evidence fits the task.

Even the check report is ordinary Prolog data. Conditions, counts, obligations,
and verdicts can be loaded and queried. One program's evidence becomes material
another program can inspect. It is easy to imagine a workflow that accepts
only certain verdicts, collects unresolved obligations, or attaches a verified
derivation to a generated report.

You can try the whole cycle immediately:

```sh
node bin/eyel.js --proof examples/socrates.pl |
  node bin/eyel.js --strict-proof --check-proof - examples/socrates.pl
```

The repository runs with Node.js 18 or newer, without an install or build step.
The runtime has no package dependencies. The JavaScript API lets you embed the
same reasoning and checking in an application. There is very little ceremony
between having a question and trying to express it.

The [example collection](examples/README.md) makes that invitation tangible.
Each program comes with saved conclusions, a proof, and a C1–C5 check report.
The test suite reproduces those artifacts and exercises the command-line
interface. You can study the source beside its results, then review both when
you make a change. An example becomes a small, repeatable experiment.

That is a useful way to develop a language, and a useful way to develop ideas.
Make the claim concrete. Show the reasoning. Preserve the example. Keep the
checks close enough that anyone working on the project can run them.

Perhaps you have a policy scattered across several documents. Perhaps a graph
contains relationships you keep tracing by hand. Perhaps a calculation needs
an explanation that can travel with its result. Begin with one question and a
few facts. Give the relationships names. Write the rules you already believe.
Then let the program show you what they imply.

The first answer may be small. The first unexpected answer may be even more
valuable: it gives you a specific rule or assumption to revisit. As the model
grows, you accumulate a body of executable knowledge that you can inspect,
test, and explain.

Eyel's promise is practical and inviting: you can build programs whose
conclusions come with a story precise enough to check. Start with a question
you care about. Write down what you know. See what follows.
