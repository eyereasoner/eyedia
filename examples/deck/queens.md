# Eight queens

*Place eight queens on a chessboard so that none can attack another.*

[queens.pl](https://github.com/eyereasoner/eyedia/blob/main/examples/queens.pl) · [output](https://github.com/eyereasoner/eyedia/blob/main/examples/output/queens.pl) · [proof](https://github.com/eyereasoner/eyedia/blob/main/examples/proof/queens.pl) · [check](https://github.com/eyereasoner/eyedia/blob/main/examples/check/queens.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=queens)

---

## The question

In chess, a queen attacks along its row, its column and both diagonals.

**Can you place eight queens on an 8×8 board so that no two attack each
other?** It is a classic puzzle; finding one answer by hand takes patience.

---

## How the board is written

One queen per row, so a placement is just a list of eight column numbers.
The first number is the column of the queen in row 1, and so on.

Because each column is used exactly once, rows and columns are safe
automatically. Only the **diagonals** still need checking.

---

## What we tell Eyedia

```prolog
place([], _, []).
place(Available, Placed, [Column|Rest]) :-
    select(Column, Available, Remaining), safe(Column, Placed, 1),
    place(Remaining, [Column|Placed], Rest).
safe(_, [], _).
safe(Column, [Other|Rest], Distance) :-
    Column =\= Other+Distance, Column =\= Other-Distance,
    Next is Distance+1, safe(Column, Rest, Next).
true :+ once(queens(8, Columns)).
```

Pick a column not used yet, and check it is not on a diagonal with any queen
already placed (`=\=` means "is not equal to"). If no column works, back up
and try another. `once` asks for the first solution only.

---

## What Eyedia concludes

```prolog
once(queens(8, [1, 5, 8, 6, 3, 7, 2, 4])).
```

```text
Q . . . . . . .
. . . . Q . . .
. . . . . . . Q
. . . . . Q . .
. . Q . . . . .
. . . . . . Q .
. Q . . . . . .
. . . Q . . . .
```

---

## Why: the proof in plain words

The proof does not replay the dead ends of the search; it records why
*this* placement works:

1. the columns available are 1 to 8 — *built by rule 3*, counting up;
2. each queen's column is picked from what remains — *the `select` rules*;
3. for each new queen, every earlier queen is checked: not on the same
   diagonal, at distance 1, 2, 3, … — *the `safe` rules* plus arithmetic.

Every one of those diagonal tests is written down.

---

## Checked, not just claimed

The proof has 153 steps behind the one answer. The checker found:

- 77 steps that are exact instances of the program lines they cite;
- 75 built-in calculations (sums, differences, comparisons) that it
  recomputed and that agree;
- 1 `once` step that matches the solution it wraps.

Verdict: **checked**. Nothing taken on trust. Finding the solution took
searching; checking it is simple.

---

## Try it

```sh
node bin/eyedia.js examples/queens.pl
node bin/eyedia.js --goal "queens(4, Columns)" examples/queens.pl
```

The 4×4 board has two solutions, `[2, 4, 1, 3]` and `[3, 1, 4, 2]`. Without
`once`, `--goal "queens(8, C)"` lists all 92 solutions for the 8×8 board,
and `queens(6, C)` finds 4.

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=queens).

---

## Takeaway

Search can be long and messy, but its result need not be. Eyedia hands back
one clean certificate for the answer it found, and anyone can check it
without searching again.
