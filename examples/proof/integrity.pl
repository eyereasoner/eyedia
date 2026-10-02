false.

clause(2, account(bob, -5), true).
clause(3, false, ','(account(var('Owner'), var('Balance')), <(var('Balance'), 0))).

step(false, rule(3), [=('Owner', bob), =('Balance', -5)], [account(bob, -5), <(-5, 0)]).
step(account(bob, -5), fact(2), [], []).
step(<(-5, 0), builtin, [], []).
