% Alternative clauses, disjunction and once provide goal-directed choices.
train(paris, brussels).
bus(paris, lille).
route(From, To) :- train(From, To).
route(From, To) :- bus(From, To).
?- route(paris, To).
?- (train(paris, brussels); bus(paris, lille)).
?- once(route(paris, To)).
