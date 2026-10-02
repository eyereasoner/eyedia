flies(tweety, true).
flies(falco, true).
flies(mythic, true).
wings(tweety, true).
wings(falco, true).
wings(mythic, true).
flies(tweety, false).
flies(opus, false).
wings(batsy, false).
flies(batsy, true).
wings(batsy, true).
swims(nemo, true).
wings(nemo, false).
flies(mythic, false).
flight_status(tweety, both).
flight_status(mythic, both).
wing_status(batsy, both).
inconsistent(tweety, flies).
needs_review(tweety, flies).
inconsistent(mythic, flies).
needs_review(mythic, flies).
inconsistent(batsy, wings).
needs_review(batsy, wings).
flies_safely(tweety, undecided).
flies_safely(mythic, undecided).
wings_safely(batsy, undecided).
moves_by(tweety, unknown).
migrates(tweety, undecided).
moves_by(mythic, unknown).
migrates(mythic, undecided).
flight_status(falco, true_only).
flight_status(batsy, true_only).
flight_status(opus, false_only).
wing_status(tweety, true_only).
wing_status(falco, true_only).
wing_status(mythic, true_only).
wing_status(nemo, false_only).
flies_safely(falco, true).
flies_safely(batsy, true).
flies_safely(opus, false).
wings_safely(tweety, true).
wings_safely(falco, true).
wings_safely(mythic, true).
wings_safely(nemo, false).
moves_by(falco, flying).
migrates(falco, true).
moves_by(batsy, flying).
migrates(batsy, true).
moves_by(opus, walking).
migrates(opus, false).

clause(1, bird(tweety), true).
clause(2, penguin(tweety), true).
clause(3, bird(falco), true).
clause(4, penguin(opus), true).
clause(5, mammal(batsy), true).
clause(6, bat(batsy), true).
clause(7, fish(nemo), true).
clause(8, bird(mythic), true).
clause(9, observed(mythic, flies, false), true).
clause(10, flies(var('X'), true), bird(var('X'))).
clause(11, wings(var('X'), true), bird(var('X'))).
clause(12, flies(var('X'), false), penguin(var('X'))).
clause(13, wings(var('X'), false), mammal(var('X'))).
clause(14, ','(flies(var('X'), true), wings(var('X'), true)), bat(var('X'))).
clause(15, ','(swims(var('X'), true), wings(var('X'), false)), fish(var('X'))).
clause(16, flies(var('X'), var('Value')), observed(var('X'), flies, var('Value'))).
clause(17, flight_status(var('X'), both), ','(flies(var('X'), true), flies(var('X'), false))).
clause(18, flight_status(var('X'), true_only), ','(flies(var('X'), true), \+(flies(var('X'), false)))).
clause(19, flight_status(var('X'), false_only), ','(flies(var('X'), false), \+(flies(var('X'), true)))).
clause(20, wing_status(var('X'), both), ','(wings(var('X'), true), wings(var('X'), false))).
clause(21, wing_status(var('X'), true_only), ','(wings(var('X'), true), \+(wings(var('X'), false)))).
clause(22, wing_status(var('X'), false_only), ','(wings(var('X'), false), \+(wings(var('X'), true)))).
clause(23, ','(inconsistent(var('X'), flies), needs_review(var('X'), flies)), flight_status(var('X'), both)).
clause(24, ','(inconsistent(var('X'), wings), needs_review(var('X'), wings)), wing_status(var('X'), both)).
clause(25, flies_safely(var('X'), true), flight_status(var('X'), true_only)).
clause(26, flies_safely(var('X'), false), flight_status(var('X'), false_only)).
clause(27, flies_safely(var('X'), undecided), flight_status(var('X'), both)).
clause(28, wings_safely(var('X'), true), wing_status(var('X'), true_only)).
clause(29, wings_safely(var('X'), false), wing_status(var('X'), false_only)).
clause(30, wings_safely(var('X'), undecided), wing_status(var('X'), both)).
clause(31, ','(moves_by(var('X'), flying), migrates(var('X'), true)), flight_status(var('X'), true_only)).
clause(32, ','(moves_by(var('X'), walking), migrates(var('X'), false)), flight_status(var('X'), false_only)).
clause(33, ','(moves_by(var('X'), unknown), migrates(var('X'), undecided)), flight_status(var('X'), both)).

step(flies(tweety, true), rule(10), [=('X', tweety)], [bird(tweety)]).
step(bird(tweety), fact(1), [], []).
step(flies(falco, true), rule(10), [=('X', falco)], [bird(falco)]).
step(bird(falco), fact(3), [], []).
step(flies(mythic, true), rule(10), [=('X', mythic)], [bird(mythic)]).
step(bird(mythic), fact(8), [], []).
step(wings(tweety, true), rule(11), [=('X', tweety)], [bird(tweety)]).
step(wings(falco, true), rule(11), [=('X', falco)], [bird(falco)]).
step(wings(mythic, true), rule(11), [=('X', mythic)], [bird(mythic)]).
step(flies(tweety, false), rule(12), [=('X', tweety)], [penguin(tweety)]).
step(penguin(tweety), fact(2), [], []).
step(flies(opus, false), rule(12), [=('X', opus)], [penguin(opus)]).
step(penguin(opus), fact(4), [], []).
step(wings(batsy, false), rule(13), [=('X', batsy)], [mammal(batsy)]).
step(mammal(batsy), fact(5), [], []).
step(flies(batsy, true), rule(14), [=('X', batsy)], [bat(batsy)]).
step(bat(batsy), fact(6), [], []).
step(wings(batsy, true), rule(14), [=('X', batsy)], [bat(batsy)]).
step(swims(nemo, true), rule(15), [=('X', nemo)], [fish(nemo)]).
step(fish(nemo), fact(7), [], []).
step(wings(nemo, false), rule(15), [=('X', nemo)], [fish(nemo)]).
step(flies(mythic, false), rule(16), [=('X', mythic), =('Value', false)], [observed(mythic, flies, false)]).
step(observed(mythic, flies, false), fact(9), [], []).
step(flight_status(tweety, both), rule(17), [=('X', tweety)], [flies(tweety, true), flies(tweety, false)]).
step(flight_status(mythic, both), rule(17), [=('X', mythic)], [flies(mythic, true), flies(mythic, false)]).
step(wing_status(batsy, both), rule(20), [=('X', batsy)], [wings(batsy, true), wings(batsy, false)]).
step(inconsistent(tweety, flies), rule(23), [=('X', tweety)], [flight_status(tweety, both)]).
step(needs_review(tweety, flies), rule(23), [=('X', tweety)], [flight_status(tweety, both)]).
step(inconsistent(mythic, flies), rule(23), [=('X', mythic)], [flight_status(mythic, both)]).
step(needs_review(mythic, flies), rule(23), [=('X', mythic)], [flight_status(mythic, both)]).
step(inconsistent(batsy, wings), rule(24), [=('X', batsy)], [wing_status(batsy, both)]).
step(needs_review(batsy, wings), rule(24), [=('X', batsy)], [wing_status(batsy, both)]).
step(flies_safely(tweety, undecided), rule(27), [=('X', tweety)], [flight_status(tweety, both)]).
step(flies_safely(mythic, undecided), rule(27), [=('X', mythic)], [flight_status(mythic, both)]).
step(wings_safely(batsy, undecided), rule(30), [=('X', batsy)], [wing_status(batsy, both)]).
step(moves_by(tweety, unknown), rule(33), [=('X', tweety)], [flight_status(tweety, both)]).
step(migrates(tweety, undecided), rule(33), [=('X', tweety)], [flight_status(tweety, both)]).
step(moves_by(mythic, unknown), rule(33), [=('X', mythic)], [flight_status(mythic, both)]).
step(migrates(mythic, undecided), rule(33), [=('X', mythic)], [flight_status(mythic, both)]).
step(flight_status(falco, true_only), rule(18), [=('X', falco)], [flies(falco, true), \+(flies(falco, false))]).
step(\+(flies(falco, false)), absent, [], []).
step(flight_status(batsy, true_only), rule(18), [=('X', batsy)], [flies(batsy, true), \+(flies(batsy, false))]).
step(\+(flies(batsy, false)), absent, [], []).
step(flight_status(opus, false_only), rule(19), [=('X', opus)], [flies(opus, false), \+(flies(opus, true))]).
step(\+(flies(opus, true)), absent, [], []).
step(wing_status(tweety, true_only), rule(21), [=('X', tweety)], [wings(tweety, true), \+(wings(tweety, false))]).
step(\+(wings(tweety, false)), absent, [], []).
step(wing_status(falco, true_only), rule(21), [=('X', falco)], [wings(falco, true), \+(wings(falco, false))]).
step(\+(wings(falco, false)), absent, [], []).
step(wing_status(mythic, true_only), rule(21), [=('X', mythic)], [wings(mythic, true), \+(wings(mythic, false))]).
step(\+(wings(mythic, false)), absent, [], []).
step(wing_status(nemo, false_only), rule(22), [=('X', nemo)], [wings(nemo, false), \+(wings(nemo, true))]).
step(\+(wings(nemo, true)), absent, [], []).
step(flies_safely(falco, true), rule(25), [=('X', falco)], [flight_status(falco, true_only)]).
step(flies_safely(batsy, true), rule(25), [=('X', batsy)], [flight_status(batsy, true_only)]).
step(flies_safely(opus, false), rule(26), [=('X', opus)], [flight_status(opus, false_only)]).
step(wings_safely(tweety, true), rule(28), [=('X', tweety)], [wing_status(tweety, true_only)]).
step(wings_safely(falco, true), rule(28), [=('X', falco)], [wing_status(falco, true_only)]).
step(wings_safely(mythic, true), rule(28), [=('X', mythic)], [wing_status(mythic, true_only)]).
step(wings_safely(nemo, false), rule(29), [=('X', nemo)], [wing_status(nemo, false_only)]).
step(moves_by(falco, flying), rule(31), [=('X', falco)], [flight_status(falco, true_only)]).
step(migrates(falco, true), rule(31), [=('X', falco)], [flight_status(falco, true_only)]).
step(moves_by(batsy, flying), rule(31), [=('X', batsy)], [flight_status(batsy, true_only)]).
step(migrates(batsy, true), rule(31), [=('X', batsy)], [flight_status(batsy, true_only)]).
step(moves_by(opus, walking), rule(32), [=('X', opus)], [flight_status(opus, false_only)]).
step(migrates(opus, false), rule(32), [=('X', opus)], [flight_status(opus, false_only)]).
