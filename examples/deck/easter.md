# Easter

*Thirty years of Easter Sundays, worked out by pure arithmetic.*

[easter.pl](https://github.com/eyereasoner/eyedia/blob/main/examples/easter.pl) · [output](https://github.com/eyereasoner/eyedia/blob/main/examples/output/easter.pl) · [proof](https://github.com/eyereasoner/eyedia/blob/main/examples/proof/easter.pl) · [check](https://github.com/eyereasoner/eyedia/blob/main/examples/check/easter.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=easter)

---

## The question

Easter moves around: it falls on the first Sunday after a church-defined
"full moon" in spring, so it can land anywhere from late March to late April.

Long before computers, people found a way to get the date with nothing but
whole-number arithmetic on the year. One famous recipe is the **anonymous
Gregorian algorithm** (also known as Meeus/Jones/Butcher).

**When is Easter Sunday in each year from 2021 to 2050?**

---

## What we tell Eyedia: the recipe

```prolog
computus(Year, [Month, Day]) :-
    A is Year rem 19,
    B is Year//100,
    C is Year rem 100,
    D is (19*A+B-B//4-((B-(B+8)//25+1)//3)+15) rem 30,
    E is (32+2*(B rem 4)+2*(C//4)-D-(C rem 4)) rem 7,
    F is D+E-7*((A+11*D+22*E)//451)+114,
    Month is F//31,
    Day is F rem 31+1.
```

`//` is whole-number division and `rem` is the remainder. **Computus** is the
traditional name for computing the date of Easter.

---

## What we tell Eyedia: which years

```prolog
in_range(Low, High, Low) :- Low =< High.
in_range(Low, High, N) :- Low < High, Next is Low+1, in_range(Next, High, N).

easter(Year, Date) :+ in_range(2021, 2050, Year), computus(Year, Date).
```

`in_range` counts from 2021 up to 2050, one year at a time. The last line
says: for every year in that range, the Easter date is what the recipe gives.

---

## What Eyedia concludes

```prolog
easter(2021, [4, 4]).
easter(2022, [4, 17]).
easter(2023, [4, 9]).
easter(2024, [3, 31]).
easter(2025, [4, 20]).
easter(2026, [4, 5]).
% …
easter(2050, [4, 10]).
```

One line per year, 30 in all. `[4, 4]` means April 4; `[3, 31]` means
March 31.

---

## Why: the proof in plain words

Take 2021. The proof records every intermediate number:

1. 2021 is in the range — *it is the starting year, 2021 ≤ 2050*.
2. A = 2021 rem 19 = 7, B = 2021 // 100 = 20, C = 2021 rem 100 = 21.
3. D = 7, E = 6, F = 127 — *the long formulas, with these values filled in*.
4. Month = 127 // 31 = 4, Day = 127 rem 31 + 1 = 4.
5. So Easter 2021 is April 4 — *the `easter` rule, with Year = 2021*.

For later years, the proof also shows the counting: 2022 is in range because
2021 < 2050 and 2021 + 1 = 2022, and so on.

---

## Checked, not just claimed

The checker re-does every sum itself rather than trusting the proof's numbers.

- **818 steps** for 30 answers: 525 verified against the program lines they
  cite, and **293 calculations recomputed** and found to agree.
- No circular reasoning, nothing unjustified, nothing extra.
- **0** steps taken on trust.

Verdict: **checked**.

---

## Try it

```sh
node bin/eyedia.js examples/easter.pl            # the 30 dates
node bin/eyedia.js --proof examples/easter.pl    # with every calculation
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=easter).
Change the range in the last line to `in_range(2000, 2000, Year)` and run
again: you get `easter(2000, [4, 23])`, April 23.

---

## Takeaway

A centuries-old calendar recipe becomes a list of dates where each one comes
with its own worked arithmetic, recomputed by an independent checker.
