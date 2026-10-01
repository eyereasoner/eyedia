% Lists can contain scalars, property records and other lists.
nested(root, [1, properties([pair(p, q)]), [2]]).
member(X, [X|_]).
member(X, [_|Xs]) :- member(X, Xs).
first(X) :+ nested(root, [X|_]).
second_property(Value) :+ nested(root, [_,properties(Pairs)|_]), member(pair(p, Value), Pairs).
third_first(X) :+ nested(root, [_,_,[X|_]]).
