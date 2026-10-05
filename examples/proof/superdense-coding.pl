sdcoding(0, 0).
sdcoding(1, 1).
sdcoding(2, 2).
sdcoding(3, 3).

clause(29, message(0), true).
clause(30, message(1), true).
clause(31, message(2), true).
clause(32, message(3), true).
clause(33, odd([var('__anon0')]), true).
clause(35, sdcoding(var('N'), var('M')), ','(message(var('N')), ','(message(var('M')), ','(findall(var('Path'), path(var('N'), var('M'), var('Path')), var('Paths')), odd(var('Paths')))))).

step(sdcoding(0, 0), rule(35), [=('N', 0), =('M', 0), =('Path', EYE_Path_23_1), =('Paths', [[true, true, true]])], [message(0), message(0), findall(EYE_Path_23_1, path(0, 0, EYE_Path_23_1), [[true, true, true]]), odd([[true, true, true]])]).
step(message(0), fact(29), [], []).
step(findall(EYE_Path_23_1, path(0, 0, EYE_Path_23_1), [[true, true, true]]), collected, [], []).
step(odd([[true, true, true]]), fact(33), [=('__anon0', [true, true, true])], []).
step(sdcoding(1, 1), rule(35), [=('N', 1), =('M', 1), =('Path', EYE_Path_23_1), =('Paths', [[false, false, true]])], [message(1), message(1), findall(EYE_Path_23_1, path(1, 1, EYE_Path_23_1), [[false, false, true]]), odd([[false, false, true]])]).
step(message(1), fact(30), [], []).
step(findall(EYE_Path_23_1, path(1, 1, EYE_Path_23_1), [[false, false, true]]), collected, [], []).
step(odd([[false, false, true]]), fact(33), [=('__anon0', [false, false, true])], []).
step(sdcoding(2, 2), rule(35), [=('N', 2), =('M', 2), =('Path', EYE_Path_23_1), =('Paths', [[true, true, false]])], [message(2), message(2), findall(EYE_Path_23_1, path(2, 2, EYE_Path_23_1), [[true, true, false]]), odd([[true, true, false]])]).
step(message(2), fact(31), [], []).
step(findall(EYE_Path_23_1, path(2, 2, EYE_Path_23_1), [[true, true, false]]), collected, [], []).
step(odd([[true, true, false]]), fact(33), [=('__anon0', [true, true, false])], []).
step(sdcoding(3, 3), rule(35), [=('N', 3), =('M', 3), =('Path', EYE_Path_23_1), =('Paths', [[false, false, false]])], [message(3), message(3), findall(EYE_Path_23_1, path(3, 3, EYE_Path_23_1), [[false, false, false]]), odd([[false, false, false]])]).
step(message(3), fact(32), [], []).
step(findall(EYE_Path_23_1, path(3, 3, EYE_Path_23_1), [[false, false, false]]), collected, [], []).
step(odd([[false, false, false]]), fact(33), [=('__anon0', [false, false, false])], []).
