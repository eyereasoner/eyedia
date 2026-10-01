% Conflicting observations are retained as data and summarized locally.
bird(tweety).
penguin(tweety).
bird(falco).
penguin(opus).
flies(X, true) :+ bird(X).
flies(X, false) :+ penguin(X).
flight_status(X, both) :+ flies(X, true), flies(X, false).
flight_status(X, true_only) :+ flies(X, true), \+ flies(X, false).
flight_status(X, false_only) :+ flies(X, false), \+ flies(X, true).
true :+ flight_status(Animal, Status).
