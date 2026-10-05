# Backward

*Two ways of reasoning in one tiny program: pushing facts forward, and asking questions backward.*

[backward.pl](../backward.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=backward)

---

## The question

Is 5 more interesting than 3? Here "more interesting" just means "bigger".

The real point is *how* Eyedia gets there. It can reason in two directions:

- **forward**: start from what is known and keep adding conclusions;
- **backward**: start from a question and work back to what would answer it.

This example uses both, one inside the other.

---

## What we tell Eyedia

One definition and one rule:

```prolog
more_interesting(X, Y) :- X > Y.
indeed_more_interesting(5, 3) :+ more_interesting(5, 3).
```

- `:-` is a **backward definition**: X is more interesting than Y *if* X > Y.
  Eyedia only uses it when some question needs it.
- `:+` is a **forward rule**: if 5 is more interesting than 3, then record
  that it is *indeed* more interesting.

---

## How the two directions meet

To fire the forward rule, Eyedia needs to know whether
`more_interesting(5, 3)` holds. It does not look that up in a table; it
*asks*, using the backward definition.

That definition in turn asks a built-in question: is `5 > 3`? A **built-in**
is a calculation the language does itself, such as comparing numbers.

---

## What Eyedia concludes

```prolog
indeed_more_interesting(5, 3).
```

One new fact, produced by the forward rule. The backward definition did its
work behind the scenes, and it shows up in the proof instead.

---

## Why: the proof in plain words

The saved proof has three steps:

1. 5 is indeed more interesting than 3 — *rule 2*, because…
2. 5 is more interesting than 3 — *rule 1, with X = 5 and Y = 3*, because…
3. 5 > 3 — *a built-in comparison*.

The forward step and the backward steps sit in one chain, each naming the
program line it used.

---

## Checked, not just claimed

A separate checker reads the proof against the program:

- the 2 steps that cite a program line really are instances of that line;
- the 1 built-in step, `5 > 3`, is recomputed and agrees;
- there is no circular reasoning, and nothing in the proof is extra.

Verdict: **checked**. All 3 steps verified, 1 claim answered, nothing taken
on trust.

---

## Try it

```sh
node bin/eyedia.js examples/backward.pl
node bin/eyedia.js --proof examples/backward.pl
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=backward).
In the last line, change both `(5, 3)` to `(3, 5)`: since 3 > 5 is false,
Eyedia concludes nothing and prints nothing.

---

## Takeaway

Forward rules build up what is known; backward definitions answer questions
on demand. Eyedia lets you mix them freely, and the proof stitches both into
one readable chain of reasons.
