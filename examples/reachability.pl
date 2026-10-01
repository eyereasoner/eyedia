% Materialize every reachable pair in a graph containing a cycle.
edge(a, b).
edge(b, c).
edge(c, a).
edge(c, d).
reachable(X, Y) :+ edge(X, Y).
reachable(X, Z) :+ reachable(X, Y), edge(Y, Z).
