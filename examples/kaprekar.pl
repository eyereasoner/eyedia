% Kaprekar's routine: take a four-digit number whose digits are not all equal,
% subtract its digits in ascending order from its digits in descending order,
% and repeat. Every such number reaches 6174 within seven steps. The first step
% depends only on which digits occur, so it is enough to check each of the 705
% nontrivial multisets of four digits once rather than all 10,000 numbers.
kaprekar_step(A, B) :-
    digits(A, Ds), sort4(Ds, Asc), reverse(Asc, Desc),
    number_of(Asc, Low), number_of(Desc, High), B is High-Low.

digits(A, [B, C, D, E]) :-
    B is A//1000, F is A rem 1000, C is F//100, G is F rem 100, D is G//10, E is G rem 10.
number_of([A, B, C, D], N) :- N is A*1000+B*100+C*10+D.

% Insertion sort, ascending.
sort4(Xs, Ys) :- insertion(Xs, [], Ys).
insertion([], Ys, Ys).
insertion([X|Xs], Acc, Ys) :- insert(X, Acc, Next), insertion(Xs, Next, Ys).
insert(X, [], [X]).
insert(X, [Y|Ys], [X, Y|Ys]) :- X =< Y.
insert(X, [Y|Ys], [Y|Zs]) :- X > Y, insert(X, Ys, Zs).
reverse(Xs, Ys) :- reverse(Xs, [], Ys).
reverse([], Ys, Ys).
reverse([X|Xs], Acc, Ys) :- reverse(Xs, [X|Acc], Ys).

in_range(Low, High, Low) :- Low =< High.
in_range(Low, High, N) :- Low < High, Next is Low+1, in_range(Next, High, N).

% One representative for every multiset of four decimal digits, nondecreasing.
digit_multiset(N) :-
    in_range(0, 9, A), in_range(A, 9, B), in_range(B, 9, C), in_range(C, 9, D),
    \+ (A =:= B, B =:= C, C =:= D),
    N is A*1000+B*100+C*10+D.

reaches_6174(6174, _).
reaches_6174(A, Steps) :- A =\= 6174, Steps < 7, kaprekar_step(A, B), Next is Steps+1, reaches_6174(B, Next).

counterexample :- digit_multiset(A), \+ reaches_6174(A, 0).
kaprekar_verified(6174, 7) :- \+ counterexample.

true :+ kaprekar_verified(6174, 7).
