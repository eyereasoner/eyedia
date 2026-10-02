once(queens(8, [1, 5, 8, 6, 3, 7, 2, 4])).

clause(1, queens(var('N'), var('Columns')), ','(integer(var('N')), ','(>=(var('N'), 0), ','(columns(1, var('N'), var('Available')), place(var('Available'), [], var('Columns')))))).
clause(2, columns(var('I'), var('N'), []), >(var('I'), var('N'))).
clause(3, columns(var('I'), var('N'), [var('I')|var('Rest')]), ','(=<(var('I'), var('N')), ','(is(var('Next'), +(var('I'), 1)), columns(var('Next'), var('N'), var('Rest'))))).
clause(4, select(var('X'), [var('X')|var('Rest')], var('Rest')), true).
clause(5, select(var('X'), [var('Y')|var('Rest')], [var('Y')|var('Remaining')]), select(var('X'), var('Rest'), var('Remaining'))).
clause(6, place([], var('__anon0'), []), true).
clause(7, place(var('Available'), var('Placed'), [var('Column')|var('Rest')]), ','(select(var('Column'), var('Available'), var('Remaining')), ','(safe(var('Column'), var('Placed'), 1), place(var('Remaining'), [var('Column')|var('Placed')], var('Rest'))))).
clause(8, safe(var('__anon1'), [], var('__anon2')), true).
clause(9, safe(var('Column'), [var('Other')|var('Rest')], var('Distance')), ','(=\=(var('Column'), +(var('Other'), var('Distance'))), ','(=\=(var('Column'), -(var('Other'), var('Distance'))), ','(is(var('Next'), +(var('Distance'), 1)), safe(var('Column'), var('Rest'), var('Next')))))).

step(once(queens(8, [1, 5, 8, 6, 3, 7, 2, 4])), control, [], [queens(8, [1, 5, 8, 6, 3, 7, 2, 4])]).
step(queens(8, [1, 5, 8, 6, 3, 7, 2, 4]), rule(1), [=('N', 8), =('Columns', [1, 5, 8, 6, 3, 7, 2, 4]), =('Available', [1, 2, 3, 4, 5, 6, 7, 8])], [integer(8), >=(8, 0), columns(1, 8, [1, 2, 3, 4, 5, 6, 7, 8]), place([1, 2, 3, 4, 5, 6, 7, 8], [], [1, 5, 8, 6, 3, 7, 2, 4])]).
step(integer(8), builtin, [], []).
step(>=(8, 0), builtin, [], []).
step(columns(1, 8, [1, 2, 3, 4, 5, 6, 7, 8]), rule(3), [=('I', 1), =('N', 8), =('Rest', [2, 3, 4, 5, 6, 7, 8]), =('Next', 2)], [=<(1, 8), is(2, +(1, 1)), columns(2, 8, [2, 3, 4, 5, 6, 7, 8])]).
step(=<(1, 8), builtin, [], []).
step(is(2, +(1, 1)), builtin, [], []).
step(columns(2, 8, [2, 3, 4, 5, 6, 7, 8]), rule(3), [=('I', 2), =('N', 8), =('Rest', [3, 4, 5, 6, 7, 8]), =('Next', 3)], [=<(2, 8), is(3, +(2, 1)), columns(3, 8, [3, 4, 5, 6, 7, 8])]).
step(=<(2, 8), builtin, [], []).
step(is(3, +(2, 1)), builtin, [], []).
step(columns(3, 8, [3, 4, 5, 6, 7, 8]), rule(3), [=('I', 3), =('N', 8), =('Rest', [4, 5, 6, 7, 8]), =('Next', 4)], [=<(3, 8), is(4, +(3, 1)), columns(4, 8, [4, 5, 6, 7, 8])]).
step(=<(3, 8), builtin, [], []).
step(is(4, +(3, 1)), builtin, [], []).
step(columns(4, 8, [4, 5, 6, 7, 8]), rule(3), [=('I', 4), =('N', 8), =('Rest', [5, 6, 7, 8]), =('Next', 5)], [=<(4, 8), is(5, +(4, 1)), columns(5, 8, [5, 6, 7, 8])]).
step(=<(4, 8), builtin, [], []).
step(is(5, +(4, 1)), builtin, [], []).
step(columns(5, 8, [5, 6, 7, 8]), rule(3), [=('I', 5), =('N', 8), =('Rest', [6, 7, 8]), =('Next', 6)], [=<(5, 8), is(6, +(5, 1)), columns(6, 8, [6, 7, 8])]).
step(=<(5, 8), builtin, [], []).
step(is(6, +(5, 1)), builtin, [], []).
step(columns(6, 8, [6, 7, 8]), rule(3), [=('I', 6), =('N', 8), =('Rest', [7, 8]), =('Next', 7)], [=<(6, 8), is(7, +(6, 1)), columns(7, 8, [7, 8])]).
step(=<(6, 8), builtin, [], []).
step(is(7, +(6, 1)), builtin, [], []).
step(columns(7, 8, [7, 8]), rule(3), [=('I', 7), =('N', 8), =('Rest', [8]), =('Next', 8)], [=<(7, 8), is(8, +(7, 1)), columns(8, 8, [8])]).
step(=<(7, 8), builtin, [], []).
step(is(8, +(7, 1)), builtin, [], []).
step(columns(8, 8, [8]), rule(3), [=('I', 8), =('N', 8), =('Rest', []), =('Next', 9)], [=<(8, 8), is(9, +(8, 1)), columns(9, 8, [])]).
step(=<(8, 8), builtin, [], []).
step(is(9, +(8, 1)), builtin, [], []).
step(columns(9, 8, []), rule(2), [=('I', 9), =('N', 8)], [>(9, 8)]).
step(>(9, 8), builtin, [], []).
step(place([1, 2, 3, 4, 5, 6, 7, 8], [], [1, 5, 8, 6, 3, 7, 2, 4]), rule(7), [=('Available', [1, 2, 3, 4, 5, 6, 7, 8]), =('Placed', []), =('Column', 1), =('Rest', [5, 8, 6, 3, 7, 2, 4]), =('Remaining', [2, 3, 4, 5, 6, 7, 8])], [select(1, [1, 2, 3, 4, 5, 6, 7, 8], [2, 3, 4, 5, 6, 7, 8]), safe(1, [], 1), place([2, 3, 4, 5, 6, 7, 8], [1], [5, 8, 6, 3, 7, 2, 4])]).
step(select(1, [1, 2, 3, 4, 5, 6, 7, 8], [2, 3, 4, 5, 6, 7, 8]), fact(4), [=('X', 1), =('Rest', [2, 3, 4, 5, 6, 7, 8])], []).
step(safe(1, [], 1), fact(8), [=('__anon1', 1), =('__anon2', 1)], []).
step(place([2, 3, 4, 5, 6, 7, 8], [1], [5, 8, 6, 3, 7, 2, 4]), rule(7), [=('Available', [2, 3, 4, 5, 6, 7, 8]), =('Placed', [1]), =('Column', 5), =('Rest', [8, 6, 3, 7, 2, 4]), =('Remaining', [2, 3, 4, 6, 7, 8])], [select(5, [2, 3, 4, 5, 6, 7, 8], [2, 3, 4, 6, 7, 8]), safe(5, [1], 1), place([2, 3, 4, 6, 7, 8], [5, 1], [8, 6, 3, 7, 2, 4])]).
step(select(5, [2, 3, 4, 5, 6, 7, 8], [2, 3, 4, 6, 7, 8]), rule(5), [=('X', 5), =('Y', 2), =('Rest', [3, 4, 5, 6, 7, 8]), =('Remaining', [3, 4, 6, 7, 8])], [select(5, [3, 4, 5, 6, 7, 8], [3, 4, 6, 7, 8])]).
step(select(5, [3, 4, 5, 6, 7, 8], [3, 4, 6, 7, 8]), rule(5), [=('X', 5), =('Y', 3), =('Rest', [4, 5, 6, 7, 8]), =('Remaining', [4, 6, 7, 8])], [select(5, [4, 5, 6, 7, 8], [4, 6, 7, 8])]).
step(select(5, [4, 5, 6, 7, 8], [4, 6, 7, 8]), rule(5), [=('X', 5), =('Y', 4), =('Rest', [5, 6, 7, 8]), =('Remaining', [6, 7, 8])], [select(5, [5, 6, 7, 8], [6, 7, 8])]).
step(select(5, [5, 6, 7, 8], [6, 7, 8]), fact(4), [=('X', 5), =('Rest', [6, 7, 8])], []).
step(safe(5, [1], 1), rule(9), [=('Column', 5), =('Other', 1), =('Rest', []), =('Distance', 1), =('Next', 2)], [=\=(5, +(1, 1)), =\=(5, -(1, 1)), is(2, +(1, 1)), safe(5, [], 2)]).
step(=\=(5, +(1, 1)), builtin, [], []).
step(=\=(5, -(1, 1)), builtin, [], []).
step(safe(5, [], 2), fact(8), [=('__anon1', 5), =('__anon2', 2)], []).
step(place([2, 3, 4, 6, 7, 8], [5, 1], [8, 6, 3, 7, 2, 4]), rule(7), [=('Available', [2, 3, 4, 6, 7, 8]), =('Placed', [5, 1]), =('Column', 8), =('Rest', [6, 3, 7, 2, 4]), =('Remaining', [2, 3, 4, 6, 7])], [select(8, [2, 3, 4, 6, 7, 8], [2, 3, 4, 6, 7]), safe(8, [5, 1], 1), place([2, 3, 4, 6, 7], [8, 5, 1], [6, 3, 7, 2, 4])]).
step(select(8, [2, 3, 4, 6, 7, 8], [2, 3, 4, 6, 7]), rule(5), [=('X', 8), =('Y', 2), =('Rest', [3, 4, 6, 7, 8]), =('Remaining', [3, 4, 6, 7])], [select(8, [3, 4, 6, 7, 8], [3, 4, 6, 7])]).
step(select(8, [3, 4, 6, 7, 8], [3, 4, 6, 7]), rule(5), [=('X', 8), =('Y', 3), =('Rest', [4, 6, 7, 8]), =('Remaining', [4, 6, 7])], [select(8, [4, 6, 7, 8], [4, 6, 7])]).
step(select(8, [4, 6, 7, 8], [4, 6, 7]), rule(5), [=('X', 8), =('Y', 4), =('Rest', [6, 7, 8]), =('Remaining', [6, 7])], [select(8, [6, 7, 8], [6, 7])]).
step(select(8, [6, 7, 8], [6, 7]), rule(5), [=('X', 8), =('Y', 6), =('Rest', [7, 8]), =('Remaining', [7])], [select(8, [7, 8], [7])]).
step(select(8, [7, 8], [7]), rule(5), [=('X', 8), =('Y', 7), =('Rest', [8]), =('Remaining', [])], [select(8, [8], [])]).
step(select(8, [8], []), fact(4), [=('X', 8), =('Rest', [])], []).
step(safe(8, [5, 1], 1), rule(9), [=('Column', 8), =('Other', 5), =('Rest', [1]), =('Distance', 1), =('Next', 2)], [=\=(8, +(5, 1)), =\=(8, -(5, 1)), is(2, +(1, 1)), safe(8, [1], 2)]).
step(=\=(8, +(5, 1)), builtin, [], []).
step(=\=(8, -(5, 1)), builtin, [], []).
step(safe(8, [1], 2), rule(9), [=('Column', 8), =('Other', 1), =('Rest', []), =('Distance', 2), =('Next', 3)], [=\=(8, +(1, 2)), =\=(8, -(1, 2)), is(3, +(2, 1)), safe(8, [], 3)]).
step(=\=(8, +(1, 2)), builtin, [], []).
step(=\=(8, -(1, 2)), builtin, [], []).
step(safe(8, [], 3), fact(8), [=('__anon1', 8), =('__anon2', 3)], []).
step(place([2, 3, 4, 6, 7], [8, 5, 1], [6, 3, 7, 2, 4]), rule(7), [=('Available', [2, 3, 4, 6, 7]), =('Placed', [8, 5, 1]), =('Column', 6), =('Rest', [3, 7, 2, 4]), =('Remaining', [2, 3, 4, 7])], [select(6, [2, 3, 4, 6, 7], [2, 3, 4, 7]), safe(6, [8, 5, 1], 1), place([2, 3, 4, 7], [6, 8, 5, 1], [3, 7, 2, 4])]).
step(select(6, [2, 3, 4, 6, 7], [2, 3, 4, 7]), rule(5), [=('X', 6), =('Y', 2), =('Rest', [3, 4, 6, 7]), =('Remaining', [3, 4, 7])], [select(6, [3, 4, 6, 7], [3, 4, 7])]).
step(select(6, [3, 4, 6, 7], [3, 4, 7]), rule(5), [=('X', 6), =('Y', 3), =('Rest', [4, 6, 7]), =('Remaining', [4, 7])], [select(6, [4, 6, 7], [4, 7])]).
step(select(6, [4, 6, 7], [4, 7]), rule(5), [=('X', 6), =('Y', 4), =('Rest', [6, 7]), =('Remaining', [7])], [select(6, [6, 7], [7])]).
step(select(6, [6, 7], [7]), fact(4), [=('X', 6), =('Rest', [7])], []).
step(safe(6, [8, 5, 1], 1), rule(9), [=('Column', 6), =('Other', 8), =('Rest', [5, 1]), =('Distance', 1), =('Next', 2)], [=\=(6, +(8, 1)), =\=(6, -(8, 1)), is(2, +(1, 1)), safe(6, [5, 1], 2)]).
step(=\=(6, +(8, 1)), builtin, [], []).
step(=\=(6, -(8, 1)), builtin, [], []).
step(safe(6, [5, 1], 2), rule(9), [=('Column', 6), =('Other', 5), =('Rest', [1]), =('Distance', 2), =('Next', 3)], [=\=(6, +(5, 2)), =\=(6, -(5, 2)), is(3, +(2, 1)), safe(6, [1], 3)]).
step(=\=(6, +(5, 2)), builtin, [], []).
step(=\=(6, -(5, 2)), builtin, [], []).
step(safe(6, [1], 3), rule(9), [=('Column', 6), =('Other', 1), =('Rest', []), =('Distance', 3), =('Next', 4)], [=\=(6, +(1, 3)), =\=(6, -(1, 3)), is(4, +(3, 1)), safe(6, [], 4)]).
step(=\=(6, +(1, 3)), builtin, [], []).
step(=\=(6, -(1, 3)), builtin, [], []).
step(safe(6, [], 4), fact(8), [=('__anon1', 6), =('__anon2', 4)], []).
step(place([2, 3, 4, 7], [6, 8, 5, 1], [3, 7, 2, 4]), rule(7), [=('Available', [2, 3, 4, 7]), =('Placed', [6, 8, 5, 1]), =('Column', 3), =('Rest', [7, 2, 4]), =('Remaining', [2, 4, 7])], [select(3, [2, 3, 4, 7], [2, 4, 7]), safe(3, [6, 8, 5, 1], 1), place([2, 4, 7], [3, 6, 8, 5, 1], [7, 2, 4])]).
step(select(3, [2, 3, 4, 7], [2, 4, 7]), rule(5), [=('X', 3), =('Y', 2), =('Rest', [3, 4, 7]), =('Remaining', [4, 7])], [select(3, [3, 4, 7], [4, 7])]).
step(select(3, [3, 4, 7], [4, 7]), fact(4), [=('X', 3), =('Rest', [4, 7])], []).
step(safe(3, [6, 8, 5, 1], 1), rule(9), [=('Column', 3), =('Other', 6), =('Rest', [8, 5, 1]), =('Distance', 1), =('Next', 2)], [=\=(3, +(6, 1)), =\=(3, -(6, 1)), is(2, +(1, 1)), safe(3, [8, 5, 1], 2)]).
step(=\=(3, +(6, 1)), builtin, [], []).
step(=\=(3, -(6, 1)), builtin, [], []).
step(safe(3, [8, 5, 1], 2), rule(9), [=('Column', 3), =('Other', 8), =('Rest', [5, 1]), =('Distance', 2), =('Next', 3)], [=\=(3, +(8, 2)), =\=(3, -(8, 2)), is(3, +(2, 1)), safe(3, [5, 1], 3)]).
step(=\=(3, +(8, 2)), builtin, [], []).
step(=\=(3, -(8, 2)), builtin, [], []).
step(safe(3, [5, 1], 3), rule(9), [=('Column', 3), =('Other', 5), =('Rest', [1]), =('Distance', 3), =('Next', 4)], [=\=(3, +(5, 3)), =\=(3, -(5, 3)), is(4, +(3, 1)), safe(3, [1], 4)]).
step(=\=(3, +(5, 3)), builtin, [], []).
step(=\=(3, -(5, 3)), builtin, [], []).
step(safe(3, [1], 4), rule(9), [=('Column', 3), =('Other', 1), =('Rest', []), =('Distance', 4), =('Next', 5)], [=\=(3, +(1, 4)), =\=(3, -(1, 4)), is(5, +(4, 1)), safe(3, [], 5)]).
step(=\=(3, +(1, 4)), builtin, [], []).
step(=\=(3, -(1, 4)), builtin, [], []).
step(safe(3, [], 5), fact(8), [=('__anon1', 3), =('__anon2', 5)], []).
step(place([2, 4, 7], [3, 6, 8, 5, 1], [7, 2, 4]), rule(7), [=('Available', [2, 4, 7]), =('Placed', [3, 6, 8, 5, 1]), =('Column', 7), =('Rest', [2, 4]), =('Remaining', [2, 4])], [select(7, [2, 4, 7], [2, 4]), safe(7, [3, 6, 8, 5, 1], 1), place([2, 4], [7, 3, 6, 8, 5, 1], [2, 4])]).
step(select(7, [2, 4, 7], [2, 4]), rule(5), [=('X', 7), =('Y', 2), =('Rest', [4, 7]), =('Remaining', [4])], [select(7, [4, 7], [4])]).
step(select(7, [4, 7], [4]), rule(5), [=('X', 7), =('Y', 4), =('Rest', [7]), =('Remaining', [])], [select(7, [7], [])]).
step(select(7, [7], []), fact(4), [=('X', 7), =('Rest', [])], []).
step(safe(7, [3, 6, 8, 5, 1], 1), rule(9), [=('Column', 7), =('Other', 3), =('Rest', [6, 8, 5, 1]), =('Distance', 1), =('Next', 2)], [=\=(7, +(3, 1)), =\=(7, -(3, 1)), is(2, +(1, 1)), safe(7, [6, 8, 5, 1], 2)]).
step(=\=(7, +(3, 1)), builtin, [], []).
step(=\=(7, -(3, 1)), builtin, [], []).
step(safe(7, [6, 8, 5, 1], 2), rule(9), [=('Column', 7), =('Other', 6), =('Rest', [8, 5, 1]), =('Distance', 2), =('Next', 3)], [=\=(7, +(6, 2)), =\=(7, -(6, 2)), is(3, +(2, 1)), safe(7, [8, 5, 1], 3)]).
step(=\=(7, +(6, 2)), builtin, [], []).
step(=\=(7, -(6, 2)), builtin, [], []).
step(safe(7, [8, 5, 1], 3), rule(9), [=('Column', 7), =('Other', 8), =('Rest', [5, 1]), =('Distance', 3), =('Next', 4)], [=\=(7, +(8, 3)), =\=(7, -(8, 3)), is(4, +(3, 1)), safe(7, [5, 1], 4)]).
step(=\=(7, +(8, 3)), builtin, [], []).
step(=\=(7, -(8, 3)), builtin, [], []).
step(safe(7, [5, 1], 4), rule(9), [=('Column', 7), =('Other', 5), =('Rest', [1]), =('Distance', 4), =('Next', 5)], [=\=(7, +(5, 4)), =\=(7, -(5, 4)), is(5, +(4, 1)), safe(7, [1], 5)]).
step(=\=(7, +(5, 4)), builtin, [], []).
step(=\=(7, -(5, 4)), builtin, [], []).
step(safe(7, [1], 5), rule(9), [=('Column', 7), =('Other', 1), =('Rest', []), =('Distance', 5), =('Next', 6)], [=\=(7, +(1, 5)), =\=(7, -(1, 5)), is(6, +(5, 1)), safe(7, [], 6)]).
step(=\=(7, +(1, 5)), builtin, [], []).
step(=\=(7, -(1, 5)), builtin, [], []).
step(safe(7, [], 6), fact(8), [=('__anon1', 7), =('__anon2', 6)], []).
step(place([2, 4], [7, 3, 6, 8, 5, 1], [2, 4]), rule(7), [=('Available', [2, 4]), =('Placed', [7, 3, 6, 8, 5, 1]), =('Column', 2), =('Rest', [4]), =('Remaining', [4])], [select(2, [2, 4], [4]), safe(2, [7, 3, 6, 8, 5, 1], 1), place([4], [2, 7, 3, 6, 8, 5, 1], [4])]).
step(select(2, [2, 4], [4]), fact(4), [=('X', 2), =('Rest', [4])], []).
step(safe(2, [7, 3, 6, 8, 5, 1], 1), rule(9), [=('Column', 2), =('Other', 7), =('Rest', [3, 6, 8, 5, 1]), =('Distance', 1), =('Next', 2)], [=\=(2, +(7, 1)), =\=(2, -(7, 1)), is(2, +(1, 1)), safe(2, [3, 6, 8, 5, 1], 2)]).
step(=\=(2, +(7, 1)), builtin, [], []).
step(=\=(2, -(7, 1)), builtin, [], []).
step(safe(2, [3, 6, 8, 5, 1], 2), rule(9), [=('Column', 2), =('Other', 3), =('Rest', [6, 8, 5, 1]), =('Distance', 2), =('Next', 3)], [=\=(2, +(3, 2)), =\=(2, -(3, 2)), is(3, +(2, 1)), safe(2, [6, 8, 5, 1], 3)]).
step(=\=(2, +(3, 2)), builtin, [], []).
step(=\=(2, -(3, 2)), builtin, [], []).
step(safe(2, [6, 8, 5, 1], 3), rule(9), [=('Column', 2), =('Other', 6), =('Rest', [8, 5, 1]), =('Distance', 3), =('Next', 4)], [=\=(2, +(6, 3)), =\=(2, -(6, 3)), is(4, +(3, 1)), safe(2, [8, 5, 1], 4)]).
step(=\=(2, +(6, 3)), builtin, [], []).
step(=\=(2, -(6, 3)), builtin, [], []).
step(safe(2, [8, 5, 1], 4), rule(9), [=('Column', 2), =('Other', 8), =('Rest', [5, 1]), =('Distance', 4), =('Next', 5)], [=\=(2, +(8, 4)), =\=(2, -(8, 4)), is(5, +(4, 1)), safe(2, [5, 1], 5)]).
step(=\=(2, +(8, 4)), builtin, [], []).
step(=\=(2, -(8, 4)), builtin, [], []).
step(safe(2, [5, 1], 5), rule(9), [=('Column', 2), =('Other', 5), =('Rest', [1]), =('Distance', 5), =('Next', 6)], [=\=(2, +(5, 5)), =\=(2, -(5, 5)), is(6, +(5, 1)), safe(2, [1], 6)]).
step(=\=(2, +(5, 5)), builtin, [], []).
step(=\=(2, -(5, 5)), builtin, [], []).
step(safe(2, [1], 6), rule(9), [=('Column', 2), =('Other', 1), =('Rest', []), =('Distance', 6), =('Next', 7)], [=\=(2, +(1, 6)), =\=(2, -(1, 6)), is(7, +(6, 1)), safe(2, [], 7)]).
step(=\=(2, +(1, 6)), builtin, [], []).
step(=\=(2, -(1, 6)), builtin, [], []).
step(safe(2, [], 7), fact(8), [=('__anon1', 2), =('__anon2', 7)], []).
step(place([4], [2, 7, 3, 6, 8, 5, 1], [4]), rule(7), [=('Available', [4]), =('Placed', [2, 7, 3, 6, 8, 5, 1]), =('Column', 4), =('Rest', []), =('Remaining', [])], [select(4, [4], []), safe(4, [2, 7, 3, 6, 8, 5, 1], 1), place([], [4, 2, 7, 3, 6, 8, 5, 1], [])]).
step(select(4, [4], []), fact(4), [=('X', 4), =('Rest', [])], []).
step(safe(4, [2, 7, 3, 6, 8, 5, 1], 1), rule(9), [=('Column', 4), =('Other', 2), =('Rest', [7, 3, 6, 8, 5, 1]), =('Distance', 1), =('Next', 2)], [=\=(4, +(2, 1)), =\=(4, -(2, 1)), is(2, +(1, 1)), safe(4, [7, 3, 6, 8, 5, 1], 2)]).
step(=\=(4, +(2, 1)), builtin, [], []).
step(=\=(4, -(2, 1)), builtin, [], []).
step(safe(4, [7, 3, 6, 8, 5, 1], 2), rule(9), [=('Column', 4), =('Other', 7), =('Rest', [3, 6, 8, 5, 1]), =('Distance', 2), =('Next', 3)], [=\=(4, +(7, 2)), =\=(4, -(7, 2)), is(3, +(2, 1)), safe(4, [3, 6, 8, 5, 1], 3)]).
step(=\=(4, +(7, 2)), builtin, [], []).
step(=\=(4, -(7, 2)), builtin, [], []).
step(safe(4, [3, 6, 8, 5, 1], 3), rule(9), [=('Column', 4), =('Other', 3), =('Rest', [6, 8, 5, 1]), =('Distance', 3), =('Next', 4)], [=\=(4, +(3, 3)), =\=(4, -(3, 3)), is(4, +(3, 1)), safe(4, [6, 8, 5, 1], 4)]).
step(=\=(4, +(3, 3)), builtin, [], []).
step(=\=(4, -(3, 3)), builtin, [], []).
step(safe(4, [6, 8, 5, 1], 4), rule(9), [=('Column', 4), =('Other', 6), =('Rest', [8, 5, 1]), =('Distance', 4), =('Next', 5)], [=\=(4, +(6, 4)), =\=(4, -(6, 4)), is(5, +(4, 1)), safe(4, [8, 5, 1], 5)]).
step(=\=(4, +(6, 4)), builtin, [], []).
step(=\=(4, -(6, 4)), builtin, [], []).
step(safe(4, [8, 5, 1], 5), rule(9), [=('Column', 4), =('Other', 8), =('Rest', [5, 1]), =('Distance', 5), =('Next', 6)], [=\=(4, +(8, 5)), =\=(4, -(8, 5)), is(6, +(5, 1)), safe(4, [5, 1], 6)]).
step(=\=(4, +(8, 5)), builtin, [], []).
step(=\=(4, -(8, 5)), builtin, [], []).
step(safe(4, [5, 1], 6), rule(9), [=('Column', 4), =('Other', 5), =('Rest', [1]), =('Distance', 6), =('Next', 7)], [=\=(4, +(5, 6)), =\=(4, -(5, 6)), is(7, +(6, 1)), safe(4, [1], 7)]).
step(=\=(4, +(5, 6)), builtin, [], []).
step(=\=(4, -(5, 6)), builtin, [], []).
step(safe(4, [1], 7), rule(9), [=('Column', 4), =('Other', 1), =('Rest', []), =('Distance', 7), =('Next', 8)], [=\=(4, +(1, 7)), =\=(4, -(1, 7)), is(8, +(7, 1)), safe(4, [], 8)]).
step(=\=(4, +(1, 7)), builtin, [], []).
step(=\=(4, -(1, 7)), builtin, [], []).
step(safe(4, [], 8), fact(8), [=('__anon1', 4), =('__anon2', 8)], []).
step(place([], [4, 2, 7, 3, 6, 8, 5, 1], []), fact(6), [=('__anon0', [4, 2, 7, 3, 6, 8, 5, 1])], []).
