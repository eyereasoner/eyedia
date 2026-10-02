t(alice, name, 'Alice').
t(alice, age, 30).

clause(1, t(alice, source_name, 'Alice'), true).
clause(2, t(alice, source_age, 30), true).
clause(3, maps(source_name, name), true).
clause(4, maps(source_age, age), true).
clause(5, t(var('S'), var('Target'), var('O')), ','(t(var('S'), var('Source'), var('O')), maps(var('Source'), var('Target')))).

step(t(alice, name, 'Alice'), rule(5), [=('S', alice), =('Target', name), =('O', 'Alice'), =('Source', source_name)], [t(alice, source_name, 'Alice'), maps(source_name, name)]).
step(t(alice, source_name, 'Alice'), fact(1), [], []).
step(maps(source_name, name), fact(3), [], []).
step(t(alice, age, 30), rule(5), [=('S', alice), =('Target', age), =('O', 30), =('Source', source_age)], [t(alice, source_age, 30), maps(source_age, age)]).
step(t(alice, source_age, 30), fact(2), [], []).
step(maps(source_age, age), fact(4), [], []).
