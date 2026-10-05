# Complex numbers

*Teaching a reasoner a kind of number it has never heard of.*

[complex.pl](../complex.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=complex)

---

## The question

A *complex number* is a pair of ordinary numbers, a real part and an
imaginary part, written here as `complex(3, 4)` for 3 + 4i. The special
number i has the property that i × i = −1. Engineers use these for waves,
circuits and rotations.

Eyedia has no complex numbers built in. **Can we define them with a few
rules, and get answers that are both right and explained?**

---

## What we tell Eyedia

How to add and multiply pairs, as ordinary rules:

```prolog
complex_add(complex(A, B), complex(C, D), complex(R, I)) :- R is A+C, I is B+D.
complex_mul(complex(A, B), complex(C, D), complex(R, I)) :- R is A*C-B*D, I is A*D+B*C.

point(z, complex(3, 4)).
point(w, complex(1, 2)).

sum(Sum) :+ point(z, Z), point(w, W), complex_add(Z, W, Sum).
product(Product) :+ point(z, Z), point(w, W), complex_mul(Z, W, Product).
unit_square(Square) :+ complex_mul(complex(0, 1), complex(0, 1), Square).
% …
```

Division, powers, polar form, logarithms, sine and cosine follow the same way.

---

## What Eyedia concludes

A few of its 23 answers:

```prolog
sum(complex(4, 6)).
product(complex(-5, 10)).
quotient(complex(3, 4)).
ratio(complex(2.2, -0.4)).
unit_square(complex(-1, 0)).
integer_power(8, complex(16, 0)).
power(self_power, complex(0.20787957635076193, 0.0)).
sine(complex(1.9999999999999998, 1.0605752387249067e-16)).
```

…and 15 more.

---

## Reading the answers

- **i × i = −1** (`unit_square`) is *derived* from the multiplication rule,
  not assumed.
- Dividing the product by w gives back z **exactly** as whole numbers;
  dividing z by w does not divide evenly, so it becomes decimals (2.2, −0.4).
- Multiplying by 1 + i eight times lands on 16, back on the real line.
- i to the power i is the ordinary number 0.2078…
- The sine of the arcsine of 2 comes back as 1.9999999999999998: decimal
  arithmetic on a computer is very close, but not perfectly exact.

---

## Why: the proof in plain words

Take `product(complex(-5, 10))`:

1. z is 3 + 4i and w is 1 + 2i — *facts we gave*.
2. The multiplication rule, with A = 3, B = 4, C = 1, D = 2, says the result
   is (3·1 − 4·2) + (3·2 + 4·1)i.
3. 3·1 − 4·2 = −5 and 3·2 + 4·1 = 10 — *each a calculation, recorded*.

Every one of the 23 answers has a trail like this.

---

## Checked, not just claimed

The checker reads the proof against the program:

- **93** steps are instances of the program lines they cite;
- **122** calculations are redone by the checker itself, every part of every
  number, and agree;
- no circular reasoning, nothing extra, every answer accounted for.

Verdict: **checked**. All 215 steps verified, nothing taken on trust.

---

## Try it

```sh
node bin/eyedia.js examples/complex.pl
node bin/eyedia.js --goal "complex_power(complex(1, 1), 16, Result)" examples/complex.pl
node bin/eyedia.js --goal "complex_div(complex(1, 0), complex(0, 1), Inverse)" examples/complex.pl
```

These give `complex(256, 0)` and `complex(0, -1)` (so 1 / i = −i).
Change `turns(8).` to `turns(4).`: the answer becomes
`integer_power(4, complex(-4, 0))`, half-way round.

---

## Takeaway

A new kind of number is just a handful of rules. Because every calculation is
recorded and redone by the checker, you can see exactly where results stay
exact and where decimals creep in.
