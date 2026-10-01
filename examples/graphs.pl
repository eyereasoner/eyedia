% base/3 represents immutable external data. t/3 is the union view.
base(alice, parent_of, bob).
base(alice, parent_of, carol).
base(bob, blocked, true).
t(S, P, O) :- base(S, P, O).
t(C, child_of, P) :+ t(P, parent_of, C).
allowed(C) :+ t(C, child_of, alice), \+ t(C, blocked, true).
children(P, Children) :+ base(P, parent_of, _), findall(C, t(C, child_of, P), Children).
