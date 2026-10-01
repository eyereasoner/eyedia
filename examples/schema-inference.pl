% Subclass and subproperty closure propagates types and relationships.
subclass(cat, mammal).
subclass(mammal, animal).
subproperty(parent_of, related_to).
domain(parent_of, person).
range(parent_of, person).
type(koko, cat).
triple(alice, parent_of, bob).
subclass(A, C) :+ subclass(A, B), subclass(B, C).
type(X, B) :+ type(X, A), subclass(A, B).
triple(S, Q, O) :+ triple(S, P, O), subproperty(P, Q).
type(S, Class) :+ triple(S, P, _), domain(P, Class).
type(O, Class) :+ triple(_, P, O), range(P, Class).
