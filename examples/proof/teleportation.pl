teleported(zero, 0, [false]).
teleported(zero, 1, [false]).
teleported(zero, 2, [false]).
teleported(zero, 3, [false]).
teleported(one, 0, [true]).
teleported(one, 1, [true]).
teleported(one, 2, [true]).
teleported(one, 3, [true]).
teleported(plus, 0, [false, true]).
teleported(plus, 1, [false, true]).
teleported(plus, 2, [false, true]).
teleported(plus, 3, [false, true]).

clause(5, name(zero), true).
clause(6, name(one), true).
clause(7, name(plus), true).
clause(29, outcome(0), true).
clause(30, outcome(1), true).
clause(31, outcome(2), true).
clause(32, outcome(3), true).
clause(37, teleported(var('S'), var('M'), var('Received')), ','(name(var('S')), ','(outcome(var('M')), findall(var('Z'), received(var('S'), var('M'), var('Z')), var('Received'))))).

step(teleported(zero, 0, [false]), rule(37), [=('S', zero), =('M', 0), =('Received', [false]), =('Z', EYE_5a_23_31)], [name(zero), outcome(0), findall(EYE_5a_23_31, received(zero, 0, EYE_5a_23_31), [false])]).
step(name(zero), fact(5), [], []).
step(outcome(0), fact(29), [], []).
step(findall(EYE_5a_23_31, received(zero, 0, EYE_5a_23_31), [false]), collected, [], []).
step(teleported(zero, 1, [false]), rule(37), [=('S', zero), =('M', 1), =('Received', [false]), =('Z', EYE_5a_23_31)], [name(zero), outcome(1), findall(EYE_5a_23_31, received(zero, 1, EYE_5a_23_31), [false])]).
step(outcome(1), fact(30), [], []).
step(findall(EYE_5a_23_31, received(zero, 1, EYE_5a_23_31), [false]), collected, [], []).
step(teleported(zero, 2, [false]), rule(37), [=('S', zero), =('M', 2), =('Received', [false]), =('Z', EYE_5a_23_31)], [name(zero), outcome(2), findall(EYE_5a_23_31, received(zero, 2, EYE_5a_23_31), [false])]).
step(outcome(2), fact(31), [], []).
step(findall(EYE_5a_23_31, received(zero, 2, EYE_5a_23_31), [false]), collected, [], []).
step(teleported(zero, 3, [false]), rule(37), [=('S', zero), =('M', 3), =('Received', [false]), =('Z', EYE_5a_23_31)], [name(zero), outcome(3), findall(EYE_5a_23_31, received(zero, 3, EYE_5a_23_31), [false])]).
step(outcome(3), fact(32), [], []).
step(findall(EYE_5a_23_31, received(zero, 3, EYE_5a_23_31), [false]), collected, [], []).
step(teleported(one, 0, [true]), rule(37), [=('S', one), =('M', 0), =('Received', [true]), =('Z', EYE_5a_23_31)], [name(one), outcome(0), findall(EYE_5a_23_31, received(one, 0, EYE_5a_23_31), [true])]).
step(name(one), fact(6), [], []).
step(findall(EYE_5a_23_31, received(one, 0, EYE_5a_23_31), [true]), collected, [], []).
step(teleported(one, 1, [true]), rule(37), [=('S', one), =('M', 1), =('Received', [true]), =('Z', EYE_5a_23_31)], [name(one), outcome(1), findall(EYE_5a_23_31, received(one, 1, EYE_5a_23_31), [true])]).
step(findall(EYE_5a_23_31, received(one, 1, EYE_5a_23_31), [true]), collected, [], []).
step(teleported(one, 2, [true]), rule(37), [=('S', one), =('M', 2), =('Received', [true]), =('Z', EYE_5a_23_31)], [name(one), outcome(2), findall(EYE_5a_23_31, received(one, 2, EYE_5a_23_31), [true])]).
step(findall(EYE_5a_23_31, received(one, 2, EYE_5a_23_31), [true]), collected, [], []).
step(teleported(one, 3, [true]), rule(37), [=('S', one), =('M', 3), =('Received', [true]), =('Z', EYE_5a_23_31)], [name(one), outcome(3), findall(EYE_5a_23_31, received(one, 3, EYE_5a_23_31), [true])]).
step(findall(EYE_5a_23_31, received(one, 3, EYE_5a_23_31), [true]), collected, [], []).
step(teleported(plus, 0, [false, true]), rule(37), [=('S', plus), =('M', 0), =('Received', [false, true]), =('Z', EYE_5a_23_31)], [name(plus), outcome(0), findall(EYE_5a_23_31, received(plus, 0, EYE_5a_23_31), [false, true])]).
step(name(plus), fact(7), [], []).
step(findall(EYE_5a_23_31, received(plus, 0, EYE_5a_23_31), [false, true]), collected, [], []).
step(teleported(plus, 1, [false, true]), rule(37), [=('S', plus), =('M', 1), =('Received', [false, true]), =('Z', EYE_5a_23_31)], [name(plus), outcome(1), findall(EYE_5a_23_31, received(plus, 1, EYE_5a_23_31), [false, true])]).
step(findall(EYE_5a_23_31, received(plus, 1, EYE_5a_23_31), [false, true]), collected, [], []).
step(teleported(plus, 2, [false, true]), rule(37), [=('S', plus), =('M', 2), =('Received', [false, true]), =('Z', EYE_5a_23_31)], [name(plus), outcome(2), findall(EYE_5a_23_31, received(plus, 2, EYE_5a_23_31), [false, true])]).
step(findall(EYE_5a_23_31, received(plus, 2, EYE_5a_23_31), [false, true]), collected, [], []).
step(teleported(plus, 3, [false, true]), rule(37), [=('S', plus), =('M', 3), =('Received', [false, true]), =('Z', EYE_5a_23_31)], [name(plus), outcome(3), findall(EYE_5a_23_31, received(plus, 3, EYE_5a_23_31), [false, true])]).
step(findall(EYE_5a_23_31, received(plus, 3, EYE_5a_23_31), [false, true]), collected, [], []).
