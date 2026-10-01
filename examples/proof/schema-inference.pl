subclass(cat, animal).
type(koko, animal).
type(koko, mammal).
triple(alice, related_to, bob).
type(alice, person).
type(bob, person).

clause(1, subclass(cat, mammal), true).
clause(2, subclass(mammal, animal), true).
clause(3, subproperty(parent_of, related_to), true).
clause(4, domain(parent_of, person), true).
clause(5, range(parent_of, person), true).
clause(6, type(koko, cat), true).
clause(7, triple(alice, parent_of, bob), true).
clause(8, subclass(var('A'), var('C')), ','(subclass(var('A'), var('B')), subclass(var('B'), var('C')))).
clause(9, type(var('X'), var('B')), ','(type(var('X'), var('A')), subclass(var('A'), var('B')))).
clause(10, triple(var('S'), var('Q'), var('O')), ','(triple(var('S'), var('P'), var('O')), subproperty(var('P'), var('Q')))).
clause(11, type(var('S'), var('Class')), ','(triple(var('S'), var('P'), var('__anon0')), domain(var('P'), var('Class')))).
clause(12, type(var('O'), var('Class')), ','(triple(var('__anon1'), var('P'), var('O')), range(var('P'), var('Class')))).

step(subclass(cat, animal), rule(8), '.'(=('A', cat), '.'(=('C', animal), '.'(=('B', mammal), []))), '.'(subclass(cat, mammal), '.'(subclass(mammal, animal), []))).
step(subclass(cat, mammal), fact(1), [], []).
step(subclass(mammal, animal), fact(2), [], []).
step(type(koko, animal), rule(9), '.'(=('X', koko), '.'(=('B', animal), '.'(=('A', cat), []))), '.'(type(koko, cat), '.'(subclass(cat, animal), []))).
step(type(koko, cat), fact(6), [], []).
step(type(koko, mammal), rule(9), '.'(=('X', koko), '.'(=('B', mammal), '.'(=('A', cat), []))), '.'(type(koko, cat), '.'(subclass(cat, mammal), []))).
step(triple(alice, related_to, bob), rule(10), '.'(=('S', alice), '.'(=('Q', related_to), '.'(=('O', bob), '.'(=('P', parent_of), [])))), '.'(triple(alice, parent_of, bob), '.'(subproperty(parent_of, related_to), []))).
step(triple(alice, parent_of, bob), fact(7), [], []).
step(subproperty(parent_of, related_to), fact(3), [], []).
step(type(alice, person), rule(11), '.'(=('S', alice), '.'(=('Class', person), '.'(=('P', parent_of), '.'(=('__anon0', bob), [])))), '.'(triple(alice, parent_of, bob), '.'(domain(parent_of, person), []))).
step(domain(parent_of, person), fact(4), [], []).
step(type(bob, person), rule(12), '.'(=('O', bob), '.'(=('Class', person), '.'(=('__anon1', alice), '.'(=('P', parent_of), [])))), '.'(triple(alice, parent_of, bob), '.'(range(parent_of, person), []))).
step(range(parent_of, person), fact(5), [], []).
