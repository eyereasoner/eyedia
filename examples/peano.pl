% Symbolic natural numbers: zero, s(zero), s(s(zero)), ...
% Addition also works backward to enumerate ways of splitting a known sum.
add(A, zero, A).
add(A, s(B), s(C)) :- add(A, B, C).
multiply(_, zero, zero).
multiply(A, s(B), C) :- multiply(A, B, D), add(A, D, C).
factorial(zero, s(zero)).
factorial(s(N), F) :- factorial(N, Before), multiply(s(N), Before, F).
?- add(A, B, s(s(s(zero)))).
?- multiply(s(s(zero)), s(s(s(zero))), Product).
?- factorial(s(s(s(zero))), Factorial).
