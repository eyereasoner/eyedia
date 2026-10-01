% Audit each quoted graph separately: a fact in one scope does not fill another.
context(approved, graph([triple(alice, role, editor), triple(alice, consent, yes)])).
context(incomplete, graph([triple(bob, role, editor)])).
member(X, [X|_]).
member(X, [_|Xs]) :- member(X, Xs).
includes(graph(Triples), Triple) :- member(Triple, Triples).
consented(Context, Person) :+ context(Context, Graph), includes(Graph, triple(Person, consent, yes)).
needs_review(Context, Person) :+ context(Context, Graph), includes(Graph, triple(Person, role, editor)), \+ includes(Graph, triple(Person, consent, yes)).
