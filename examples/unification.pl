% Open lists and repeated variables enforce structural relationships.
append([], Ys, Ys).
append([X|Xs], Ys, [X|Zs]) :- append(Xs, Ys, Zs).
matching_pair(pair(X, X)).
head_tail([Head|Tail], Head, Tail).
true :+ append(Prefix, Suffix, [a,b]).
true :+ matching_pair(pair(same, same)).
true :+ head_tail([a,b,c], Head, Tail).
