grandparent(alice, carol).
grandparent(bob, dave).
has_parent(bob, alice).
has_parent(carol, bob).
has_parent(dave, carol).
descendant(bob, alice).
descendant(carol, bob).
descendant(dave, carol).
descendant(carol, alice).
descendant(dave, bob).
descendant(dave, alice).

clause(1, parent(alice, bob), true).
clause(2, parent(bob, carol), true).
clause(3, parent(carol, dave), true).
clause(4, grandparent(var('X'), var('Z')), ','(parent(var('X'), var('Y')), parent(var('Y'), var('Z')))).
clause(5, has_parent(var('Child'), var('Parent')), parent(var('Parent'), var('Child'))).
clause(6, descendant(var('X'), var('Y')), parent(var('Y'), var('X'))).
clause(7, descendant(var('X'), var('Z')), ','(descendant(var('X'), var('Y')), parent(var('Z'), var('Y')))).

step(grandparent(alice, carol), rule(4), '.'(=('X', alice), '.'(=('Z', carol), '.'(=('Y', bob), []))), '.'(parent(alice, bob), '.'(parent(bob, carol), []))).
step(parent(alice, bob), fact(1), [], []).
step(parent(bob, carol), fact(2), [], []).
step(grandparent(bob, dave), rule(4), '.'(=('X', bob), '.'(=('Z', dave), '.'(=('Y', carol), []))), '.'(parent(bob, carol), '.'(parent(carol, dave), []))).
step(parent(carol, dave), fact(3), [], []).
step(has_parent(bob, alice), rule(5), '.'(=('Child', bob), '.'(=('Parent', alice), [])), '.'(parent(alice, bob), [])).
step(has_parent(carol, bob), rule(5), '.'(=('Child', carol), '.'(=('Parent', bob), [])), '.'(parent(bob, carol), [])).
step(has_parent(dave, carol), rule(5), '.'(=('Child', dave), '.'(=('Parent', carol), [])), '.'(parent(carol, dave), [])).
step(descendant(bob, alice), rule(6), '.'(=('X', bob), '.'(=('Y', alice), [])), '.'(parent(alice, bob), [])).
step(descendant(carol, bob), rule(6), '.'(=('X', carol), '.'(=('Y', bob), [])), '.'(parent(bob, carol), [])).
step(descendant(dave, carol), rule(6), '.'(=('X', dave), '.'(=('Y', carol), [])), '.'(parent(carol, dave), [])).
step(descendant(carol, alice), rule(7), '.'(=('X', carol), '.'(=('Z', alice), '.'(=('Y', bob), []))), '.'(descendant(carol, bob), '.'(parent(alice, bob), []))).
step(descendant(dave, bob), rule(7), '.'(=('X', dave), '.'(=('Z', bob), '.'(=('Y', carol), []))), '.'(descendant(dave, carol), '.'(parent(bob, carol), []))).
step(descendant(dave, alice), rule(7), '.'(=('X', dave), '.'(=('Z', alice), '.'(=('Y', bob), []))), '.'(descendant(dave, bob), '.'(parent(alice, bob), []))).
