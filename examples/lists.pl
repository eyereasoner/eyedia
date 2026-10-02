% Define list operations with ordinary recursive clauses.
append([], Ys, Ys).
append([X|Xs], Ys, [X|Zs]) :- append(Xs, Ys, Zs).
squares([], []).
squares([X|Xs], [Y|Ys]) :- Y is X*X, squares(Xs, Ys).
sum([], 0).
sum([X|Xs], Total) :- sum(Xs, Rest), Total is X+Rest.
true :+ append([a,b], [c,d], Joined).
true :+ squares([1,2,3,4], Squared).
true :+ sum([1,2,3,4], Total).
