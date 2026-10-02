posterior(paper_jam, 18000, 37200, 0.4838709677419355).
posterior(network_loss, 14250, 37200, 0.38306451612903225).
posterior(power_loss, 4950, 37200, 0.13306451612903225).

clause(1, fault(paper_jam, 20, 90, 10), true).
clause(2, fault(network_loss, 30, 5, 95), true).
clause(3, fault(power_loss, 50, 1, 99), true).
clause(4, weight(var('Fault'), var('Weight')), ','(fault(var('Fault'), var('Prior'), var('Jam'), var('Offline')), is(var('Weight'), *(*(var('Prior'), var('Jam')), var('Offline'))))).
clause(5, sum_weights([], 0), true).
clause(6, sum_weights([var('W')|var('Ws')], var('Sum')), ','(sum_weights(var('Ws'), var('Rest')), is(var('Sum'), +(var('W'), var('Rest'))))).
clause(7, total(var('Total')), ','(findall(var('W'), weight(var('Fault'), var('W')), var('Weights')), sum_weights(var('Weights'), var('Total')))).
clause(8, posterior(var('Fault'), var('Numerator'), var('Denominator'), var('Probability')), ','(weight(var('Fault'), var('Numerator')), ','(total(var('Denominator')), ','(>(var('Denominator'), 0), is(var('Probability'), /(var('Numerator'), var('Denominator'))))))).

step(posterior(paper_jam, 18000, 37200, 0.4838709677419355), rule(8), [=('Fault', paper_jam), =('Numerator', 18000), =('Denominator', 37200), =('Probability', 0.4838709677419355)], [weight(paper_jam, 18000), total(37200), >(37200, 0), is(0.4838709677419355, /(18000, 37200))]).
step(weight(paper_jam, 18000), rule(4), [=('Fault', paper_jam), =('Weight', 18000), =('Prior', 20), =('Jam', 90), =('Offline', 10)], [fault(paper_jam, 20, 90, 10), is(18000, *(*(20, 90), 10))]).
step(fault(paper_jam, 20, 90, 10), fact(1), [], []).
step(is(18000, *(*(20, 90), 10)), builtin, [], []).
step(total(37200), rule(7), [=('Total', 37200), =('W', EYE_57_23_39), =('Fault', EYE_46_61_75_6c_74_23_39), =('Weights', [18000, 14250, 4950])], [findall(EYE_57_23_39, weight(EYE_46_61_75_6c_74_23_39, EYE_57_23_39), [18000, 14250, 4950]), sum_weights([18000, 14250, 4950], 37200)]).
step(findall(EYE_57_23_39, weight(EYE_46_61_75_6c_74_23_39, EYE_57_23_39), [18000, 14250, 4950]), collected, [], []).
step(sum_weights([18000, 14250, 4950], 37200), rule(6), [=('W', 18000), =('Ws', [14250, 4950]), =('Sum', 37200), =('Rest', 19200)], [sum_weights([14250, 4950], 19200), is(37200, +(18000, 19200))]).
step(sum_weights([14250, 4950], 19200), rule(6), [=('W', 14250), =('Ws', [4950]), =('Sum', 19200), =('Rest', 4950)], [sum_weights([4950], 4950), is(19200, +(14250, 4950))]).
step(sum_weights([4950], 4950), rule(6), [=('W', 4950), =('Ws', []), =('Sum', 4950), =('Rest', 0)], [sum_weights([], 0), is(4950, +(4950, 0))]).
step(sum_weights([], 0), fact(5), [], []).
step(is(4950, +(4950, 0)), builtin, [], []).
step(is(19200, +(14250, 4950)), builtin, [], []).
step(is(37200, +(18000, 19200)), builtin, [], []).
step(>(37200, 0), builtin, [], []).
step(is(0.4838709677419355, /(18000, 37200)), builtin, [], []).
step(posterior(network_loss, 14250, 37200, 0.38306451612903225), rule(8), [=('Fault', network_loss), =('Numerator', 14250), =('Denominator', 37200), =('Probability', 0.38306451612903225)], [weight(network_loss, 14250), total(37200), >(37200, 0), is(0.38306451612903225, /(14250, 37200))]).
step(weight(network_loss, 14250), rule(4), [=('Fault', network_loss), =('Weight', 14250), =('Prior', 30), =('Jam', 5), =('Offline', 95)], [fault(network_loss, 30, 5, 95), is(14250, *(*(30, 5), 95))]).
step(fault(network_loss, 30, 5, 95), fact(2), [], []).
step(is(14250, *(*(30, 5), 95)), builtin, [], []).
step(is(0.38306451612903225, /(14250, 37200)), builtin, [], []).
step(posterior(power_loss, 4950, 37200, 0.13306451612903225), rule(8), [=('Fault', power_loss), =('Numerator', 4950), =('Denominator', 37200), =('Probability', 0.13306451612903225)], [weight(power_loss, 4950), total(37200), >(37200, 0), is(0.13306451612903225, /(4950, 37200))]).
step(weight(power_loss, 4950), rule(4), [=('Fault', power_loss), =('Weight', 4950), =('Prior', 50), =('Jam', 1), =('Offline', 99)], [fault(power_loss, 50, 1, 99), is(4950, *(*(50, 1), 99))]).
step(fault(power_loss, 50, 1, 99), fact(3), [], []).
step(is(4950, *(*(50, 1), 99)), builtin, [], []).
step(is(0.13306451612903225, /(4950, 37200)), builtin, [], []).
