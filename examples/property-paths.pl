% Compose relationships, invert one, and follow a repeatable path.
parent(alice, bob).
parent(bob, carol).
parent(carol, dave).
% A fixed-length composition: parent followed by parent.
grandparent(X, Z) :+ parent(X, Y), parent(Y, Z).
% The inverse of a relation, read from the other end.
has_parent(Child, Parent) :+ parent(Parent, Child).
% An arbitrary-length path, closed by forward materialization.
descendant(X, Y) :+ parent(Y, X).
descendant(X, Z) :+ descendant(X, Y), parent(Z, Y).
