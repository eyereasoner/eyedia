name(author_42, 'Alice').
name(alice_alias, 'Alice').
name(alice, 'Alice').

clause(1, same_as(alice, alice_alias), true).
clause(2, same_as(alice_alias, author_42), true).
clause(3, name(alice, 'Alice'), true).
clause(5, same_as(var('X'), var('Z')), ','(same_as(var('X'), var('Y')), same_as(var('Y'), var('Z')))).
clause(6, name(var('Y'), var('Name')), ','(same_as(var('X'), var('Y')), name(var('X'), var('Name')))).

step(name(author_42, 'Alice'), rule(6), '.'(=('Y', author_42), '.'(=('Name', 'Alice'), '.'(=('X', alice), []))), '.'(same_as(alice, author_42), '.'(name(alice, 'Alice'), []))).
step(same_as(alice, author_42), rule(5), '.'(=('X', alice), '.'(=('Z', author_42), '.'(=('Y', alice_alias), []))), '.'(same_as(alice, alice_alias), '.'(same_as(alice_alias, author_42), []))).
step(same_as(alice, alice_alias), fact(1), [], []).
step(same_as(alice_alias, author_42), fact(2), [], []).
step(name(alice, 'Alice'), fact(3), [], []).
step(name(alice_alias, 'Alice'), rule(6), '.'(=('Y', alice_alias), '.'(=('Name', 'Alice'), '.'(=('X', alice), []))), '.'(same_as(alice, alice_alias), '.'(name(alice, 'Alice'), []))).
