% Exact modular exponentiation by repeated squaring, with logarithmic depth.
mod_pow(Base, Exponent, Modulus, Result) :-
    integer(Base), integer(Exponent), integer(Modulus),
    Exponent >= 0, Modulus > 0,
    Reduced is Base mod Modulus, power_mod(Reduced, Exponent, Modulus, Result).
power_mod(_, 0, Modulus, Result) :- Result is 1 mod Modulus.
power_mod(Base, Exponent, Modulus, Result) :-
    Exponent > 0, Half is Exponent//2,
    Squared is (Base*Base) mod Modulus,
    power_mod(Squared, Half, Modulus, Partial),
    finish_power(Exponent, Base, Partial, Modulus, Result).
finish_power(Exponent, _, Partial, _, Partial) :- 0 =:= Exponent mod 2.
finish_power(Exponent, Base, Partial, Modulus, Result) :-
    1 =:= Exponent mod 2, Result is (Base*Partial) mod Modulus.
% A small case checked against the naive power-then-remainder computation.
?- Naive is 7^13 mod 97, mod_pow(7, 13, 97, Fast).
?- mod_pow(7, 1000000000, 1000000007, Result).
% The exponents themselves are computed: 2^25 and 2^20.
?- Exponent is 2^25, mod_pow(3, Exponent, 1000000007, Result).
?- Exponent is 2^20, mod_pow(2, Exponent, 1000000000000, Result).
