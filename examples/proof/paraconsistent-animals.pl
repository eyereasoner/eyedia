flight_status(tweety, both).
flight_status(falco, true_only).
flight_status(opus, false_only).

clause(1, bird(tweety), true).
clause(2, penguin(tweety), true).
clause(3, bird(falco), true).
clause(4, penguin(opus), true).
clause(5, flies(var('X'), true), bird(var('X'))).
clause(6, flies(var('X'), false), penguin(var('X'))).
clause(7, flight_status(var('X'), both), ','(flies(var('X'), true), flies(var('X'), false))).
clause(8, flight_status(var('X'), true_only), ','(flies(var('X'), true), \+(flies(var('X'), false)))).
clause(9, flight_status(var('X'), false_only), ','(flies(var('X'), false), \+(flies(var('X'), true)))).

step(flight_status(tweety, both), rule(7), '.'(=('X', tweety), []), '.'(flies(tweety, true), '.'(flies(tweety, false), []))).
step(flies(tweety, true), rule(5), '.'(=('X', tweety), []), '.'(bird(tweety), [])).
step(bird(tweety), fact(1), [], []).
step(flies(tweety, false), rule(6), '.'(=('X', tweety), []), '.'(penguin(tweety), [])).
step(penguin(tweety), fact(2), [], []).
step(flight_status(falco, true_only), rule(8), '.'(=('X', falco), []), '.'(flies(falco, true), '.'(\+(flies(falco, false)), []))).
step(flies(falco, true), rule(5), '.'(=('X', falco), []), '.'(bird(falco), [])).
step(bird(falco), fact(3), [], []).
step(\+(flies(falco, false)), absent, [], []).
step(flight_status(opus, false_only), rule(9), '.'(=('X', opus), []), '.'(flies(opus, false), '.'(\+(flies(opus, true)), []))).
step(flies(opus, false), rule(6), '.'(=('X', opus), []), '.'(penguin(opus), [])).
step(penguin(opus), fact(4), [], []).
step(\+(flies(opus, true)), absent, [], []).
