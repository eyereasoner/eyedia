# Expression Evaluation

*Working out (2 × 3) + (10 − 4), and showing every intermediate result.*

[expression-eval.pl](../expression-eval.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=expression-eval)

---

## The question

A formula like **(2 × 3) + (10 − 4)** is really a little tree: the `+` at the
top, a multiplication and a subtraction below it, and plain numbers at the
bottom. Spreadsheets and calculators work through such trees all the time.

**What is the value of this formula?** And can we see how each part was
computed?

---

## What we tell Eyedia: the formula

Every part of the formula gets a name, called a **node**:

```prolog
literal(n2, 2).
literal(n3, 3).
literal(n10, 10).
literal(n4, 4).
expression(product, mul, n2, n3).
expression(difference, sub, n10, n4).
expression(total, add, product, difference).
root(example, total).
```

`product` multiplies `n2` and `n3`; `difference` subtracts `n4` from `n10`;
`total` adds those two. The formula called `example` starts at `total`.

---

## What we tell Eyedia: how to evaluate

```prolog
value(Node, Value) :- literal(Node, Value).
value(Node, Value) :- expression(Node, Operation, Left, Right),
    value(Left, L), value(Right, R), calculate(Operation, L, R, Value).
calculate(add, L, R, Value) :- Value is L+R.
calculate(sub, L, R, Value) :- Value is L-R.
calculate(mul, L, R, Value) :- Value is L*R.
result(Name, Value) :+ root(Name, Node), value(Node, Value).
```

A number's value is itself. An expression's value: evaluate both sides, then
apply the operation. This is **recursion**: a rule that uses itself on
smaller pieces until it reaches plain numbers.

---

## What Eyedia concludes

```prolog
result(example, 12).
```

(2 × 3) + (10 − 4) = 6 + 6 = **12**.

---

## Why: the proof in plain words

The proof follows the tree from the top down, 22 steps in all:

1. `total` is 12, because `product` is 6, `difference` is 6, and 6 + 6 = 12.
2. `product` is 6, because `n2` is 2, `n3` is 3, and 2 × 3 = 6.
3. `difference` is 6, because `n10` is 10, `n4` is 4, and 10 − 4 = 6.
4. Each number's value comes straight from its `literal` fact.

Every step names the program line it used and the values it filled in.

---

## Checked, not just claimed

A separate checker read the proof against the program:

- 19 steps were matched to the exact program line they cite;
- 3 steps are arithmetic (2 × 3, 10 − 4, 6 + 6), and the checker
  **recomputed** each one itself and got the same answer;
- no step depends on itself in a circle, and nothing is extra.

Verdict: **checked**. All 22 steps verified, nothing taken on trust.

---

## Try it

```sh
node bin/eyedia.js examples/expression-eval.pl
node bin/eyedia.js --proof examples/expression-eval.pl
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=expression-eval).
Change `literal(n4, 4).` to `literal(n4, 1).` and run again: the difference
becomes 9 and the answer `result(example, 15).`

---

## Takeaway

Even simple arithmetic is a chain of small steps. When each one is written
down and rechecked, a wrong input is easy to find, and a right answer is
easy to trust.
