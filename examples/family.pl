% Derive child and ancestor relationships from parent facts.
t(a, father_of, x).
t(b, mother_of, x).
t(c, mother_of, a).
t(X, child_of, Y) :+ t(Y, father_of, X).
t(X, child_of, Y) :+ t(Y, mother_of, X).
t(X, descended_from, Y) :+ t(X, child_of, Y).
t(X, descended_from, Y) :+ t(X, child_of, Z), t(Z, descended_from, Y).
