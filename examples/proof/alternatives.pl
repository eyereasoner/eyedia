route(paris, brussels).
route(paris, lille).
;(train(paris, brussels), bus(paris, lille)).
once(route(paris, brussels)).

clause(1, train(paris, brussels), true).
clause(2, bus(paris, lille), true).
clause(3, route(var('From'), var('To')), train(var('From'), var('To'))).
clause(4, route(var('From'), var('To')), bus(var('From'), var('To'))).

step(route(paris, brussels), rule(3), [=('From', paris), =('To', brussels)], [train(paris, brussels)]).
step(train(paris, brussels), fact(1), [], []).
step(route(paris, lille), rule(4), [=('From', paris), =('To', lille)], [bus(paris, lille)]).
step(bus(paris, lille), fact(2), [], []).
step(;(train(paris, brussels), bus(paris, lille)), control, [], [train(paris, brussels)]).
step(once(route(paris, brussels)), control, [], [route(paris, brussels)]).
