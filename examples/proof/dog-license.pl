dog_count(alice, 5).
dog_count(bob, 2).
requires(alice, dog_license).

clause(8, owner(alice), true).
clause(9, owner(bob), true).
clause(10, length([], 0), true).
clause(11, length([var('__anon0')|var('Xs')], var('N')), ','(length(var('Xs'), var('Before')), is(var('N'), +(var('Before'), 1)))).
clause(12, dog_count(var('Owner'), var('N')), ','(owner(var('Owner')), ','(findall(var('Dog'), owns(var('Owner'), var('Dog')), var('Dogs')), length(var('Dogs'), var('N'))))).
clause(13, requires(var('Owner'), dog_license), ','(dog_count(var('Owner'), var('N')), >(var('N'), 4))).

step(dog_count(alice, 5), rule(12), [=('Owner', alice), =('N', 5), =('Dog', EYE_44_6f_67_23_31), =('Dogs', [dog1, dog2, dog3, dog4, dog5])], [owner(alice), findall(EYE_44_6f_67_23_31, owns(alice, EYE_44_6f_67_23_31), [dog1, dog2, dog3, dog4, dog5]), length([dog1, dog2, dog3, dog4, dog5], 5)]).
step(owner(alice), fact(8), [], []).
step(findall(EYE_44_6f_67_23_31, owns(alice, EYE_44_6f_67_23_31), [dog1, dog2, dog3, dog4, dog5]), collected, [], []).
step(length([dog1, dog2, dog3, dog4, dog5], 5), rule(11), [=('__anon0', dog1), =('Xs', [dog2, dog3, dog4, dog5]), =('N', 5), =('Before', 4)], [length([dog2, dog3, dog4, dog5], 4), is(5, +(4, 1))]).
step(length([dog2, dog3, dog4, dog5], 4), rule(11), [=('__anon0', dog2), =('Xs', [dog3, dog4, dog5]), =('N', 4), =('Before', 3)], [length([dog3, dog4, dog5], 3), is(4, +(3, 1))]).
step(length([dog3, dog4, dog5], 3), rule(11), [=('__anon0', dog3), =('Xs', [dog4, dog5]), =('N', 3), =('Before', 2)], [length([dog4, dog5], 2), is(3, +(2, 1))]).
step(length([dog4, dog5], 2), rule(11), [=('__anon0', dog4), =('Xs', [dog5]), =('N', 2), =('Before', 1)], [length([dog5], 1), is(2, +(1, 1))]).
step(length([dog5], 1), rule(11), [=('__anon0', dog5), =('Xs', []), =('N', 1), =('Before', 0)], [length([], 0), is(1, +(0, 1))]).
step(length([], 0), fact(10), [], []).
step(is(1, +(0, 1)), builtin, [], []).
step(is(2, +(1, 1)), builtin, [], []).
step(is(3, +(2, 1)), builtin, [], []).
step(is(4, +(3, 1)), builtin, [], []).
step(is(5, +(4, 1)), builtin, [], []).
step(dog_count(bob, 2), rule(12), [=('Owner', bob), =('N', 2), =('Dog', EYE_44_6f_67_23_31), =('Dogs', [dog6, dog7])], [owner(bob), findall(EYE_44_6f_67_23_31, owns(bob, EYE_44_6f_67_23_31), [dog6, dog7]), length([dog6, dog7], 2)]).
step(owner(bob), fact(9), [], []).
step(findall(EYE_44_6f_67_23_31, owns(bob, EYE_44_6f_67_23_31), [dog6, dog7]), collected, [], []).
step(length([dog6, dog7], 2), rule(11), [=('__anon0', dog6), =('Xs', [dog7]), =('N', 2), =('Before', 1)], [length([dog7], 1), is(2, +(1, 1))]).
step(length([dog7], 1), rule(11), [=('__anon0', dog7), =('Xs', []), =('N', 1), =('Before', 0)], [length([], 0), is(1, +(0, 1))]).
step(requires(alice, dog_license), rule(13), [=('Owner', alice), =('N', 5)], [dog_count(alice, 5), >(5, 4)]).
step(>(5, 4), builtin, [], []).
