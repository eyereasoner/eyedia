# Leg Length Discrepancy

*From four dots on an X-ray to an alarm — with the reason it fired, and every calculation rechecked.*

[lldm.pl](https://github.com/eyereasoner/eyedia/blob/main/examples/lldm.pl) · [output](https://github.com/eyereasoner/eyedia/blob/main/examples/output/lldm.pl) · [proof](https://github.com/eyereasoner/eyedia/blob/main/examples/proof/lldm.pl) · [check](https://github.com/eyereasoner/eyedia/blob/main/examples/check/lldm.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=lldm)

---

## The question

When one leg is noticeably longer than the other, doctors want to know by
how much. One way is to mark points — *landmarks* — on an X-ray image
(a *radiograph*) and measure between them.

This example takes one measurement, `meas47`, with four landmarks, and asks:

**How long is each leg, how big is the difference, and is it over the
1.25 cm threshold?** If an alarm goes off, it should say *why*.

*(An illustration of reasoning, adapted from the Eyeling example
`lldm.n3` — not a clinical tool.)*

---

## The geometry

- Landmarks 1 and 2 fix a reference line across the image.
- From landmark 3 (left) and 4 (right), drop a perpendicular onto that line.
  Where it lands are two new points, 5 and 6.
- Each leg's length is the distance from 3 to 5, and from 4 to 6.
- The *discrepancy* is left minus right. An alarm fires if it is beyond
  the threshold on either side.

---

## What we tell Eyedia

The measured coordinates, in centimetres, and the threshold:

```prolog
val(meas47, p1xCm, 10.1).
val(meas47, p1yCm, 7.8).
% … landmarks 2, 3 and 4 the same way
threshold(meas47, lld_alarm_threshold_cm, 1.25).
```

Then one rule per intermediate value — 37 in all — such as the final leg
length and the difference:

```prolog
val(M, d53Cm, Z) :- measurement(M), val(M, ssd53Cm2, X), (Z is X ** 0.5).
val(M, dCm, Z) :- measurement(M), val(M, d53Cm, X), val(M, d64Cm, Y), (Z is X - Y).
```

---

## The alarm and its reason

```prolog
alarm(M, 'discrepancy below negative threshold') :- measurement(M), val(M, dCm, D), threshold(M, lld_alarm_threshold_cm, T), (Negt is 0 - T), (D < Negt).
alarm(M, 'discrepancy above threshold') :- measurement(M), val(M, dCm, D), threshold(M, lld_alarm_threshold_cm, T), (D > T).
```

Two rules, one per side. Each carries its own reason, so the output says
which side of the threshold was crossed. (The version this was adapted from
gave the same reason for both.)

---

## What Eyedia concludes

```prolog
type(meas47, lld_alarm).
lld_left_length_cm(meas47, 21.548900464617255).
lld_right_length_cm(meas47, 23.45713444515475).
lld_discrepancy_cm(meas47, -1.9082339805374957).
lld_threshold_cm(meas47, 1.25).
lld_reason(meas47, 'discrepancy below negative threshold').
```

The left leg measures about 21.55 cm, the right about 23.46 cm. The left
is 1.91 cm shorter — past the 1.25 cm limit — so the alarm is raised, with
its reason.

---

## Why: the proof in plain words

The proof walks from the raw dots to the alarm:

1. The slope of the reference line is −0.0629 — *rule 21*.
2. The foot of the left perpendicular, point 5, is at (2.248, 8.294) —
   *rules 35 and 36*.
3. The left leg is √464.355… = 21.5489… cm — *rule 45*.
4. Left minus right is −1.9082… cm — *rule 47*.
5. −1.9082 < −1.25, so the alarm fires with the "below" reason — *rule 48*.

Every intermediate number is its own named value, so each one is visible.

---

## Checked, not just claimed

A separate checker read the proof's 93 steps against the program:

- **54** steps are exact instances of the program lines they cite;
- **39** calculations — subtractions, divisions, squares, square roots, the
  final comparison — were **recomputed** by the checker and agreed;
- no circular reasoning, and every step serves one of the 6 conclusions.

Verdict: **checked**. Nothing taken on trust.

---

## Try it

```sh
node bin/eyedia.js examples/lldm.pl            # the alarm and its reason
node bin/eyedia.js --proof examples/lldm.pl    # with every calculation
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=lldm).

Change the threshold from `1.25` to `2.0` and run again: the output is
empty. A 1.91 cm difference is within that limit, so no alarm — and nothing
to report.

---

## Takeaway

An alarm you cannot question is hard to act on. Here the alarm arrives
with its numbers and its reason, and behind them a proof in which every
step of geometry has been recomputed by an independent checker.
