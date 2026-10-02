t(x, child_of, a).
t(x, child_of, b).
t(a, child_of, c).
t(x, descended_from, a).
t(x, descended_from, b).
t(a, descended_from, c).
t(x, descended_from, c).

clause(1, t(a, father_of, x), true).
clause(2, t(b, mother_of, x), true).
clause(3, t(c, mother_of, a), true).
clause(4, t(var('X'), child_of, var('Y')), t(var('Y'), father_of, var('X'))).
clause(5, t(var('X'), child_of, var('Y')), t(var('Y'), mother_of, var('X'))).
clause(6, t(var('X'), descended_from, var('Y')), t(var('X'), child_of, var('Y'))).
clause(7, t(var('X'), descended_from, var('Y')), ','(t(var('X'), child_of, var('Z')), t(var('Z'), descended_from, var('Y')))).

step(t(x, child_of, a), rule(4), [=('X', x), =('Y', a)], [t(a, father_of, x)]).
step(t(a, father_of, x), fact(1), [], []).
step(t(x, child_of, b), rule(5), [=('X', x), =('Y', b)], [t(b, mother_of, x)]).
step(t(b, mother_of, x), fact(2), [], []).
step(t(a, child_of, c), rule(5), [=('X', a), =('Y', c)], [t(c, mother_of, a)]).
step(t(c, mother_of, a), fact(3), [], []).
step(t(x, descended_from, a), rule(6), [=('X', x), =('Y', a)], [t(x, child_of, a)]).
step(t(x, descended_from, b), rule(6), [=('X', x), =('Y', b)], [t(x, child_of, b)]).
step(t(a, descended_from, c), rule(6), [=('X', a), =('Y', c)], [t(a, child_of, c)]).
step(t(x, descended_from, c), rule(7), [=('X', x), =('Y', c), =('Z', a)], [t(x, child_of, a), t(a, descended_from, c)]).
