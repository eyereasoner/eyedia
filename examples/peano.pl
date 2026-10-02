% Symbolic natural numbers: zero, s(zero), s(s(zero)), ...
% Addition also works backward to enumerate ways of splitting a known sum.
add(A, zero, A).
add(A, s(B), s(C)) :- add(A, B, C).
multiply(_, zero, zero).
multiply(A, s(B), C) :- multiply(A, B, D), add(A, D, C).
factorial(zero, s(zero)).
factorial(s(N), F) :- factorial(N, Before), multiply(s(N), Before, F).
% Addition run backward enumerates every way of splitting a known sum.
?- add(A, B, s(s(s(zero)))).
% One derivation chains all three relations: (1*2)+3 = 5, then 5! = 120.
?- multiply(s(zero), s(s(zero)), Product),
   add(Product, s(s(s(zero))), Sum),
   factorial(Sum, Factorial).
