# The Sieve of Eratosthenes

*A 2,200-year-old recipe for prime numbers, with every crossed-out number on record.*

[sieve.pl](https://github.com/eyereasoner/eyedia/blob/main/examples/sieve.pl) · [output](https://github.com/eyereasoner/eyedia/blob/main/examples/output/sieve.pl) · [proof](https://github.com/eyereasoner/eyedia/blob/main/examples/proof/sieve.pl) · [check](https://github.com/eyereasoner/eyedia/blob/main/examples/check/sieve.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=sieve)

---

## The question

A **prime** is a whole number above 1 that only divides by 1 and itself:
2, 3, 5, 7, 11, …

The Greek scholar Eratosthenes found them like this: write down the numbers
from 2 upwards. Keep the first one, cross out all its multiples. Keep the
next number still standing, cross out its multiples. Repeat.

**Which numbers up to 100 are prime?**

---

## What we tell Eyedia

```prolog
primes(Limit, Primes) :- range(2, Limit, Integers), sift(Integers, Primes).

range(Start, End, []) :- Start > End.
range(Start, End, [Start|Rest]) :- Start =< End, Next is Start+1, range(Next, End, Rest).

sift([], []).
sift([I|Is], [I|Ps]) :- remove(I, Is, New), sift(New, Ps).

remove(_, [], []).
remove(P, [I|Is], Rest) :- 0 =:= I mod P, remove(P, Is, Rest).
remove(P, [I|Is], [I|Rest]) :- 0 =\= I mod P, remove(P, Is, Rest).

true :+ primes(100, _).
```

`range` writes the list 2 … 100. `sift` keeps the first number and has
`remove` cross out its multiples (`I mod P` is the remainder after dividing).

---

## What Eyedia concludes

```prolog
primes(100, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]).
```

The 25 primes below 100, exactly the classic list.

---

## Why: the proof in plain words

The proof replays the whole recipe:

1. The list from 2 to 100 is built one number at a time
   (is 2 ≤ 100? then add 2, and continue from 3 …).
2. 2 is kept; for every later number the remainder after dividing by 2 is
   computed, and the even ones are crossed out.
3. The same with 3 on what is left, then 5, then 7, and so on.

Each "keep" or "cross out" is its own step: 1,173 steps for one answer.

---

## Checked, not just claimed

The checker matched 563 steps to the exact program line they cite, and
**recomputed** the other 610 itself: every comparison and every remainder,
to make sure each one comes out as claimed.

Verdict: **checked**. All 1,173 steps verified, nothing taken on trust.

Why stop at 100? The proof records every intermediate list, so it grows far
faster than the answer: about 325 KB here, and past 100 MB at a limit of
1000.

---

## Try it

```sh
node bin/eyedia.js examples/sieve.pl
node bin/eyedia.js --proof examples/sieve.pl
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=sieve).
Change `primes(100, _)` to `primes(50, _)` and run again: you get the 15
primes up to 47.

---

## Takeaway

An old algorithm becomes a fully audited one: not just "here are the
primes", but every single crossing-out, independently rechecked. The cost
of that honesty is visible too, in the size of the proof.
