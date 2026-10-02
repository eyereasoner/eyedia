% Alternative clauses, disjunction and once provide goal-directed choices.
train(paris, brussels).
bus(paris, lille).
route(From, To) :- train(From, To).
route(From, To) :- bus(From, To).
true :+ route(paris, To).
true :+ (train(paris, brussels); bus(paris, lille)).
true :+ once(route(paris, To)).
