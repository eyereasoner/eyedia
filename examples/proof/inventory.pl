invoice(28).

clause(5, sum([], 0), true).
clause(6, sum([var('X')|var('Xs')], var('Total')), ','(sum(var('Xs'), var('Rest')), is(var('Total'), +(var('X'), var('Rest'))))).
clause(7, invoice(var('Total')), ','(findall(var('Amount'), line_total(var('__anon0'), var('Amount')), var('Amounts')), sum(var('Amounts'), var('Total')))).

step(invoice(28), rule(7), [=('Total', 28), =('Amount', EYE_Amount_23_9), =('__anon0', EYE_____anon0_23_9), =('Amounts', [6, 12, 10])], [findall(EYE_Amount_23_9, line_total(EYE_____anon0_23_9, EYE_Amount_23_9), [6, 12, 10]), sum([6, 12, 10], 28)]).
step(findall(EYE_Amount_23_9, line_total(EYE_____anon0_23_9, EYE_Amount_23_9), [6, 12, 10]), collected, [], []).
step(sum([6, 12, 10], 28), rule(6), [=('X', 6), =('Xs', [12, 10]), =('Total', 28), =('Rest', 22)], [sum([12, 10], 22), is(28, +(6, 22))]).
step(sum([12, 10], 22), rule(6), [=('X', 12), =('Xs', [10]), =('Total', 22), =('Rest', 10)], [sum([10], 10), is(22, +(12, 10))]).
step(sum([10], 10), rule(6), [=('X', 10), =('Xs', []), =('Total', 10), =('Rest', 0)], [sum([], 0), is(10, +(10, 0))]).
step(sum([], 0), fact(5), [], []).
step(is(10, +(10, 0)), builtin, [], []).
step(is(22, +(12, 10)), builtin, [], []).
step(is(28, +(6, 22)), builtin, [], []).
