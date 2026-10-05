# Reachability

*Where can you get to from here — even when the roads go in circles?*

[reachability.pl](../reachability.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=reachability)

---

## The question

Picture four places, a, b, c and d, joined by one-way roads:

```text
a ──▶ b ──▶ c ──▶ d
▲           │
└───────────┘
```

From a you can drive to b, from b to c, and from c either back to a or on
to d. Nothing leaves d.

**From each place, which places can you reach?** The loop a → b → c → a
means a careless search could go round forever.

---

## What we tell Eyedia

```prolog
edge(a, b).
edge(b, c).
edge(c, a).
edge(c, d).
reachable(X, Y) :+ edge(X, Y).
reachable(X, Z) :+ reachable(X, Y), edge(Y, Z).
```

Four roads, and two rules:

- if there is a road from X to Y, you can reach Y from X;
- if you can reach Y from X, and there is a road from Y to Z, you can reach
  Z from X.

`:+` means "keep applying these until nothing new follows".

---

## What Eyedia concludes

```prolog
reachable(a, b).   reachable(b, c).   reachable(c, a).
reachable(c, d).   reachable(a, c).   reachable(b, a).
reachable(b, d).   reachable(c, b).   reachable(a, a).
reachable(a, d).   reachable(b, b).   reachable(c, c).
```

12 conclusions (shown three per line). From a, b or c you can reach all
four places — including the place you started, by going round the loop.
From d you reach nothing. And the run stops: once no new pair appears,
Eyedia is done.

---

## Why: the proof in plain words

How do we know you can get from a back to a?

1. There is a road a → b — *fact 1*, so a reaches b — *rule 5*.
2. a reaches b, and there is a road b → c — so a reaches c — *rule 6*.
3. a reaches c, and there is a road c → a — so a reaches a — *rule 6*.

Every one of the 12 conclusions has a short chain like this, built only on
the four roads we gave.

---

## Checked, not just claimed

A separate checker read all 16 steps of the proof (the 12 conclusions plus
the 4 road facts) against the program and confirmed that:

- every step is an exact instance of the line it cites (16 of 16);
- even though the roads loop, the *reasoning* never does: no conclusion
  depends on itself;
- every step serves one of the 12 conclusions.

Verdict: **checked**. Nothing taken on trust.

---

## Try it

```sh
node bin/eyedia.js examples/reachability.pl            # the answers
node bin/eyedia.js --proof examples/reachability.pl    # with their proof
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=reachability).
Add a road `edge(d, e).` and run again: there are now 16 conclusions,
because a, b, c and d can all reach e.

---

## Takeaway

A loop in the data does not have to mean a loop in the reasoning. Eyedia
collects every reachable pair, stops when nothing is new, and backs each
pair with a chain that leads straight back to the roads.
