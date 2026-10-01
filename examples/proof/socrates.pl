mortal(socrates).

clause(1, human(socrates), true).
clause(2, mortal(var('X')), human(var('X'))).

step(mortal(socrates), rule(2), '.'(=('X', socrates), []), '.'(human(socrates), [])).
step(human(socrates), fact(1), [], []).
