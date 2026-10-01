descendant(bob, alice).
descendant(carol, alice).
descendant(dave, alice).

clause(1, parent(alice, bob), true).
clause(2, parent(bob, carol), true).
clause(3, parent(carol, dave), true).
clause(5, descendant(var('X'), var('Y')), parent(var('Y'), var('X'))).
clause(6, descendant(var('X'), var('Z')), ','(descendant(var('X'), var('Y')), parent(var('Z'), var('Y')))).

step(descendant(bob, alice), rule(5), '.'(=('X', bob), '.'(=('Y', alice), [])), '.'(parent(alice, bob), [])).
step(parent(alice, bob), fact(1), [], []).
step(descendant(carol, alice), rule(6), '.'(=('X', carol), '.'(=('Z', alice), '.'(=('Y', bob), []))), '.'(descendant(carol, bob), '.'(parent(alice, bob), []))).
step(descendant(carol, bob), rule(5), '.'(=('X', carol), '.'(=('Y', bob), [])), '.'(parent(bob, carol), [])).
step(parent(bob, carol), fact(2), [], []).
step(descendant(dave, alice), rule(6), '.'(=('X', dave), '.'(=('Z', alice), '.'(=('Y', bob), []))), '.'(descendant(dave, bob), '.'(parent(alice, bob), []))).
step(descendant(dave, bob), rule(6), '.'(=('X', dave), '.'(=('Z', bob), '.'(=('Y', carol), []))), '.'(descendant(dave, carol), '.'(parent(bob, carol), []))).
step(descendant(dave, carol), rule(5), '.'(=('X', dave), '.'(=('Y', carol), [])), '.'(parent(carol, dave), [])).
step(parent(carol, dave), fact(3), [], []).
