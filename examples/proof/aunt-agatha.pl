witness(agatha, world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no))).
models(agatha, 4).
models(butler, 0).
models(charles, 0).
entailed(killed(agatha, agatha)).

clause(1, model(var('Killer'), world(var('Richer'), var('Hates'))), ','(=(var('Richer'), richer(var('RA'), var('RB'), var('RC'))), ','(=(var('Hates'), hates(var('AA'), var('AB'), var('AC'), var('BA'), var('BB'), var('BC'), var('CA'), var('CB'), var('CC'))), ','(resident(var('Killer')), ','(hates(var('Hates'), var('Killer'), agatha, yes), ','(richer(var('Richer'), var('Killer'), no), ','(implies_not(var('AA'), var('CA')), ','(implies_not(var('AB'), var('CB')), ','(implies_not(var('AC'), var('CC')), ','(=(var('AA'), yes), ','(=(var('AC'), yes), ','(unless(var('RA'), var('BA')), ','(unless(var('RB'), var('BB')), ','(unless(var('RC'), var('BC')), ','(implies(var('AA'), var('BA')), ','(implies(var('AB'), var('BB')), ','(implies(var('AC'), var('BC')), ','(label([var('RA'), var('RB'), var('RC'), var('AA'), var('AB'), var('AC'), var('BA'), var('BB'), var('BC'), var('CA'), var('CB'), var('CC')]), ','(some_no(var('AA'), var('AB'), var('AC')), ','(some_no(var('BA'), var('BB'), var('BC')), some_no(var('CA'), var('CB'), var('CC')))))))))))))))))))))).
clause(2, resident(agatha), true).
clause(3, resident(butler), true).
clause(4, resident(charles), true).
clause(5, hates(hates(var('V'), var('__anon0'), var('__anon1'), var('__anon2'), var('__anon3'), var('__anon4'), var('__anon5'), var('__anon6'), var('__anon7')), agatha, agatha, var('V')), true).
clause(14, richer(richer(var('V'), var('__anon72'), var('__anon73')), agatha, var('V')), true).
clause(17, truth(yes), true).
clause(18, truth(no), true).
clause(19, label([]), true).
clause(20, label([var('V')|var('Vs')]), ','(truth(var('V')), label(var('Vs')))).
clause(21, implies(no, var('__anon78')), true).
clause(22, implies(yes, yes), true).
clause(23, implies_not(no, var('__anon79')), true).
clause(24, implies_not(yes, no), true).
clause(25, unless(yes, var('__anon80')), true).
clause(26, unless(no, yes), true).
clause(27, some_no(no, var('__anon81'), var('__anon82')), true).
clause(28, some_no(yes, no, var('__anon83')), true).
clause(30, count([], 0), true).
clause(31, count([var('__anon84')|var('Xs')], var('N')), ','(count(var('Xs'), var('M')), is(var('N'), +(var('M'), 1)))).
clause(32, models(var('Suspect'), var('N')), ','(resident(var('Suspect')), ','(findall(var('W'), model(var('Suspect'), var('W')), var('Ws')), count(var('Ws'), var('N'))))).
clause(33, entailed(killed(agatha, agatha)), ','(models(agatha, var('N')), ','(>(var('N'), 0), ','(models(butler, 0), models(charles, 0))))).
clause(34, witness(var('Killer'), var('W')), once(model(var('Killer'), var('W')))).

step(witness(agatha, world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no))), rule(34), [=('Killer', agatha), =('W', world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no)))], [once(model(agatha, world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no))))]).
step(once(model(agatha, world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no)))), control, [], [model(agatha, world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no)))]).
step(model(agatha, world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no))), rule(1), [=('Killer', agatha), =('Richer', richer(no, yes, yes)), =('Hates', hates(yes, no, yes, yes, no, yes, no, yes, no)), =('RA', no), =('RB', yes), =('RC', yes), =('AA', yes), =('AB', no), =('AC', yes), =('BA', yes), =('BB', no), =('BC', yes), =('CA', no), =('CB', yes), =('CC', no)], [=(richer(no, yes, yes), richer(no, yes, yes)), =(hates(yes, no, yes, yes, no, yes, no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), resident(agatha), hates(hates(yes, no, yes, yes, no, yes, no, yes, no), agatha, agatha, yes), richer(richer(no, yes, yes), agatha, no), implies_not(yes, no), implies_not(no, yes), implies_not(yes, no), =(yes, yes), =(yes, yes), unless(no, yes), unless(yes, no), unless(yes, yes), implies(yes, yes), implies(no, no), implies(yes, yes), label([no, yes, yes, yes, no, yes, yes, no, yes, no, yes, no]), some_no(yes, no, yes), some_no(yes, no, yes), some_no(no, yes, no)]).
step(=(richer(no, yes, yes), richer(no, yes, yes)), builtin, [], []).
step(=(hates(yes, no, yes, yes, no, yes, no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), builtin, [], []).
step(resident(agatha), fact(2), [], []).
step(hates(hates(yes, no, yes, yes, no, yes, no, yes, no), agatha, agatha, yes), fact(5), [=('V', yes), =('__anon0', no), =('__anon1', yes), =('__anon2', yes), =('__anon3', no), =('__anon4', yes), =('__anon5', no), =('__anon6', yes), =('__anon7', no)], []).
step(richer(richer(no, yes, yes), agatha, no), fact(14), [=('V', no), =('__anon72', yes), =('__anon73', yes)], []).
step(implies_not(yes, no), fact(24), [], []).
step(implies_not(no, yes), fact(23), [=('__anon79', yes)], []).
step(=(yes, yes), builtin, [], []).
step(unless(no, yes), fact(26), [], []).
step(unless(yes, no), fact(25), [=('__anon80', no)], []).
step(unless(yes, yes), fact(25), [=('__anon80', yes)], []).
step(implies(yes, yes), fact(22), [], []).
step(implies(no, no), fact(21), [=('__anon78', no)], []).
step(label([no, yes, yes, yes, no, yes, yes, no, yes, no, yes, no]), rule(20), [=('V', no), =('Vs', [yes, yes, yes, no, yes, yes, no, yes, no, yes, no])], [truth(no), label([yes, yes, yes, no, yes, yes, no, yes, no, yes, no])]).
step(truth(no), fact(18), [], []).
step(label([yes, yes, yes, no, yes, yes, no, yes, no, yes, no]), rule(20), [=('V', yes), =('Vs', [yes, yes, no, yes, yes, no, yes, no, yes, no])], [truth(yes), label([yes, yes, no, yes, yes, no, yes, no, yes, no])]).
step(truth(yes), fact(17), [], []).
step(label([yes, yes, no, yes, yes, no, yes, no, yes, no]), rule(20), [=('V', yes), =('Vs', [yes, no, yes, yes, no, yes, no, yes, no])], [truth(yes), label([yes, no, yes, yes, no, yes, no, yes, no])]).
step(label([yes, no, yes, yes, no, yes, no, yes, no]), rule(20), [=('V', yes), =('Vs', [no, yes, yes, no, yes, no, yes, no])], [truth(yes), label([no, yes, yes, no, yes, no, yes, no])]).
step(label([no, yes, yes, no, yes, no, yes, no]), rule(20), [=('V', no), =('Vs', [yes, yes, no, yes, no, yes, no])], [truth(no), label([yes, yes, no, yes, no, yes, no])]).
step(label([yes, yes, no, yes, no, yes, no]), rule(20), [=('V', yes), =('Vs', [yes, no, yes, no, yes, no])], [truth(yes), label([yes, no, yes, no, yes, no])]).
step(label([yes, no, yes, no, yes, no]), rule(20), [=('V', yes), =('Vs', [no, yes, no, yes, no])], [truth(yes), label([no, yes, no, yes, no])]).
step(label([no, yes, no, yes, no]), rule(20), [=('V', no), =('Vs', [yes, no, yes, no])], [truth(no), label([yes, no, yes, no])]).
step(label([yes, no, yes, no]), rule(20), [=('V', yes), =('Vs', [no, yes, no])], [truth(yes), label([no, yes, no])]).
step(label([no, yes, no]), rule(20), [=('V', no), =('Vs', [yes, no])], [truth(no), label([yes, no])]).
step(label([yes, no]), rule(20), [=('V', yes), =('Vs', [no])], [truth(yes), label([no])]).
step(label([no]), rule(20), [=('V', no), =('Vs', [])], [truth(no), label([])]).
step(label([]), fact(19), [], []).
step(some_no(yes, no, yes), fact(28), [=('__anon83', yes)], []).
step(some_no(no, yes, no), fact(27), [=('__anon81', yes), =('__anon82', no)], []).
step(models(agatha, 4), rule(32), [=('Suspect', agatha), =('N', 4), =('W', EYE_57_23_31_36_39), =('Ws', [world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, no, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))])], [resident(agatha), findall(EYE_57_23_31_36_39, model(agatha, EYE_57_23_31_36_39), [world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, no, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))]), count([world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, no, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))], 4)]).
step(findall(EYE_57_23_31_36_39, model(agatha, EYE_57_23_31_36_39), [world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, no, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))]), collected, [], []).
step(count([world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, no, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))], 4), rule(31), [=('__anon84', world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, yes, no))), =('Xs', [world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, no, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))]), =('N', 4), =('M', 3)], [count([world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, no, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))], 3), is(4, +(3, 1))]).
step(count([world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, no, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))], 3), rule(31), [=('__anon84', world(richer(no, yes, yes), hates(yes, no, yes, yes, no, yes, no, no, no))), =('Xs', [world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))]), =('N', 3), =('M', 2)], [count([world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))], 2), is(3, +(2, 1))]).
step(count([world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no)), world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))], 2), rule(31), [=('__anon84', world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, yes, no))), =('Xs', [world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))]), =('N', 2), =('M', 1)], [count([world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))], 1), is(2, +(1, 1))]).
step(count([world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))], 1), rule(31), [=('__anon84', world(richer(no, yes, no), hates(yes, no, yes, yes, no, yes, no, no, no))), =('Xs', []), =('N', 1), =('M', 0)], [count([], 0), is(1, +(0, 1))]).
step(count([], 0), fact(30), [], []).
step(is(1, +(0, 1)), builtin, [], []).
step(is(2, +(1, 1)), builtin, [], []).
step(is(3, +(2, 1)), builtin, [], []).
step(is(4, +(3, 1)), builtin, [], []).
step(models(butler, 0), rule(32), [=('Suspect', butler), =('N', 0), =('W', EYE_57_23_31_36_39), =('Ws', [])], [resident(butler), findall(EYE_57_23_31_36_39, model(butler, EYE_57_23_31_36_39), []), count([], 0)]).
step(resident(butler), fact(3), [], []).
step(findall(EYE_57_23_31_36_39, model(butler, EYE_57_23_31_36_39), []), collected, [], []).
step(models(charles, 0), rule(32), [=('Suspect', charles), =('N', 0), =('W', EYE_57_23_31_36_39), =('Ws', [])], [resident(charles), findall(EYE_57_23_31_36_39, model(charles, EYE_57_23_31_36_39), []), count([], 0)]).
step(resident(charles), fact(4), [], []).
step(findall(EYE_57_23_31_36_39, model(charles, EYE_57_23_31_36_39), []), collected, [], []).
step(entailed(killed(agatha, agatha)), rule(33), [=('N', 4)], [models(agatha, 4), >(4, 0), models(butler, 0), models(charles, 0)]).
step(>(4, 0), builtin, [], []).
