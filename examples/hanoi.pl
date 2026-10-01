% Move three disks using a spare peg; recursion constructs the move list.
append([], Ys, Ys).
append([X|Xs], Ys, [X|Zs]) :- append(Xs, Ys, Zs).
moves(1, From, To, _, [move(From, To)]).
moves(N, From, To, Spare, Moves) :- N > 1, Smaller is N-1, moves(Smaller, From, Spare, To, First), moves(Smaller, Spare, To, From, Last), append(First, [move(From, To)|Last], Moves).
?- moves(3, left, right, center, Moves).
