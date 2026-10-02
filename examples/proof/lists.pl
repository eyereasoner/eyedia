append([a, b], [c, d], [a, b, c, d]).
squares([1, 2, 3, 4], [1, 4, 9, 16]).
sum([1, 2, 3, 4], 10).

clause(1, append([], var('Ys'), var('Ys')), true).
clause(2, append([var('X')|var('Xs')], var('Ys'), [var('X')|var('Zs')]), append(var('Xs'), var('Ys'), var('Zs'))).
clause(3, squares([], []), true).
clause(4, squares([var('X')|var('Xs')], [var('Y')|var('Ys')]), ','(is(var('Y'), *(var('X'), var('X'))), squares(var('Xs'), var('Ys')))).
clause(5, sum([], 0), true).
clause(6, sum([var('X')|var('Xs')], var('Total')), ','(sum(var('Xs'), var('Rest')), is(var('Total'), +(var('X'), var('Rest'))))).

step(append([a, b], [c, d], [a, b, c, d]), rule(2), [=('X', a), =('Xs', [b]), =('Ys', [c, d]), =('Zs', [b, c, d])], [append([b], [c, d], [b, c, d])]).
step(append([b], [c, d], [b, c, d]), rule(2), [=('X', b), =('Xs', []), =('Ys', [c, d]), =('Zs', [c, d])], [append([], [c, d], [c, d])]).
step(append([], [c, d], [c, d]), fact(1), [=('Ys', [c, d])], []).
step(squares([1, 2, 3, 4], [1, 4, 9, 16]), rule(4), [=('X', 1), =('Xs', [2, 3, 4]), =('Y', 1), =('Ys', [4, 9, 16])], [is(1, *(1, 1)), squares([2, 3, 4], [4, 9, 16])]).
step(is(1, *(1, 1)), builtin, [], []).
step(squares([2, 3, 4], [4, 9, 16]), rule(4), [=('X', 2), =('Xs', [3, 4]), =('Y', 4), =('Ys', [9, 16])], [is(4, *(2, 2)), squares([3, 4], [9, 16])]).
step(is(4, *(2, 2)), builtin, [], []).
step(squares([3, 4], [9, 16]), rule(4), [=('X', 3), =('Xs', [4]), =('Y', 9), =('Ys', [16])], [is(9, *(3, 3)), squares([4], [16])]).
step(is(9, *(3, 3)), builtin, [], []).
step(squares([4], [16]), rule(4), [=('X', 4), =('Xs', []), =('Y', 16), =('Ys', [])], [is(16, *(4, 4)), squares([], [])]).
step(is(16, *(4, 4)), builtin, [], []).
step(squares([], []), fact(3), [], []).
step(sum([1, 2, 3, 4], 10), rule(6), [=('X', 1), =('Xs', [2, 3, 4]), =('Total', 10), =('Rest', 9)], [sum([2, 3, 4], 9), is(10, +(1, 9))]).
step(sum([2, 3, 4], 9), rule(6), [=('X', 2), =('Xs', [3, 4]), =('Total', 9), =('Rest', 7)], [sum([3, 4], 7), is(9, +(2, 7))]).
step(sum([3, 4], 7), rule(6), [=('X', 3), =('Xs', [4]), =('Total', 7), =('Rest', 4)], [sum([4], 4), is(7, +(3, 4))]).
step(sum([4], 4), rule(6), [=('X', 4), =('Xs', []), =('Total', 4), =('Rest', 0)], [sum([], 0), is(4, +(4, 0))]).
step(sum([], 0), fact(5), [], []).
step(is(4, +(4, 0)), builtin, [], []).
step(is(7, +(3, 4)), builtin, [], []).
step(is(9, +(2, 7)), builtin, [], []).
step(is(10, +(1, 9)), builtin, [], []).
