% The Padovan sequence P(n) = P(n-2) + P(n-3), computed by carrying three
% successive values forward. The ratio of successive values converges on the
% plastic ratio, about 1.3247, the real root of x^3 = x + 1.
padovan(N, P) :- padovan(N, 0, 1, 1, P).
padovan(0, A, _, _, A).
padovan(1, _, B, _, B).
padovan(2, _, _, C, C).
padovan(N, A, B, C, P) :- N > 2, M is N-1, D is A+B, padovan(M, B, C, D, P).

plastic_ratio(N, Ratio) :- padovan(N, A), Next is N+1, padovan(Next, B), Ratio is B/A.

true :+ padovan(1, _).
true :+ padovan(2, _).
true :+ padovan(3, _).
true :+ padovan(4, _).
true :+ padovan(5, _).
true :+ padovan(91, _).
true :+ padovan(283, _).
true :+ padovan(3674, _).
true :+ plastic_ratio(1, _).
true :+ plastic_ratio(10, _).
true :+ plastic_ratio(100, _).
true :+ plastic_ratio(1000, _).
