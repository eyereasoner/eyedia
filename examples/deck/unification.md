# Unification

*Matching shapes: how Eyedia fills in the blanks by fitting patterns together.*

[unification.pl](../unification.pl) · [output](../output/unification.pl) · [proof](../proof/unification.pl) · [check](../check/unification.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=unification)

---

## The question

**Unification** is pattern matching with blanks on both sides. Put two
patterns side by side, and find values for the blanks that make them
identical — or find that none exist.

Three small puzzles:

- Which ways can the list `[a, b]` be split into a front and a back?
- Does `pair(same, same)` fit the pattern "a pair of two equal things"?
- What are the first item and the rest of `[a, b, c]`?

---

## What we tell Eyedia: the patterns

```prolog
append([], Ys, Ys).
append([X|Xs], Ys, [X|Zs]) :- append(Xs, Ys, Zs).
matching_pair(pair(X, X)).
head_tail([Head|Tail], Head, Tail).
```

- `append(A, B, C)`: list C is A followed by B.
- `[X|Xs]` means "a list whose first item is X and whose rest is Xs".
- `pair(X, X)` uses the same blank twice, so both halves must be equal.

---

## What we tell Eyedia: the questions

```prolog
true :+ append(Prefix, Suffix, [a,b]).
true :+ matching_pair(pair(same, same)).
true :+ head_tail([a,b,c], Head, Tail).
```

Capitalised names are blanks (**variables**). In the first question, both
the front and the back are unknown; only the whole list is given.

---

## What Eyedia concludes

```prolog
append([], [a, b], [a, b]).
append([a], [b], [a, b]).
append([a, b], [], [a, b]).
matching_pair(pair(same, same)).
head_tail([a, b, c], a, [b, c]).
```

- `[a, b]` splits three ways: nothing + `[a, b]`, `[a]` + `[b]`,
  `[a, b]` + nothing.
- `pair(same, same)` fits the pattern.
- The first item of `[a, b, c]` is `a`, and the rest is `[b, c]`.

---

## Why: the proof in plain words

Take the split `[a]` + `[b]`:

1. `[a]` followed by `[b]` is `[a, b]` — *rule 2, with X = a, Xs = [],
   Ys = [b], Zs = [b]*; it peels off the `a` and asks about the rest…
2. `[]` followed by `[b]` is `[b]` — *fact 1, with Ys = [b]*.

And for the pair: *fact 3, with X = same* — one value fills both blanks.
Each step records exactly which values filled which blanks.

---

## Checked, not just claimed

The proof has 8 steps behind the 5 answers. The checker confirms that each
step really is the line it cites with those values filled in — that is the
heart of unification, so it is the heart of the check.

There is no arithmetic to recompute here, and nothing circular or extra.

Verdict: **checked**. All 8 steps verified, nothing taken on trust.

---

## Try it

```sh
node bin/eyedia.js examples/unification.pl
node bin/eyedia.js --proof examples/unification.pl
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=unification).
Add `true :+ append(X, [c], [a,b,c]).` and run again: Eyedia works out what
comes before `[c]`, and adds `append([a, b], [c], [a, b, c])`.

---

## Takeaway

Unification is how a logic program fills in its blanks. Because each filled
blank is written into the proof, you can see — and a checker can confirm —
exactly how every answer was matched.
