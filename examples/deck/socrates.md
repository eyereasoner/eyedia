# Socrates

*The oldest example in logic, with the reasoning written down.*

[socrates.pl](../socrates.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=socrates)

---

## The question

Socrates is human. Every human is mortal.

**Is Socrates mortal?** And, just as important: can the computer show *why*?

---

## What we tell Eyedia

Two facts and one rule, written in Prolog syntax:

```prolog
type(socrates, human).          % Socrates is a human
subclass_of(human, mortal).     % every human is a mortal

type(S, B) :+ type(S, A), subclass_of(A, B).
```

The rule reads: *if S is an A, and every A is a B, then S is a B.*
The `:+` means "keep applying this until nothing new follows".

---

## What Eyedia concludes

```prolog
type(socrates, mortal).
type(socrates, human).
```

The first line is new: nobody typed it in. The second is the fact we gave,
reported back because the program asks for every `type` it knows.

---

## Why: the proof in plain words

Eyedia does not just print the answer; it records how it got there:

1. Socrates is human — *a fact we gave (fact 1)*.
2. Every human is mortal — *a fact we gave (fact 2)*.
3. So Socrates is mortal — *rule 3, with S = socrates, A = human, B = mortal*.

Each step names the exact line of the program it used, and the values it
filled in.

---

## Checked, not just claimed

The proof is a document of its own, and a separate checker reads it against
the program. It confirms, among other things, that:

- every step really is an instance of the line it cites;
- nothing is assumed that the program does not say;
- no step depends on itself in a circle;
- every step serves one of the answers.

Verdict: **checked**. All 3 steps verified, and nothing taken on trust.

---

## Try it

```sh
node bin/eyedia.js examples/socrates.pl            # the answers
node bin/eyedia.js --proof examples/socrates.pl    # answers with their proof
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=socrates).
Add `type(plato, human).` and run again: Plato becomes mortal too, with his
own proof.

---

## Takeaway

A conclusion you can follow step by step, and that a machine has checked,
is one you can explain, question and build on — not just believe.
