% Solve a 9x9 Sudoku by backtracking over finite choices. A puzzle gives its
% rows with 0 for a blank. The given digits are placed first, then the blanks,
% most constrained first; each takes a digit that no cell placed before it in
% its row, column or box already has, and the search backtracks on a dead end.
puzzle(wikipedia, [
  [5, 3, 0, 0, 7, 0, 0, 0, 0],
  [6, 0, 0, 1, 9, 5, 0, 0, 0],
  [0, 9, 8, 0, 0, 0, 0, 6, 0],
  [8, 0, 0, 0, 6, 0, 0, 0, 3],
  [4, 0, 0, 8, 0, 3, 0, 0, 1],
  [7, 0, 0, 0, 2, 0, 0, 0, 6],
  [0, 6, 0, 0, 0, 0, 2, 8, 0],
  [0, 0, 0, 4, 1, 9, 0, 0, 5],
  [0, 0, 0, 0, 8, 0, 0, 7, 9]]).

digit(1). digit(2). digit(3). digit(4). digit(5). digit(6). digit(7). digit(8). digit(9).

% A blank takes any digit; a given digit is its own value.
value(0, V) :- digit(V).
value(G, G) :- G > 0.

% Each cell is cell(Row, Column, Box, Given, Value); Value is shared with the
% solution grid. Givens and blanks are kept apart so that givens come first.
cells([], _, [], [], []).
cells([Row|Rows], R, [Values|Grid], Givens, Blanks) :-
    row_cells(Row, R, 1, Values, Givens, Givens1, Blanks, Blanks1),
    Next is R+1, cells(Rows, Next, Grid, Givens1, Blanks1).

row_cells([], _, _, [], Givens, Givens, Blanks, Blanks).
row_cells([G|Gs], R, C, [V|Vs], Givens, Givens1, Blanks, Blanks1) :-
    B is ((R-1)//3)*3 + (C-1)//3 + 1,
    file_cell(G, cell(R, C, B, G, V), Givens, Givens2, Blanks, Blanks2),
    Next is C+1, row_cells(Gs, R, Next, Vs, Givens2, Givens1, Blanks2, Blanks1).

file_cell(0, Cell, Givens, Givens, [Cell|Blanks], Blanks).
file_cell(G, Cell, [Cell|Givens], Givens, Blanks, Blanks) :- G > 0.

% Blanks that see the most given digits have the fewest choices, so they are
% filled first; ties keep row order.
order(Givens, Blanks, Ordered) :- weigh(Blanks, Givens, Weighed), sort_weighed(Weighed, [], Ordered).

weigh([], _, []).
weigh([cell(R, C, B, G, V)|Cells], Givens, [w(K, cell(R, C, B, G, V))|Weighed]) :-
    seen(R, C, B, Givens, 0, K), weigh(Cells, Givens, Weighed).

seen(_, _, _, [], K, K).
seen(R, C, B, [cell(R2, C2, B2, _, _)|Cells], K0, K) :- shares(R, C, B, R2, C2, B2), K1 is K0+1, seen(R, C, B, Cells, K1, K).
seen(R, C, B, [cell(R2, C2, B2, _, _)|Cells], K0, K) :- R =\= R2, C =\= C2, B =\= B2, seen(R, C, B, Cells, K0, K).

sort_weighed([], Sorted, Cells) :- unweigh(Sorted, Cells).
sort_weighed([W|Ws], Sorted, Cells) :- insert(W, Sorted, Sorted1), sort_weighed(Ws, Sorted1, Cells).

insert(W, [], [W]).
insert(w(K, X), [w(K2, Y)|Ws], [w(K, X), w(K2, Y)|Ws]) :- K > K2.
insert(w(K, X), [w(K2, Y)|Ws], [w(K2, Y)|Sorted]) :- K =< K2, insert(w(K, X), Ws, Sorted).

unweigh([], []).
unweigh([w(_, Cell)|Ws], [Cell|Cells]) :- unweigh(Ws, Cells).

append([], L, L).
append([X|Xs], L, [X|Ys]) :- append(Xs, L, Ys).

% Plan the search once: each cell gets the values of the peers placed before it.
plan([], _, []).
plan([cell(R, C, B, G, V)|Cells], Prior, [slot(G, V, Peers)|Slots]) :-
    peers(R, C, B, Prior, Peers),
    plan(Cells, [p(R, C, B, V)|Prior], Slots).

peers(_, _, _, [], []).
peers(R, C, B, [p(R2, C2, B2, W)|Prior], [W|Peers]) :- shares(R, C, B, R2, C2, B2), peers(R, C, B, Prior, Peers).
peers(R, C, B, [p(R2, C2, B2, _)|Prior], Peers) :- R =\= R2, C =\= C2, B =\= B2, peers(R, C, B, Prior, Peers).

shares(R, _, _, R2, _, _) :- R =:= R2.
shares(R, C, _, R2, C2, _) :- R =\= R2, C =:= C2.
shares(R, C, B, R2, C2, B2) :- R =\= R2, C =\= C2, B =:= B2.

place([]).
place([slot(G, V, Peers)|Slots]) :- value(G, V), differs(V, Peers), place(Slots).

differs(_, []).
differs(V, [W|Ws]) :- V =\= W, differs(V, Ws).

sudoku(Name, Grid) :-
    puzzle(Name, Rows), cells(Rows, 1, Grid, Givens, Blanks),
    order(Givens, Blanks, Ordered), append(Givens, Ordered, Cells), plan(Cells, [], Slots), place(Slots).

true :+ sudoku(wikipedia, _).
