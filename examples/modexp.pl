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
?- mod_pow(7, 13, 97, Result).
?- mod_pow(7, 1000000000, 1000000007, Result).
?- mod_pow(3, 33554432, 1000000007, Result).
?- mod_pow(2, 1048576, 1000000000000, Result).
