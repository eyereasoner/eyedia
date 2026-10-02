shortest(a, d, 6).

clause(2, edge(a, c, 2), true).
clause(3, edge(c, b, 1), true).
clause(4, edge(b, d, 3), true).
clause(6, path(var('X'), var('Y'), var('Cost')), edge(var('X'), var('Y'), var('Cost'))).
clause(7, path(var('X'), var('Z'), var('Cost')), ','(path(var('X'), var('Y'), var('Before')), ','(edge(var('Y'), var('Z'), var('Weight')), is(var('Cost'), +(var('Before'), var('Weight')))))).
clause(9, shortest(var('X'), var('Y'), var('Cost')), ','(path(var('X'), var('Y'), var('Cost')), \+(cheaper(var('X'), var('Y'), var('Cost'))))).

step(shortest(a, d, 6), rule(9), [=('X', a), =('Y', d), =('Cost', 6)], [path(a, d, 6), \+(cheaper(a, d, 6))]).
step(path(a, d, 6), rule(7), [=('X', a), =('Z', d), =('Cost', 6), =('Y', b), =('Before', 3), =('Weight', 3)], [path(a, b, 3), edge(b, d, 3), is(6, +(3, 3))]).
step(path(a, b, 3), rule(7), [=('X', a), =('Z', b), =('Cost', 3), =('Y', c), =('Before', 2), =('Weight', 1)], [path(a, c, 2), edge(c, b, 1), is(3, +(2, 1))]).
step(path(a, c, 2), rule(6), [=('X', a), =('Y', c), =('Cost', 2)], [edge(a, c, 2)]).
step(edge(a, c, 2), fact(2), [], []).
step(edge(c, b, 1), fact(3), [], []).
step(is(3, +(2, 1)), builtin, [], []).
step(edge(b, d, 3), fact(4), [], []).
step(is(6, +(3, 3)), builtin, [], []).
step(\+(cheaper(a, d, 6)), absent, [], []).
