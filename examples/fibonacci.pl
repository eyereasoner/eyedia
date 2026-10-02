% Fast doubling computes F(N) and F(N+1) together in logarithmic depth.
% F(2K) = F(K)*(2*F(K+1)-F(K)); F(2K+1) = F(K)^2+F(K+1)^2.
% Integer arithmetic keeps even very large results exact.
fib(N, F) :- N >= 0, fib_pair(N, F, _).
fib_pair(0, 0, 1).
fib_pair(N, A, B) :- N > 0, Half is N//2, fib_pair(Half, X, Y), C is X*(2*Y-X), D is X*X+Y*Y, parity_pair(N, C, D, A, B).
parity_pair(N, C, D, A, B) :- 0 =:= N mod 2, A=C, B=D.
parity_pair(N, C, D, A, B) :- 1 =:= N mod 2, A=D, B is C+D.
% The ratio of successive Fibonacci numbers converges on the golden ratio.
golden_ratio(N, Ratio) :- fib(N, A), A > 0, Next is N+1, fib(Next, B), Ratio is B/A.
true :+ fib(0, F).
true :+ fib(1, F).
true :+ fib(10, F).
true :+ fib(100, F).
true :+ fib(1000, F).
true :+ fib(10000, F).
true :+ golden_ratio(1, Ratio).
true :+ golden_ratio(10, Ratio).
true :+ golden_ratio(100, Ratio).
true :+ golden_ratio(1000, Ratio).
