allowed(alice, read).
allowed(alice, write).
allowed(bob, read).

clause(1, role(alice, editor), true).
clause(2, role(bob, viewer), true).
clause(4, permits(editor, read), true).
clause(5, permits(editor, write), true).
clause(6, permits(viewer, read), true).
clause(8, candidate(var('User'), var('Action')), ','(role(var('User'), var('Role')), permits(var('Role'), var('Action')))).
clause(9, allowed(var('User'), var('Action')), ','(candidate(var('User'), var('Action')), \+(suspended(var('User'))))).

step(allowed(alice, read), rule(9), [=('User', alice), =('Action', read)], [candidate(alice, read), \+(suspended(alice))]).
step(candidate(alice, read), rule(8), [=('User', alice), =('Action', read), =('Role', editor)], [role(alice, editor), permits(editor, read)]).
step(role(alice, editor), fact(1), [], []).
step(permits(editor, read), fact(4), [], []).
step(\+(suspended(alice)), absent, [], []).
step(allowed(alice, write), rule(9), [=('User', alice), =('Action', write)], [candidate(alice, write), \+(suspended(alice))]).
step(candidate(alice, write), rule(8), [=('User', alice), =('Action', write), =('Role', editor)], [role(alice, editor), permits(editor, write)]).
step(permits(editor, write), fact(5), [], []).
step(allowed(bob, read), rule(9), [=('User', bob), =('Action', read)], [candidate(bob, read), \+(suspended(bob))]).
step(candidate(bob, read), rule(8), [=('User', bob), =('Action', read), =('Role', viewer)], [role(bob, viewer), permits(viewer, read)]).
step(role(bob, viewer), fact(2), [], []).
step(permits(viewer, read), fact(6), [], []).
step(\+(suspended(bob)), absent, [], []).
