% Enumerate paths in an acyclic weighted graph, then select minimum costs.
edge(a, b, 4).
edge(a, c, 2).
edge(c, b, 1).
edge(b, d, 3).
edge(c, d, 8).
path(X, Y, Cost) :+ edge(X, Y, Cost).
path(X, Z, Cost) :+ path(X, Y, Before), edge(Y, Z, Weight), Cost is Before+Weight.
cheaper(X, Y, Cost) :- path(X, Y, Other), Other < Cost.
shortest(X, Y, Cost) :+ path(X, Y, Cost), \+ cheaper(X, Y, Cost).
true :+ shortest(a, d, Cost).
