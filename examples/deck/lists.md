# Lists

*Joining, squaring and adding up lists — one small step at a time.*

[lists.pl](https://github.com/eyereasoner/eyedia/blob/main/examples/lists.pl) · [output](https://github.com/eyereasoner/eyedia/blob/main/examples/output/lists.pl) · [proof](https://github.com/eyereasoner/eyedia/blob/main/examples/proof/lists.pl) · [check](https://github.com/eyereasoner/eyedia/blob/main/examples/check/lists.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=lists)

---

## The question

Lists are everywhere: a shopping list, a playlist, a row of numbers.
Three everyday jobs:

- **Join** `[a, b]` and `[c, d]` into one list.
- **Square** every number in `[1, 2, 3, 4]`.
- **Add up** `[1, 2, 3, 4]`.

Eyedia has no special list commands for these. Can we define them from
scratch — and see each step?

---

## The idea: first item, then the rest

Every list is either *empty*, or a *first item followed by the rest*.
Prolog writes that as `[X|Xs]`: X is the first item, Xs the rest.

So each job needs just two rules:

- what to do with an empty list, and
- what to do with the first item, after handling the rest the same way.

A rule that uses itself on a smaller piece is called *recursive*.

---

## What we tell Eyedia

```prolog
append([], Ys, Ys).
append([X|Xs], Ys, [X|Zs]) :- append(Xs, Ys, Zs).
squares([], []).
squares([X|Xs], [Y|Ys]) :- Y is X*X, squares(Xs, Ys).
sum([], 0).
sum([X|Xs], Total) :- sum(Xs, Rest), Total is X+Rest.
true :+ append([a,b], [c,d], Joined).
true :+ squares([1,2,3,4], Squared).
true :+ sum([1,2,3,4], Total).
```

For example: the sum of an empty list is 0; the sum of a longer list is its
first number plus the sum of the rest. The last three lines ask the
questions.

---

## What Eyedia concludes

```prolog
append([a, b], [c, d], [a, b, c, d]).
squares([1, 2, 3, 4], [1, 4, 9, 16]).
sum([1, 2, 3, 4], 10).
```

Each answer repeats the question with the blank filled in.

---

## Why: the proof in plain words

For the sum, the proof works from the inside out:

1. The sum of `[]` is 0 — *a fact we gave (fact 5)*.
2. The sum of `[4]` is 4 + 0 = 4 — *rule 6*.
3. The sum of `[3, 4]` is 3 + 4 = 7 — *rule 6*.
4. The sum of `[2, 3, 4]` is 2 + 7 = 9 — *rule 6*.
5. The sum of `[1, 2, 3, 4]` is 1 + 9 = 10 — *rule 6*.

Joining and squaring are recorded the same way, one item per step.

---

## Checked, not just claimed

A separate checker read all 21 steps of the proof against the program:

- 13 steps are verified as exact instances of the lines they cite;
- 8 calculations (the four squares and the four additions) are recomputed,
  and they agree;
- no step depends on itself, and every step serves one of the 3 answers.

Verdict: **checked**. Nothing taken on trust.

---

## Try it

```sh
node bin/eyedia.js examples/lists.pl            # the answers
node bin/eyedia.js --proof examples/lists.pl    # with their proof
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=lists).
Add `true :+ append(X, Y, [a,b]).` — asking the question *backward* — and
`append` lists every way to split `[a, b]`: `[]` and `[a, b]`, `[a]` and
`[b]`, `[a, b]` and `[]`.

---

## Takeaway

Two plain rules per job are enough, and the proof follows the list item by
item. Nothing is hidden inside a library: what you read is what ran.
