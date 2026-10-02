plan([go(loc3), push(loc1), climb_on, grab]).
plan([go(loc1), go(loc3), push(loc1), climb_on, grab]).
plan([go(loc3), push(loc1), climb_on, grab, climb_off]).
plan([go(loc3), push(loc2), push(loc1), climb_on, grab]).

clause(1, reaches_goal(var('Moves')), ','(initial_state(var('I')), ','(goal_state(var('G')), reachable(var('I'), var('Moves'), var('G'))))).
clause(2, reachable(var('S'), [], var('S')), true).
clause(3, reachable(var('S1'), [var('M')|var('Rest')], var('S3')), ','(legal_move(var('S1'), var('M'), var('S2')), reachable(var('S2'), var('Rest'), var('S3')))).
clause(4, initial_state([loc1, loc2, loc3, n, n]), true).
clause(5, goal_state([var('__anon0'), var('__anon1'), var('__anon2'), var('__anon3'), y]), true).
clause(6, legal_move([var('B'), var('M'), var('M'), n, var('H')], climb_on, [var('B'), var('M'), var('M'), y, var('H')]), true).
clause(7, legal_move([var('B'), var('M'), var('M'), y, var('H')], climb_off, [var('B'), var('M'), var('M'), n, var('H')]), true).
clause(8, legal_move([var('B'), var('B'), var('B'), y, n], grab, [var('B'), var('B'), var('B'), y, y]), true).
clause(9, legal_move([var('B'), var('M'), var('M'), n, var('H')], push(var('X')), [var('B'), var('X'), var('X'), n, var('H')]), ','(location(var('X')), \=(var('X'), var('M')))).
clause(10, legal_move([var('B'), var('M'), var('L'), n, var('H')], go(var('X')), [var('B'), var('X'), var('L'), n, var('H')]), ','(location(var('X')), \=(var('X'), var('M')))).
clause(11, location(loc1), true).
clause(12, location(loc2), true).
clause(13, location(loc3), true).
clause(14, moves(0, []), true).
clause(15, moves(var('N'), [var('__anon4')|var('Rest')]), ','(>(var('N'), 0), ','(is(var('M'), -(var('N'), 1)), moves(var('M'), var('Rest'))))).
clause(16, in_range(var('Low'), var('High'), var('Low')), =<(var('Low'), var('High'))).
clause(17, in_range(var('Low'), var('High'), var('N')), ','(<(var('Low'), var('High')), ','(is(var('Next'), +(var('Low'), 1)), in_range(var('Next'), var('High'), var('N'))))).
clause(18, plan(var('Moves')), ','(in_range(1, 5, var('N')), ','(moves(var('N'), var('Moves')), reaches_goal(var('Moves'))))).

step(plan([go(loc3), push(loc1), climb_on, grab]), rule(18), [=('Moves', [go(loc3), push(loc1), climb_on, grab]), =('N', 4)], [in_range(1, 5, 4), moves(4, [go(loc3), push(loc1), climb_on, grab]), reaches_goal([go(loc3), push(loc1), climb_on, grab])]).
step(in_range(1, 5, 4), rule(17), [=('Low', 1), =('High', 5), =('N', 4), =('Next', 2)], [<(1, 5), is(2, +(1, 1)), in_range(2, 5, 4)]).
step(<(1, 5), builtin, [], []).
step(is(2, +(1, 1)), builtin, [], []).
step(in_range(2, 5, 4), rule(17), [=('Low', 2), =('High', 5), =('N', 4), =('Next', 3)], [<(2, 5), is(3, +(2, 1)), in_range(3, 5, 4)]).
step(<(2, 5), builtin, [], []).
step(is(3, +(2, 1)), builtin, [], []).
step(in_range(3, 5, 4), rule(17), [=('Low', 3), =('High', 5), =('N', 4), =('Next', 4)], [<(3, 5), is(4, +(3, 1)), in_range(4, 5, 4)]).
step(<(3, 5), builtin, [], []).
step(is(4, +(3, 1)), builtin, [], []).
step(in_range(4, 5, 4), rule(16), [=('Low', 4), =('High', 5)], [=<(4, 5)]).
step(=<(4, 5), builtin, [], []).
step(moves(4, [go(loc3), push(loc1), climb_on, grab]), rule(15), [=('N', 4), =('__anon4', go(loc3)), =('Rest', [push(loc1), climb_on, grab]), =('M', 3)], [>(4, 0), is(3, -(4, 1)), moves(3, [push(loc1), climb_on, grab])]).
step(>(4, 0), builtin, [], []).
step(is(3, -(4, 1)), builtin, [], []).
step(moves(3, [push(loc1), climb_on, grab]), rule(15), [=('N', 3), =('__anon4', push(loc1)), =('Rest', [climb_on, grab]), =('M', 2)], [>(3, 0), is(2, -(3, 1)), moves(2, [climb_on, grab])]).
step(>(3, 0), builtin, [], []).
step(is(2, -(3, 1)), builtin, [], []).
step(moves(2, [climb_on, grab]), rule(15), [=('N', 2), =('__anon4', climb_on), =('Rest', [grab]), =('M', 1)], [>(2, 0), is(1, -(2, 1)), moves(1, [grab])]).
step(>(2, 0), builtin, [], []).
step(is(1, -(2, 1)), builtin, [], []).
step(moves(1, [grab]), rule(15), [=('N', 1), =('__anon4', grab), =('Rest', []), =('M', 0)], [>(1, 0), is(0, -(1, 1)), moves(0, [])]).
step(>(1, 0), builtin, [], []).
step(is(0, -(1, 1)), builtin, [], []).
step(moves(0, []), fact(14), [], []).
step(reaches_goal([go(loc3), push(loc1), climb_on, grab]), rule(1), [=('Moves', [go(loc3), push(loc1), climb_on, grab]), =('I', [loc1, loc2, loc3, n, n]), =('G', [loc1, loc1, loc1, y, y])], [initial_state([loc1, loc2, loc3, n, n]), goal_state([loc1, loc1, loc1, y, y]), reachable([loc1, loc2, loc3, n, n], [go(loc3), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(initial_state([loc1, loc2, loc3, n, n]), fact(4), [], []).
step(goal_state([loc1, loc1, loc1, y, y]), fact(5), [=('__anon0', loc1), =('__anon1', loc1), =('__anon2', loc1), =('__anon3', y)], []).
step(reachable([loc1, loc2, loc3, n, n], [go(loc3), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y]), rule(3), [=('S1', [loc1, loc2, loc3, n, n]), =('M', go(loc3)), =('Rest', [push(loc1), climb_on, grab]), =('S3', [loc1, loc1, loc1, y, y]), =('S2', [loc1, loc3, loc3, n, n])], [legal_move([loc1, loc2, loc3, n, n], go(loc3), [loc1, loc3, loc3, n, n]), reachable([loc1, loc3, loc3, n, n], [push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(legal_move([loc1, loc2, loc3, n, n], go(loc3), [loc1, loc3, loc3, n, n]), rule(10), [=('B', loc1), =('M', loc2), =('L', loc3), =('H', n), =('X', loc3)], [location(loc3), \=(loc3, loc2)]).
step(location(loc3), fact(13), [], []).
step(\=(loc3, loc2), builtin, [], []).
step(reachable([loc1, loc3, loc3, n, n], [push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y]), rule(3), [=('S1', [loc1, loc3, loc3, n, n]), =('M', push(loc1)), =('Rest', [climb_on, grab]), =('S3', [loc1, loc1, loc1, y, y]), =('S2', [loc1, loc1, loc1, n, n])], [legal_move([loc1, loc3, loc3, n, n], push(loc1), [loc1, loc1, loc1, n, n]), reachable([loc1, loc1, loc1, n, n], [climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(legal_move([loc1, loc3, loc3, n, n], push(loc1), [loc1, loc1, loc1, n, n]), rule(9), [=('B', loc1), =('M', loc3), =('H', n), =('X', loc1)], [location(loc1), \=(loc1, loc3)]).
step(location(loc1), fact(11), [], []).
step(\=(loc1, loc3), builtin, [], []).
step(reachable([loc1, loc1, loc1, n, n], [climb_on, grab], [loc1, loc1, loc1, y, y]), rule(3), [=('S1', [loc1, loc1, loc1, n, n]), =('M', climb_on), =('Rest', [grab]), =('S3', [loc1, loc1, loc1, y, y]), =('S2', [loc1, loc1, loc1, y, n])], [legal_move([loc1, loc1, loc1, n, n], climb_on, [loc1, loc1, loc1, y, n]), reachable([loc1, loc1, loc1, y, n], [grab], [loc1, loc1, loc1, y, y])]).
step(legal_move([loc1, loc1, loc1, n, n], climb_on, [loc1, loc1, loc1, y, n]), fact(6), [=('B', loc1), =('M', loc1), =('H', n)], []).
step(reachable([loc1, loc1, loc1, y, n], [grab], [loc1, loc1, loc1, y, y]), rule(3), [=('S1', [loc1, loc1, loc1, y, n]), =('M', grab), =('Rest', []), =('S3', [loc1, loc1, loc1, y, y]), =('S2', [loc1, loc1, loc1, y, y])], [legal_move([loc1, loc1, loc1, y, n], grab, [loc1, loc1, loc1, y, y]), reachable([loc1, loc1, loc1, y, y], [], [loc1, loc1, loc1, y, y])]).
step(legal_move([loc1, loc1, loc1, y, n], grab, [loc1, loc1, loc1, y, y]), fact(8), [=('B', loc1)], []).
step(reachable([loc1, loc1, loc1, y, y], [], [loc1, loc1, loc1, y, y]), fact(2), [=('S', [loc1, loc1, loc1, y, y])], []).
step(plan([go(loc1), go(loc3), push(loc1), climb_on, grab]), rule(18), [=('Moves', [go(loc1), go(loc3), push(loc1), climb_on, grab]), =('N', 5)], [in_range(1, 5, 5), moves(5, [go(loc1), go(loc3), push(loc1), climb_on, grab]), reaches_goal([go(loc1), go(loc3), push(loc1), climb_on, grab])]).
step(in_range(1, 5, 5), rule(17), [=('Low', 1), =('High', 5), =('N', 5), =('Next', 2)], [<(1, 5), is(2, +(1, 1)), in_range(2, 5, 5)]).
step(in_range(2, 5, 5), rule(17), [=('Low', 2), =('High', 5), =('N', 5), =('Next', 3)], [<(2, 5), is(3, +(2, 1)), in_range(3, 5, 5)]).
step(in_range(3, 5, 5), rule(17), [=('Low', 3), =('High', 5), =('N', 5), =('Next', 4)], [<(3, 5), is(4, +(3, 1)), in_range(4, 5, 5)]).
step(in_range(4, 5, 5), rule(17), [=('Low', 4), =('High', 5), =('N', 5), =('Next', 5)], [<(4, 5), is(5, +(4, 1)), in_range(5, 5, 5)]).
step(<(4, 5), builtin, [], []).
step(is(5, +(4, 1)), builtin, [], []).
step(in_range(5, 5, 5), rule(16), [=('Low', 5), =('High', 5)], [=<(5, 5)]).
step(=<(5, 5), builtin, [], []).
step(moves(5, [go(loc1), go(loc3), push(loc1), climb_on, grab]), rule(15), [=('N', 5), =('__anon4', go(loc1)), =('Rest', [go(loc3), push(loc1), climb_on, grab]), =('M', 4)], [>(5, 0), is(4, -(5, 1)), moves(4, [go(loc3), push(loc1), climb_on, grab])]).
step(>(5, 0), builtin, [], []).
step(is(4, -(5, 1)), builtin, [], []).
step(reaches_goal([go(loc1), go(loc3), push(loc1), climb_on, grab]), rule(1), [=('Moves', [go(loc1), go(loc3), push(loc1), climb_on, grab]), =('I', [loc1, loc2, loc3, n, n]), =('G', [loc1, loc1, loc1, y, y])], [initial_state([loc1, loc2, loc3, n, n]), goal_state([loc1, loc1, loc1, y, y]), reachable([loc1, loc2, loc3, n, n], [go(loc1), go(loc3), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(reachable([loc1, loc2, loc3, n, n], [go(loc1), go(loc3), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y]), rule(3), [=('S1', [loc1, loc2, loc3, n, n]), =('M', go(loc1)), =('Rest', [go(loc3), push(loc1), climb_on, grab]), =('S3', [loc1, loc1, loc1, y, y]), =('S2', [loc1, loc1, loc3, n, n])], [legal_move([loc1, loc2, loc3, n, n], go(loc1), [loc1, loc1, loc3, n, n]), reachable([loc1, loc1, loc3, n, n], [go(loc3), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(legal_move([loc1, loc2, loc3, n, n], go(loc1), [loc1, loc1, loc3, n, n]), rule(10), [=('B', loc1), =('M', loc2), =('L', loc3), =('H', n), =('X', loc1)], [location(loc1), \=(loc1, loc2)]).
step(\=(loc1, loc2), builtin, [], []).
step(reachable([loc1, loc1, loc3, n, n], [go(loc3), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y]), rule(3), [=('S1', [loc1, loc1, loc3, n, n]), =('M', go(loc3)), =('Rest', [push(loc1), climb_on, grab]), =('S3', [loc1, loc1, loc1, y, y]), =('S2', [loc1, loc3, loc3, n, n])], [legal_move([loc1, loc1, loc3, n, n], go(loc3), [loc1, loc3, loc3, n, n]), reachable([loc1, loc3, loc3, n, n], [push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(legal_move([loc1, loc1, loc3, n, n], go(loc3), [loc1, loc3, loc3, n, n]), rule(10), [=('B', loc1), =('M', loc1), =('L', loc3), =('H', n), =('X', loc3)], [location(loc3), \=(loc3, loc1)]).
step(\=(loc3, loc1), builtin, [], []).
step(plan([go(loc3), push(loc1), climb_on, grab, climb_off]), rule(18), [=('Moves', [go(loc3), push(loc1), climb_on, grab, climb_off]), =('N', 5)], [in_range(1, 5, 5), moves(5, [go(loc3), push(loc1), climb_on, grab, climb_off]), reaches_goal([go(loc3), push(loc1), climb_on, grab, climb_off])]).
step(moves(5, [go(loc3), push(loc1), climb_on, grab, climb_off]), rule(15), [=('N', 5), =('__anon4', go(loc3)), =('Rest', [push(loc1), climb_on, grab, climb_off]), =('M', 4)], [>(5, 0), is(4, -(5, 1)), moves(4, [push(loc1), climb_on, grab, climb_off])]).
step(moves(4, [push(loc1), climb_on, grab, climb_off]), rule(15), [=('N', 4), =('__anon4', push(loc1)), =('Rest', [climb_on, grab, climb_off]), =('M', 3)], [>(4, 0), is(3, -(4, 1)), moves(3, [climb_on, grab, climb_off])]).
step(moves(3, [climb_on, grab, climb_off]), rule(15), [=('N', 3), =('__anon4', climb_on), =('Rest', [grab, climb_off]), =('M', 2)], [>(3, 0), is(2, -(3, 1)), moves(2, [grab, climb_off])]).
step(moves(2, [grab, climb_off]), rule(15), [=('N', 2), =('__anon4', grab), =('Rest', [climb_off]), =('M', 1)], [>(2, 0), is(1, -(2, 1)), moves(1, [climb_off])]).
step(moves(1, [climb_off]), rule(15), [=('N', 1), =('__anon4', climb_off), =('Rest', []), =('M', 0)], [>(1, 0), is(0, -(1, 1)), moves(0, [])]).
step(reaches_goal([go(loc3), push(loc1), climb_on, grab, climb_off]), rule(1), [=('Moves', [go(loc3), push(loc1), climb_on, grab, climb_off]), =('I', [loc1, loc2, loc3, n, n]), =('G', [loc1, loc1, loc1, n, y])], [initial_state([loc1, loc2, loc3, n, n]), goal_state([loc1, loc1, loc1, n, y]), reachable([loc1, loc2, loc3, n, n], [go(loc3), push(loc1), climb_on, grab, climb_off], [loc1, loc1, loc1, n, y])]).
step(goal_state([loc1, loc1, loc1, n, y]), fact(5), [=('__anon0', loc1), =('__anon1', loc1), =('__anon2', loc1), =('__anon3', n)], []).
step(reachable([loc1, loc2, loc3, n, n], [go(loc3), push(loc1), climb_on, grab, climb_off], [loc1, loc1, loc1, n, y]), rule(3), [=('S1', [loc1, loc2, loc3, n, n]), =('M', go(loc3)), =('Rest', [push(loc1), climb_on, grab, climb_off]), =('S3', [loc1, loc1, loc1, n, y]), =('S2', [loc1, loc3, loc3, n, n])], [legal_move([loc1, loc2, loc3, n, n], go(loc3), [loc1, loc3, loc3, n, n]), reachable([loc1, loc3, loc3, n, n], [push(loc1), climb_on, grab, climb_off], [loc1, loc1, loc1, n, y])]).
step(reachable([loc1, loc3, loc3, n, n], [push(loc1), climb_on, grab, climb_off], [loc1, loc1, loc1, n, y]), rule(3), [=('S1', [loc1, loc3, loc3, n, n]), =('M', push(loc1)), =('Rest', [climb_on, grab, climb_off]), =('S3', [loc1, loc1, loc1, n, y]), =('S2', [loc1, loc1, loc1, n, n])], [legal_move([loc1, loc3, loc3, n, n], push(loc1), [loc1, loc1, loc1, n, n]), reachable([loc1, loc1, loc1, n, n], [climb_on, grab, climb_off], [loc1, loc1, loc1, n, y])]).
step(reachable([loc1, loc1, loc1, n, n], [climb_on, grab, climb_off], [loc1, loc1, loc1, n, y]), rule(3), [=('S1', [loc1, loc1, loc1, n, n]), =('M', climb_on), =('Rest', [grab, climb_off]), =('S3', [loc1, loc1, loc1, n, y]), =('S2', [loc1, loc1, loc1, y, n])], [legal_move([loc1, loc1, loc1, n, n], climb_on, [loc1, loc1, loc1, y, n]), reachable([loc1, loc1, loc1, y, n], [grab, climb_off], [loc1, loc1, loc1, n, y])]).
step(reachable([loc1, loc1, loc1, y, n], [grab, climb_off], [loc1, loc1, loc1, n, y]), rule(3), [=('S1', [loc1, loc1, loc1, y, n]), =('M', grab), =('Rest', [climb_off]), =('S3', [loc1, loc1, loc1, n, y]), =('S2', [loc1, loc1, loc1, y, y])], [legal_move([loc1, loc1, loc1, y, n], grab, [loc1, loc1, loc1, y, y]), reachable([loc1, loc1, loc1, y, y], [climb_off], [loc1, loc1, loc1, n, y])]).
step(reachable([loc1, loc1, loc1, y, y], [climb_off], [loc1, loc1, loc1, n, y]), rule(3), [=('S1', [loc1, loc1, loc1, y, y]), =('M', climb_off), =('Rest', []), =('S3', [loc1, loc1, loc1, n, y]), =('S2', [loc1, loc1, loc1, n, y])], [legal_move([loc1, loc1, loc1, y, y], climb_off, [loc1, loc1, loc1, n, y]), reachable([loc1, loc1, loc1, n, y], [], [loc1, loc1, loc1, n, y])]).
step(legal_move([loc1, loc1, loc1, y, y], climb_off, [loc1, loc1, loc1, n, y]), fact(7), [=('B', loc1), =('M', loc1), =('H', y)], []).
step(reachable([loc1, loc1, loc1, n, y], [], [loc1, loc1, loc1, n, y]), fact(2), [=('S', [loc1, loc1, loc1, n, y])], []).
step(plan([go(loc3), push(loc2), push(loc1), climb_on, grab]), rule(18), [=('Moves', [go(loc3), push(loc2), push(loc1), climb_on, grab]), =('N', 5)], [in_range(1, 5, 5), moves(5, [go(loc3), push(loc2), push(loc1), climb_on, grab]), reaches_goal([go(loc3), push(loc2), push(loc1), climb_on, grab])]).
step(moves(5, [go(loc3), push(loc2), push(loc1), climb_on, grab]), rule(15), [=('N', 5), =('__anon4', go(loc3)), =('Rest', [push(loc2), push(loc1), climb_on, grab]), =('M', 4)], [>(5, 0), is(4, -(5, 1)), moves(4, [push(loc2), push(loc1), climb_on, grab])]).
step(moves(4, [push(loc2), push(loc1), climb_on, grab]), rule(15), [=('N', 4), =('__anon4', push(loc2)), =('Rest', [push(loc1), climb_on, grab]), =('M', 3)], [>(4, 0), is(3, -(4, 1)), moves(3, [push(loc1), climb_on, grab])]).
step(reaches_goal([go(loc3), push(loc2), push(loc1), climb_on, grab]), rule(1), [=('Moves', [go(loc3), push(loc2), push(loc1), climb_on, grab]), =('I', [loc1, loc2, loc3, n, n]), =('G', [loc1, loc1, loc1, y, y])], [initial_state([loc1, loc2, loc3, n, n]), goal_state([loc1, loc1, loc1, y, y]), reachable([loc1, loc2, loc3, n, n], [go(loc3), push(loc2), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(reachable([loc1, loc2, loc3, n, n], [go(loc3), push(loc2), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y]), rule(3), [=('S1', [loc1, loc2, loc3, n, n]), =('M', go(loc3)), =('Rest', [push(loc2), push(loc1), climb_on, grab]), =('S3', [loc1, loc1, loc1, y, y]), =('S2', [loc1, loc3, loc3, n, n])], [legal_move([loc1, loc2, loc3, n, n], go(loc3), [loc1, loc3, loc3, n, n]), reachable([loc1, loc3, loc3, n, n], [push(loc2), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(reachable([loc1, loc3, loc3, n, n], [push(loc2), push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y]), rule(3), [=('S1', [loc1, loc3, loc3, n, n]), =('M', push(loc2)), =('Rest', [push(loc1), climb_on, grab]), =('S3', [loc1, loc1, loc1, y, y]), =('S2', [loc1, loc2, loc2, n, n])], [legal_move([loc1, loc3, loc3, n, n], push(loc2), [loc1, loc2, loc2, n, n]), reachable([loc1, loc2, loc2, n, n], [push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(legal_move([loc1, loc3, loc3, n, n], push(loc2), [loc1, loc2, loc2, n, n]), rule(9), [=('B', loc1), =('M', loc3), =('H', n), =('X', loc2)], [location(loc2), \=(loc2, loc3)]).
step(location(loc2), fact(12), [], []).
step(\=(loc2, loc3), builtin, [], []).
step(reachable([loc1, loc2, loc2, n, n], [push(loc1), climb_on, grab], [loc1, loc1, loc1, y, y]), rule(3), [=('S1', [loc1, loc2, loc2, n, n]), =('M', push(loc1)), =('Rest', [climb_on, grab]), =('S3', [loc1, loc1, loc1, y, y]), =('S2', [loc1, loc1, loc1, n, n])], [legal_move([loc1, loc2, loc2, n, n], push(loc1), [loc1, loc1, loc1, n, n]), reachable([loc1, loc1, loc1, n, n], [climb_on, grab], [loc1, loc1, loc1, y, y])]).
step(legal_move([loc1, loc2, loc2, n, n], push(loc1), [loc1, loc1, loc1, n, n]), rule(9), [=('B', loc1), =('M', loc2), =('H', n), =('X', loc1)], [location(loc1), \=(loc1, loc2)]).
