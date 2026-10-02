% Goldbach's conjecture: every even number greater than 2 is the sum of two
% primes. For each power of two from 4 to 2^25, find the split whose smaller
% prime is the least, testing primality by trial division.
% See https://en.wikipedia.org/wiki/Goldbach%27s_conjecture
split(4, [2, 2]).
split(N, Pair) :- 0 =:= N rem 2, N > 4, once(split_from(N, Pair, 3)).

split_from(N, [P, Q], P) :- Q is N-P, is_prime(Q).
split_from(N, Pair, P) :- P < N, once(next_prime(P, Next)), split_from(N, Pair, Next).

next_prime(P, Next) :- Next is P+2, is_prime(Next).
next_prime(P, Next) :- Q is P+2, next_prime(Q, Next).

is_prime(2).
is_prime(3).
is_prime(P) :- P > 3, 1 =:= P rem 2, \+ has_factor(P, 3).

has_factor(N, L) :- 0 =:= N rem L.
has_factor(N, L) :- L*L < N, M is L+2, has_factor(N, M).

in_range(Low, High, Low) :- Low =< High.
in_range(Low, High, N) :- Low < High, Next is Low+1, in_range(Next, High, N).

goldbach(N, Pair) :+ in_range(2, 25, I), N is 2^I, split(N, Pair).
