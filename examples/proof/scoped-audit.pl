consented(approved, alice).
needs_review(incomplete, bob).

clause(1, context(approved, graph([triple(alice, role, editor), triple(alice, consent, yes)])), true).
clause(2, context(incomplete, graph([triple(bob, role, editor)])), true).
clause(3, member(var('X'), [var('X')|var('__anon0')]), true).
clause(4, member(var('X'), [var('__anon1')|var('Xs')]), member(var('X'), var('Xs'))).
clause(5, includes(graph(var('Triples')), var('Triple')), member(var('Triple'), var('Triples'))).
clause(6, consented(var('Context'), var('Person')), ','(context(var('Context'), var('Graph')), includes(var('Graph'), triple(var('Person'), consent, yes)))).
clause(7, needs_review(var('Context'), var('Person')), ','(context(var('Context'), var('Graph')), ','(includes(var('Graph'), triple(var('Person'), role, editor)), \+(includes(var('Graph'), triple(var('Person'), consent, yes)))))).

step(consented(approved, alice), rule(6), [=('Context', approved), =('Person', alice), =('Graph', graph([triple(alice, role, editor), triple(alice, consent, yes)]))], [context(approved, graph([triple(alice, role, editor), triple(alice, consent, yes)])), includes(graph([triple(alice, role, editor), triple(alice, consent, yes)]), triple(alice, consent, yes))]).
step(context(approved, graph([triple(alice, role, editor), triple(alice, consent, yes)])), fact(1), [], []).
step(includes(graph([triple(alice, role, editor), triple(alice, consent, yes)]), triple(alice, consent, yes)), rule(5), [=('Triples', [triple(alice, role, editor), triple(alice, consent, yes)]), =('Triple', triple(alice, consent, yes))], [member(triple(alice, consent, yes), [triple(alice, role, editor), triple(alice, consent, yes)])]).
step(member(triple(alice, consent, yes), [triple(alice, role, editor), triple(alice, consent, yes)]), rule(4), [=('X', triple(alice, consent, yes)), =('__anon1', triple(alice, role, editor)), =('Xs', [triple(alice, consent, yes)])], [member(triple(alice, consent, yes), [triple(alice, consent, yes)])]).
step(member(triple(alice, consent, yes), [triple(alice, consent, yes)]), fact(3), [=('X', triple(alice, consent, yes)), =('__anon0', [])], []).
step(needs_review(incomplete, bob), rule(7), [=('Context', incomplete), =('Person', bob), =('Graph', graph([triple(bob, role, editor)]))], [context(incomplete, graph([triple(bob, role, editor)])), includes(graph([triple(bob, role, editor)]), triple(bob, role, editor)), \+(includes(graph([triple(bob, role, editor)]), triple(bob, consent, yes)))]).
step(context(incomplete, graph([triple(bob, role, editor)])), fact(2), [], []).
step(includes(graph([triple(bob, role, editor)]), triple(bob, role, editor)), rule(5), [=('Triples', [triple(bob, role, editor)]), =('Triple', triple(bob, role, editor))], [member(triple(bob, role, editor), [triple(bob, role, editor)])]).
step(member(triple(bob, role, editor), [triple(bob, role, editor)]), fact(3), [=('X', triple(bob, role, editor)), =('__anon0', [])], []).
step(\+(includes(graph([triple(bob, role, editor)]), triple(bob, consent, yes))), absent, [], []).
