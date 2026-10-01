% N queens: list position is the row, list value is the column (both 1-based).
queens(N, Columns) :- integer(N), N >= 0, columns(1, N, Available), place(Available, [], Columns).
columns(I, N, []) :- I > N.
columns(I, N, [I|Rest]) :- I =< N, Next is I+1, columns(Next, N, Rest).
select(X, [X|Rest], Rest).
select(X, [Y|Rest], [Y|Remaining]) :- select(X, Rest, Remaining).
place([], _, []).
place(Available, Placed, [Column|Rest]) :-
    select(Column, Available, Remaining), safe(Column, Placed, 1),
    place(Remaining, [Column|Placed], Rest).
safe(_, [], _).
safe(Column, [Other|Rest], Distance) :-
    Column =\= Other+Distance, Column =\= Other-Distance,
    Next is Distance+1, safe(Column, Rest, Next).
?- once(queens(8, Columns)).
