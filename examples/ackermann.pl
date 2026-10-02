% The Ackermann function, computed through the hyperoperation sequence:
% addition, multiplication, exponentiation, tetration, and so on.
% A(X, Y) = hyper(X, Y+3, 2) - 3, and every level above exponentiation is the
% previous level iterated. Integers are exact, so A(4, 2) - a number with 19,729
% digits - is computed in full rather than approximated.
ackermann([X, Y], A) :- B is Y+3, hyper(X, B, 2, C), A is C-3.

% The first four levels have closed forms in ordinary arithmetic.
hyper(0, Y, _, A) :- A is Y+1.
hyper(1, Y, Z, A) :- A is Y+Z.
hyper(2, Y, Z, A) :- A is Y*Z.
hyper(3, Y, Z, A) :- A is Z^Y.
% Above them, level X applied Y times is level X-1 applied to the result of
% level X applied Y-1 times.
hyper(X, 0, _, 1) :- X > 3.
hyper(X, Y, Z, A) :- X > 3, Y > 0, B is Y-1, hyper(X, B, Z, C), D is X-1, hyper(D, C, Z, A).

true :+ ackermann([0, 6], _).
true :+ ackermann([1, 2], _).
true :+ ackermann([1, 7], _).
true :+ ackermann([2, 2], _).
true :+ ackermann([2, 9], _).
true :+ ackermann([3, 4], _).
true :+ ackermann([3, 14], _).
true :+ ackermann([4, 0], _).
true :+ ackermann([4, 1], _).
true :+ ackermann([4, 2], _).
true :+ ackermann([5, 0], _).
