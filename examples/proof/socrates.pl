type(socrates, mortal).
type(socrates, human).

clause(1, type(socrates, human), true).
clause(2, subclass_of(human, mortal), true).
clause(3, type(var('S'), var('B')), ','(type(var('S'), var('A')), subclass_of(var('A'), var('B')))).

step(type(socrates, mortal), rule(3), '.'(=('S', socrates), '.'(=('B', mortal), '.'(=('A', human), []))), '.'(type(socrates, human), '.'(subclass_of(human, mortal), []))).
step(type(socrates, human), fact(1), [], []).
step(subclass_of(human, mortal), fact(2), [], []).
