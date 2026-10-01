% An ordered event log defines a relation between successive account states.
opening_balance(100).
event(1, deposit, 25).
event(2, withdraw, 40).
event(3, withdraw, 20).
balance(0, Amount) :- opening_balance(Amount).
balance(N, Amount) :- N > 0, event(N, deposit, Value), Before is N-1, balance(Before, Previous), Amount is Previous+Value.
balance(N, Amount) :- N > 0, event(N, withdraw, Value), Before is N-1, balance(Before, Previous), Amount is Previous-Value.
?- balance(3, Amount).
