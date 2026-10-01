% Compose relationships and follow a repeatable path with forward closure.
parent(alice, bob).
parent(bob, carol).
parent(carol, dave).
grandparent(X, Z) :+ parent(X, Y), parent(Y, Z).
descendant(X, Y) :+ parent(Y, X).
descendant(X, Z) :+ descendant(X, Y), parent(Z, Y).
true :+ descendant(Person, alice).
