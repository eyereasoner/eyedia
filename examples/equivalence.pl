% Identity is an explicit relation; it is distinct from variable unification.
same_as(alice, alice_alias).
same_as(alice_alias, author_42).
name(alice, 'Alice').
same_as(Y, X) :+ same_as(X, Y).
same_as(X, Z) :+ same_as(X, Y), same_as(Y, Z).
name(Y, Name) :+ same_as(X, Y), name(X, Name).
true :+ name(Person, Name).
