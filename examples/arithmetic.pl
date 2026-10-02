% Factorial and Euclid's algorithm use exact integer arithmetic.
factorial(0, 1).
factorial(N, F) :- N > 0, Previous is N-1, factorial(Previous, Rest), F is N*Rest.
gcd(A, 0, A).
gcd(A, B, G) :- B > 0, Remainder is A mod B, gcd(B, Remainder, G).
true :+ factorial(20, F).
true :+ gcd(1071, 462, G).
true :+ is(Power, 2^80).
