% Class membership follows a class hierarchy: Socrates is human, and every
% human is mortal, so the subclass rule concludes that Socrates is mortal.
type(socrates, human).
subclass_of(human, mortal).
type(S, B) :+ type(S, A), subclass_of(A, B).
% The query reports every class membership, asserted as well as derived.
true :+ type(X, Y).
