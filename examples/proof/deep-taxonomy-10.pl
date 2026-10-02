type(ind, n10).

clause(1, type(ind, n0), true).
clause(2, type(var('X'), n1), type(var('X'), n0)).
clause(5, type(var('X'), n2), type(var('X'), n1)).
clause(8, type(var('X'), n3), type(var('X'), n2)).
clause(11, type(var('X'), n4), type(var('X'), n3)).
clause(14, type(var('X'), n5), type(var('X'), n4)).
clause(17, type(var('X'), n6), type(var('X'), n5)).
clause(20, type(var('X'), n7), type(var('X'), n6)).
clause(23, type(var('X'), n8), type(var('X'), n7)).
clause(26, type(var('X'), n9), type(var('X'), n8)).
clause(29, type(var('X'), n10), type(var('X'), n9)).

step(type(ind, n10), rule(29), [=('X', ind)], [type(ind, n9)]).
step(type(ind, n9), rule(26), [=('X', ind)], [type(ind, n8)]).
step(type(ind, n8), rule(23), [=('X', ind)], [type(ind, n7)]).
step(type(ind, n7), rule(20), [=('X', ind)], [type(ind, n6)]).
step(type(ind, n6), rule(17), [=('X', ind)], [type(ind, n5)]).
step(type(ind, n5), rule(14), [=('X', ind)], [type(ind, n4)]).
step(type(ind, n4), rule(11), [=('X', ind)], [type(ind, n3)]).
step(type(ind, n3), rule(8), [=('X', ind)], [type(ind, n2)]).
step(type(ind, n2), rule(5), [=('X', ind)], [type(ind, n1)]).
step(type(ind, n1), rule(2), [=('X', ind)], [type(ind, n0)]).
step(type(ind, n0), fact(1), [], []).
