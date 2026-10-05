# Schema Inference

*A few general statements about categories and relations, and the facts that follow from them.*

[schema-inference.pl](../schema-inference.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=schema-inference)

---

## The question

Data on the web often comes with a *schema*: general statements about what
the data means. "Every cat is a mammal." "If someone is a parent of
someone, they are related." "Only people can be parents."

Given a schema and a couple of plain facts — Koko is a cat; Alice is
Bob's parent —

**what else can we safely conclude?** And can each conclusion be traced
back to the statements it came from?

---

## Four kinds of schema statement

- **Subclass** — every member of one category is in another: cat ⊂ mammal.
- **Subproperty** — one relation implies a broader one: `parent_of`
  implies `related_to`.
- **Domain** — whoever is *on the left* of a relation is of some kind:
  whoever is a `parent_of` is a person.
- **Range** — whoever is *on the right* is of some kind: whoever has a
  parent is a person.

These are the core ideas of the web's RDF Schema, written here as ordinary
rules.

---

## What we tell Eyedia

```prolog
subclass(cat, mammal).
subclass(mammal, animal).
subproperty(parent_of, related_to).
domain(parent_of, person).
range(parent_of, person).
type(koko, cat).
triple(alice, parent_of, bob).

subclass(A, C) :+ subclass(A, B), subclass(B, C).
type(X, B) :+ type(X, A), subclass(A, B).
triple(S, Q, O) :+ triple(S, P, O), subproperty(P, Q).
type(S, Class) :+ triple(S, P, _), domain(P, Class).
type(O, Class) :+ triple(_, P, O), range(P, Class).
```

`:+` means "keep applying this until nothing new follows". No question is
asked, so Eyedia reports everything new.

---

## What Eyedia concludes

```prolog
subclass(cat, animal).
type(koko, animal).
type(koko, mammal).
triple(alice, related_to, bob).
type(alice, person).
type(bob, person).
```

Six new facts, none of them typed in:

- cats are animals, so Koko is a mammal *and* an animal;
- Alice is related to Bob;
- both Alice and Bob are people — nobody said so directly.

---

## Why: the proof in plain words

Each conclusion cites the rule and facts behind it:

1. Cat ⊂ mammal and mammal ⊂ animal, so cat ⊂ animal — *rule 8*.
2. Koko is a cat, and cat ⊂ animal, so Koko is an animal — *rule 9*.
3. Alice is Bob's parent, and `parent_of` implies `related_to`, so Alice
   is related to Bob — *rule 10*.
4. Alice is a parent, and parents are people — *rule 11* (domain).
5. Bob has a parent, and those are people too — *rule 12* (range).

Step 2 builds on step 1: one conclusion feeds the next.

---

## Checked, not just claimed

A separate checker read all 13 proof steps against the program and
confirmed that:

- each step is an exact instance of the rule or fact it cites (13 of 13);
- no conclusion depends on itself in a circle;
- every step serves one of the 6 conclusions, and nothing extra is included.

Verdict: **checked**. Nothing taken on trust.

---

## Try it

```sh
node bin/eyedia.js examples/schema-inference.pl            # the new facts
node bin/eyedia.js --proof examples/schema-inference.pl    # with their proof
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=schema-inference).

Add `triple(bob, parent_of, carol).` and run again: Bob becomes related to
Carol, and Carol is concluded to be a person.

---

## Takeaway

A schema says a lot in a few lines. Eyedia spells out what it implies, and
every implied fact comes with the exact statements that support it — so a
surprising conclusion can be traced to the schema line that caused it.
