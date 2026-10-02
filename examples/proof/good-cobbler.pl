good_at(joe, cobbler).
good_at(jane, carpenter).
classified_as(joe, cobbler).
classified_as(jane, carpenter).

clause(1, description(joe, [good, cobbler]), true).
clause(2, description(jane, [good, carpenter]), true).
clause(4, good_at(var('Person'), var('Trade')), description(var('Person'), [good, var('Trade')])).
clause(5, classified_as(var('Person'), var('Trade')), description(var('Person'), [good, var('Trade')])).

step(good_at(joe, cobbler), rule(4), [=('Person', joe), =('Trade', cobbler)], [description(joe, [good, cobbler])]).
step(description(joe, [good, cobbler]), fact(1), [], []).
step(good_at(jane, carpenter), rule(4), [=('Person', jane), =('Trade', carpenter)], [description(jane, [good, carpenter])]).
step(description(jane, [good, carpenter]), fact(2), [], []).
step(classified_as(joe, cobbler), rule(5), [=('Person', joe), =('Trade', cobbler)], [description(joe, [good, cobbler])]).
step(classified_as(jane, carpenter), rule(5), [=('Person', jane), =('Trade', carpenter)], [description(jane, [good, carpenter])]).
