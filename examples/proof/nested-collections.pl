first(1).
second_property(q).
third_first(2).

clause(1, nested(root, [1, properties([pair(p, q)]), [2]]), true).
clause(2, member(var('X'), [var('X')|var('__anon0')]), true).
clause(4, first(var('X')), nested(root, [var('X')|var('__anon2')])).
clause(5, second_property(var('Value')), ','(nested(root, [var('__anon3'), properties(var('Pairs'))|var('__anon4')]), member(pair(p, var('Value')), var('Pairs')))).
clause(6, third_first(var('X')), nested(root, [var('__anon5'), var('__anon6'), [var('X')|var('__anon7')]])).

step(first(1), rule(4), [=('X', 1), =('__anon2', [properties([pair(p, q)]), [2]])], [nested(root, [1, properties([pair(p, q)]), [2]])]).
step(nested(root, [1, properties([pair(p, q)]), [2]]), fact(1), [], []).
step(second_property(q), rule(5), [=('Value', q), =('__anon3', 1), =('Pairs', [pair(p, q)]), =('__anon4', [[2]])], [nested(root, [1, properties([pair(p, q)]), [2]]), member(pair(p, q), [pair(p, q)])]).
step(member(pair(p, q), [pair(p, q)]), fact(2), [=('X', pair(p, q)), =('__anon0', [])], []).
step(third_first(2), rule(6), [=('X', 2), =('__anon5', 1), =('__anon6', properties([pair(p, q)])), =('__anon7', [])], [nested(root, [1, properties([pair(p, q)]), [2]])]).
