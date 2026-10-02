% The sieve of Eratosthenes: list the integers from 2, then repeatedly keep the
% first and strike out its multiples from the rest. The limit is 100 rather
% than 1000 because a certificate records every intermediate list: its size
% grows far faster than the answer, about 325 KB here and past 100 MB at 1000.
primes(Limit, Primes) :- range(2, Limit, Integers), sift(Integers, Primes).

range(Start, End, []) :- Start > End.
range(Start, End, [Start|Rest]) :- Start =< End, Next is Start+1, range(Next, End, Rest).

sift([], []).
sift([I|Is], [I|Ps]) :- remove(I, Is, New), sift(New, Ps).

remove(_, [], []).
remove(P, [I|Is], Rest) :- 0 =:= I mod P, remove(P, Is, Rest).
remove(P, [I|Is], [I|Rest]) :- 0 =\= I mod P, remove(P, Is, Rest).

true :+ primes(100, _).
