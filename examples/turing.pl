% A Turing machine interpreter, and a machine that adds one to a binary number.
% The tape is held as the cells to the left (reversed), the cell under the
% head, and the cells to the right; # is a blank cell.
% See https://en.wikipedia.org/wiki/Universal_Turing_machine
compute([], OutTape) :- start(_, I), find(I, [], #, [], OutTape).
compute([Head|Tail], OutTape) :- start(_, I), find(I, [], Head, Tail, OutTape).

find(State, Left, Cell, Right, OutTape) :-
    t([State, Cell, Write, Move], Next),
    move(Move, Left, Write, Right, A, B, C),
    continue(Next, A, B, C, OutTape).

continue(halt, Left, Cell, Right, OutTape) :- reverse(Left, R), append(R, [Cell|Right], OutTape).
continue(State, Left, Cell, Right, OutTape) :- State \= halt, find(State, Left, Cell, Right, OutTape).

move(l, [], Cell, Right, [], #, [Cell|Right]).
move(l, [Head|Tail], Cell, Right, Tail, Head, [Cell|Right]).
move(s, Left, Cell, Right, Left, Cell, Right).
move(r, Left, Cell, [], [Cell|Left], #, []).
move(r, Left, Cell, [Head|Tail], [Cell|Left], Head, Tail).

append([], Ys, Ys).
append([X|Xs], Ys, [X|Zs]) :- append(Xs, Ys, Zs).
reverse(Xs, Ys) :- reverse(Xs, [], Ys).
reverse([], Ys, Ys).
reverse([X|Xs], Acc, Ys) :- reverse(Xs, [X|Acc], Ys).

% The machine: scan right to the end, then carry leftwards.
start(add1, 0).
t([0, 0, 0, r], 0).
t([0, 1, 1, r], 0).
t([0, #, #, l], 1).
t([1, 0, 1, s], halt).
t([1, 1, 0, l], 1).
t([1, #, 1, s], halt).

true :+ compute([1, 0, 1, 0, 0, 1], _).
true :+ compute([1, 0, 1, 1, 1, 1], _).
true :+ compute([1, 1, 1, 1, 1, 1], _).
true :+ compute([], _).
