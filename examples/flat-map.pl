% Map a predicate over subjects and concatenate all matching objects.
t(s1, p1, o1).
t(s2, p1, o2).
t(s3, p1, o3).
t(s3, p1, o4).
append([], Ys, Ys).
append([X|Xs], Ys, [X|Zs]) :- append(Xs, Ys, Zs).
flat_map([], _, []).
flat_map([S|Subjects], P, Objects) :- findall(O, t(S, P, O), Here), flat_map(Subjects, P, Rest), append(Here, Rest, Objects).
true :+ flat_map([s1,s2,s3], p1, Objects).
true :+ flat_map([missing], p1, Objects).
true :+ flat_map([s1], p2, Objects).
