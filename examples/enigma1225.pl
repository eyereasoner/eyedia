% New Scientist Enigma 1225: fill a Size x Size board so that permuting its
% rows by a permutation without fixed points gives the board's transpose,
% with no two rows alike. Cells forced equal form classes; number the classes
% 1, 2, ... from the smallest class up, and score the board as the sum of its
% entries. Report the best board and the permutation that makes it.
% Adapted from https://www.sciencedirect.com/science/article/pii/S0898122106002057
% where the classes come from unifying variables; here a cell is its row-major
% number, and its class is its orbit under (I, J) -> (Perm(J), I).
enigma1225(Size, [Permutation, Board, Max]) :-
    partitions([part(Size, 1)], Partitions),
    squares(Partitions, Size, Squares),
    best(Squares, 0, Max),
    first_with(Squares, Max, Permutation, Board).

% Every partition of Size, in the order of the original generator: a list of
% part(K, Count) with the smallest parts first. The last one is all ones.
partitions([part(1, A)], [[part(1, A)]]).
partitions([P|Ps], [[P|Ps]|Rest]) :- not_last([P|Ps]), next_partition([P|Ps], Next), partitions(Next, Rest).

not_last([part(K, _)|_]) :- K > 1.
not_last([part(1, _), _|_]).

next_partition([part(2, 1)|T], [part(1, 2)|T]).
next_partition([part(2, A)|T], [part(1, 2), part(2, B)|T]) :- A > 1, B is A-1.
next_partition([part(K, 1)|T], [part(1, 1), part(L, 1)|T]) :- K > 2, L is K-1.
next_partition([part(K, A)|T], [part(1, 1), part(L, 1), part(K, B)|T]) :- K > 2, A > 1, L is K-1, B is A-1.
next_partition([part(1, A), part(2, 1)|T], [part(1, B)|T]) :- B is A+2.
next_partition([part(1, A), part(2, A2)|T], [part(1, B), part(2, B2)|T]) :- A2 > 1, B is A+2, B2 is A2-1.
next_partition([part(1, A), part(L, 1)|T], Next) :-
    L > 2, M is L-1, Rest is (A+L) mod M, Ratio is (A+L)//M, refill(Rest, part(M, Ratio), T, Next).
next_partition([part(1, A), part(L, AL)|T], Next) :-
    L > 2, AL > 1, M is L-1, Rest is (A+L) mod M, Ratio is (A+L)//M, B is AL-1,
    refill(Rest, part(M, Ratio), [part(L, B)|T], Next).

refill(0, Part, T, [Part|T]).
refill(Rest, Part, T, [part(Rest, 1), Part|T]) :- Rest > 0.

% One board for each partition without parts of size 1, kept when its rows differ.
squares([], _, []).
squares([[part(1, _)|_]|Ps], Size, Squares) :- squares(Ps, Size, Squares).
squares([[part(K, A)|T]|Ps], Size, Squares) :-
    K > 1, square(Size, [part(K, A)|T], Square, Distinct),
    keep(Distinct, Square, Rest, Squares), squares(Ps, Size, Rest).

keep(yes, Square, Rest, [Square|Rest]).
keep(no, _, Rest, Rest).

square(Size, Partition, square(Total, Permutation, Board), Distinct) :-
    blocks(Partition, 1, Permutation),
    label_rows(1, Size, Permutation, Rows), distinct(Rows, Distinct),
    representatives(Rows, 1, Classes), order(Classes, [], Ordered),
    total(Ordered, 1, 0, Total), values(Rows, Ordered, Board).

% Each block of K consecutive numbers is rotated one step: a cycle of length K.
blocks([], _, []).
blocks([part(_, 0)|T], Start, P) :- blocks(T, Start, P).
blocks([part(K, A)|T], Start, P) :-
    A > 0, Second is Start+1, Last is Start+K-1, range(Second, Last, Up),
    append(Up, [Start], Block), Next is Start+K, B is A-1,
    blocks([part(K, B)|T], Next, Rest), append(Block, Rest, P).

range(From, To, []) :- From > To.
range(From, To, [From|Rest]) :- From =< To, Next is From+1, range(Next, To, Rest).

append([], L, L).
append([X|Xs], L, [X|Ys]) :- append(Xs, L, Ys).

nth(1, [X|_], X).
nth(N, [_|Xs], X) :- N > 1, M is N-1, nth(M, Xs, X).

% The label of a cell is c(First, Count): the first cell of its class in row
% order, and the size of the class.
% A row of labels holds c(First, Count) lists, so two rows are alike exactly
% when their cells fall in the same classes.
label_rows(I, Size, _, []) :- I > Size.
label_rows(I, Size, Perm, [Row|Rows]) :-
    I =< Size, labels(I, 1, Size, Perm, Row), Next is I+1, label_rows(Next, Size, Perm, Rows).

labels(_, J, Size, _, []) :- J > Size.
labels(I, J, Size, Perm, [c(First, Count)|Labels]) :-
    J =< Size, X is (I-1)*Size + J, orbit(X, X, Size, Perm, X, 1, First, Count),
    Next is J+1, labels(I, Next, Size, Perm, Labels).

orbit(Start, X, Size, Perm, Min0, Len0, Min, Len) :-
    I is (X-1)//Size + 1, J is (X-1) mod Size + 1, nth(J, Perm, PJ),
    Y is (PJ-1)*Size + I, around(Y, Start, Size, Perm, Min0, Len0, Min, Len).

around(Y, Start, _, _, Min, Len, Min, Len) :- Y =:= Start.
around(Y, Start, Size, Perm, Min0, Len0, Min, Len) :-
    Y =\= Start, Min1 is min(Min0, Y), Len1 is Len0+1, orbit(Start, Y, Size, Perm, Min1, Len1, Min, Len).

distinct([], yes).
distinct([Row|Rows], Distinct) :- unlike(Row, Rows, D), distinct_rest(D, Rows, Distinct).

distinct_rest(no, _, no).
distinct_rest(yes, Rows, Distinct) :- distinct(Rows, Distinct).

unlike(_, [], yes).
unlike(Row, [Other|_], no) :- Row == Other.
unlike(Row, [Other|Rows], D) :- Row \== Other, unlike(Row, Rows, D).

% The classes in row order of their first cell, then sorted by size, keeping
% that order among classes of equal size.
representatives([], _, []).
representatives([Row|Rows], X, Classes) :-
    firsts(Row, X, Next, Classes, Rest), representatives(Rows, Next, Rest).

firsts([], X, X, Classes, Classes).
firsts([c(First, Count)|Labels], X, Next, [c(Count, First)|Classes], Rest) :-
    First =:= X, Y is X+1, firsts(Labels, Y, Next, Classes, Rest).
firsts([c(First, _)|Labels], X, Next, Classes, Rest) :-
    First =\= X, Y is X+1, firsts(Labels, Y, Next, Classes, Rest).

order([], Sorted, Sorted).
order([C|Cs], Sorted0, Sorted) :- insert(C, Sorted0, Sorted1), order(Cs, Sorted1, Sorted).

insert(C, [], [C]).
insert(c(N, F), [c(M, G)|Cs], [c(N, F), c(M, G)|Cs]) :- N < M.
insert(c(N, F), [c(M, G)|Cs], [c(M, G)|Sorted]) :- N >= M, insert(c(N, F), Cs, Sorted).

% Class number R covers Count cells, so it adds R*Count to the total.
total([], _, Total, Total).
total([c(Count, _)|Cs], R, Total0, Total) :- Total1 is Total0 + R*Count, Next is R+1, total(Cs, Next, Total1, Total).

values([], _, []).
values([Row|Rows], Ordered, [Values|Board]) :- row_values(Row, Ordered, Values), values(Rows, Ordered, Board).

row_values([], _, []).
row_values([c(First, _)|Labels], Ordered, [V|Vs]) :- number_of(First, Ordered, 1, V), row_values(Labels, Ordered, Vs).

number_of(First, [c(_, F)|_], R, R) :- F =:= First.
number_of(First, [c(_, F)|Cs], R, V) :- F =\= First, Next is R+1, number_of(First, Cs, Next, V).

best([], Max, Max).
best([square(Total, _, _)|Squares], Max0, Max) :- Max1 is max(Max0, Total), best(Squares, Max1, Max).

first_with([square(Total, Permutation, Board)|_], Max, Permutation, Board) :- Total =:= Max.
first_with([square(Total, _, _)|Squares], Max, Permutation, Board) :- Total =\= Max, first_with(Squares, Max, Permutation, Board).

true :+ enigma1225(8, _).
