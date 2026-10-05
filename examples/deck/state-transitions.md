# State transitions

*Replay a bank account's history, one event at a time, to get today's balance.*

[state-transitions.pl](../state-transitions.pl) · [output](../output/state-transitions.pl) · [proof](../proof/state-transitions.pl) · [check](../check/state-transitions.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=state-transitions)

---

## The question

An account opens with 100. Then three things happen, in order: a deposit of
25, a withdrawal of 40, a withdrawal of 20.

**What is the balance after event 3?** And can we see how each event
changed it?

---

## What we tell Eyedia: the history

An **event log** is a numbered list of what happened:

```prolog
opening_balance(100).
event(1, deposit, 25).
event(2, withdraw, 40).
event(3, withdraw, 20).
```

Each balance is a **state**, and each event is a **transition**: a step from
one state to the next.

---

## What we tell Eyedia: the rules

```prolog
balance(0, Amount) :- opening_balance(Amount).
balance(N, Amount) :- N > 0, event(N, deposit, Value), Before is N-1, balance(Before, Previous), Amount is Previous+Value.
balance(N, Amount) :- N > 0, event(N, withdraw, Value), Before is N-1, balance(Before, Previous), Amount is Previous-Value.
true :+ balance(3, Amount).
```

- Before any event, the balance is the opening balance.
- After a deposit, it is the previous balance plus the amount.
- After a withdrawal, it is the previous balance minus the amount.

---

## What Eyedia concludes

```prolog
balance(3, 65).
```

After the three events, the balance is 65.

---

## Why: the proof in plain words

Read from the start of the log:

1. balance 0 is 100 — *the opening balance (rule 5, fact 1)*;
2. event 1 deposits 25, so balance 1 is 100 + 25 = 125 — *rule 6*;
3. event 2 withdraws 40, so balance 2 is 125 − 40 = 85 — *rule 7*;
4. event 3 withdraws 20, so balance 3 is 85 − 20 = 65 — *rule 7*.

The proof also records each small calculation, such as "3 − 1 = 2" for
finding the previous event.

---

## Checked, not just claimed

The proof has 17 steps. The checker found:

- 8 steps that are exact instances of the program lines they cite;
- 9 built-in calculations (the sums, differences and "N > 0" tests) that it
  recomputed and that agree;
- no circular reasoning: each balance rests only on the one before it.

Verdict: **checked**. All 17 steps verified, nothing taken on trust.

---

## Try it

```sh
node bin/eyedia.js examples/state-transitions.pl
node bin/eyedia.js --proof examples/state-transitions.pl
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=state-transitions).
Add `event(4, deposit, 10).` and change the last line to ask for
`balance(4, Amount)`: the answer becomes `balance(4, 75)`.

---

## Takeaway

An audit trail you can trust: the final number comes with every
intermediate balance and every calculation that led to it, each one
rechecked.
