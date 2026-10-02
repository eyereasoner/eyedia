result(example, 12).

clause(1, literal(n2, 2), true).
clause(2, literal(n3, 3), true).
clause(3, literal(n10, 10), true).
clause(4, literal(n4, 4), true).
clause(5, expression(product, mul, n2, n3), true).
clause(6, expression(difference, sub, n10, n4), true).
clause(7, expression(total, add, product, difference), true).
clause(8, root(example, total), true).
clause(9, value(var('Node'), var('Value')), literal(var('Node'), var('Value'))).
clause(10, value(var('Node'), var('Value')), ','(expression(var('Node'), var('Operation'), var('Left'), var('Right')), ','(value(var('Left'), var('L')), ','(value(var('Right'), var('R')), calculate(var('Operation'), var('L'), var('R'), var('Value')))))).
clause(11, calculate(add, var('L'), var('R'), var('Value')), is(var('Value'), +(var('L'), var('R')))).
clause(12, calculate(sub, var('L'), var('R'), var('Value')), is(var('Value'), -(var('L'), var('R')))).
clause(13, calculate(mul, var('L'), var('R'), var('Value')), is(var('Value'), *(var('L'), var('R')))).
clause(14, result(var('Name'), var('Value')), ','(root(var('Name'), var('Node')), value(var('Node'), var('Value')))).

step(result(example, 12), rule(14), [=('Name', example), =('Value', 12), =('Node', total)], [root(example, total), value(total, 12)]).
step(root(example, total), fact(8), [], []).
step(value(total, 12), rule(10), [=('Node', total), =('Value', 12), =('Operation', add), =('Left', product), =('Right', difference), =('L', 6), =('R', 6)], [expression(total, add, product, difference), value(product, 6), value(difference, 6), calculate(add, 6, 6, 12)]).
step(expression(total, add, product, difference), fact(7), [], []).
step(value(product, 6), rule(10), [=('Node', product), =('Value', 6), =('Operation', mul), =('Left', n2), =('Right', n3), =('L', 2), =('R', 3)], [expression(product, mul, n2, n3), value(n2, 2), value(n3, 3), calculate(mul, 2, 3, 6)]).
step(expression(product, mul, n2, n3), fact(5), [], []).
step(value(n2, 2), rule(9), [=('Node', n2), =('Value', 2)], [literal(n2, 2)]).
step(literal(n2, 2), fact(1), [], []).
step(value(n3, 3), rule(9), [=('Node', n3), =('Value', 3)], [literal(n3, 3)]).
step(literal(n3, 3), fact(2), [], []).
step(calculate(mul, 2, 3, 6), rule(13), [=('L', 2), =('R', 3), =('Value', 6)], [is(6, *(2, 3))]).
step(is(6, *(2, 3)), builtin, [], []).
step(value(difference, 6), rule(10), [=('Node', difference), =('Value', 6), =('Operation', sub), =('Left', n10), =('Right', n4), =('L', 10), =('R', 4)], [expression(difference, sub, n10, n4), value(n10, 10), value(n4, 4), calculate(sub, 10, 4, 6)]).
step(expression(difference, sub, n10, n4), fact(6), [], []).
step(value(n10, 10), rule(9), [=('Node', n10), =('Value', 10)], [literal(n10, 10)]).
step(literal(n10, 10), fact(3), [], []).
step(value(n4, 4), rule(9), [=('Node', n4), =('Value', 4)], [literal(n4, 4)]).
step(literal(n4, 4), fact(4), [], []).
step(calculate(sub, 10, 4, 6), rule(12), [=('L', 10), =('R', 4), =('Value', 6)], [is(6, -(10, 4))]).
step(is(6, -(10, 4)), builtin, [], []).
step(calculate(add, 6, 6, 12), rule(11), [=('L', 6), =('R', 6), =('Value', 12)], [is(12, +(6, 6))]).
step(is(12, +(6, 6)), builtin, [], []).
