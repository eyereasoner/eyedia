t(bob, child_of, alice).
t(carol, child_of, alice).
allowed(carol).
children(alice, [bob, carol]).

clause(1, base(alice, parent_of, bob), true).
clause(2, base(alice, parent_of, carol), true).
clause(4, t(var('S'), var('P'), var('O')), base(var('S'), var('P'), var('O'))).
clause(5, t(var('C'), child_of, var('P')), t(var('P'), parent_of, var('C'))).
clause(6, allowed(var('C')), ','(t(var('C'), child_of, alice), \+(t(var('C'), blocked, true)))).
clause(7, children(var('P'), var('Children')), ','(base(var('P'), parent_of, var('__anon0')), findall(var('C'), t(var('C'), child_of, var('P')), var('Children')))).

step(t(bob, child_of, alice), rule(5), [=('C', bob), =('P', alice)], [t(alice, parent_of, bob)]).
step(t(alice, parent_of, bob), rule(4), [=('S', alice), =('P', parent_of), =('O', bob)], [base(alice, parent_of, bob)]).
step(base(alice, parent_of, bob), fact(1), [], []).
step(t(carol, child_of, alice), rule(5), [=('C', carol), =('P', alice)], [t(alice, parent_of, carol)]).
step(t(alice, parent_of, carol), rule(4), [=('S', alice), =('P', parent_of), =('O', carol)], [base(alice, parent_of, carol)]).
step(base(alice, parent_of, carol), fact(2), [], []).
step(allowed(carol), rule(6), [=('C', carol)], [t(carol, child_of, alice), \+(t(carol, blocked, true))]).
step(\+(t(carol, blocked, true)), absent, [], []).
step(children(alice, [bob, carol]), rule(7), [=('P', alice), =('Children', [bob, carol]), =('__anon0', bob), =('C', EYE_43_23_31_34)], [base(alice, parent_of, bob), findall(EYE_43_23_31_34, t(EYE_43_23_31_34, child_of, alice), [bob, carol])]).
step(findall(EYE_43_23_31_34, t(EYE_43_23_31_34, child_of, alice), [bob, carol]), collected, [], []).
