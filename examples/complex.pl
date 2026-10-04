% Complex numbers as ordinary terms: complex(Real, Imaginary).
% eyeris has no complex primitives, so the whole domain is defined by clauses.
% Gaussian integer components stay exact, and the two places that leave the
% integers - an inexact quotient and a modulus - are visible in the output.
complex_add(complex(A, B), complex(C, D), complex(R, I)) :- R is A+C, I is B+D.
complex_sub(complex(A, B), complex(C, D), complex(R, I)) :- R is A-C, I is B-D.
complex_mul(complex(A, B), complex(C, D), complex(R, I)) :- R is A*C-B*D, I is A*D+B*C.
complex_conjugate(complex(A, B), complex(A, N)) :- N is -B.
% Dividing by a nonzero divisor scales by its norm, so an exactly divisible
% quotient stays a Gaussian integer and any other one becomes a float pair.
complex_div(complex(A, B), complex(C, D), complex(R, I)) :-
    Norm is C*C+D*D, Norm > 0, R is (A*C+B*D)/Norm, I is (B*C-A*D)/Norm.
% The norm of a Gaussian integer is an exact integer; the modulus is its root.
complex_norm(complex(A, B), Norm) :- Norm is A*A+B*B.
complex_modulus(Z, Modulus) :- complex_norm(Z, Norm), Modulus is sqrt(Norm).
% Integer powers by repeated squaring, with logarithmic depth as in modexp.pl.
complex_power(_, 0, complex(1, 0)).
complex_power(Base, Exponent, Result) :-
    Exponent > 0, Half is Exponent//2,
    complex_mul(Base, Base, Squared),
    complex_power(Squared, Half, Partial),
    finish_complex_power(Exponent, Base, Partial, Result).
finish_complex_power(Exponent, _, Partial, Partial) :- 0 =:= Exponent mod 2.
finish_complex_power(Exponent, Base, Partial, Result) :-
    1 =:= Exponent mod 2, complex_mul(Base, Partial, Result).

point(z, complex(3, 4)).
point(w, complex(1, 2)).
% Multiplying by 1+i rotates by an eighth turn and scales by the square root of 2.
turn(complex(1, 1)).
turns(8).

sum(Sum) :+ point(z, Z), point(w, W), complex_add(Z, W, Sum).
product(Product) :+ point(z, Z), point(w, W), complex_mul(Z, W, Product).
% Dividing the product by w recovers z exactly: the norm divides both parts.
quotient(Quotient) :+ product(Product), point(w, W), complex_div(Product, W, Quotient).
% The same division with an indivisible numerator leaves the integers.
ratio(Ratio) :+ point(z, Z), point(w, W), complex_div(Z, W, Ratio).
% i*i = -1 follows from the multiplication clause rather than being assumed.
unit_square(Square) :+ complex_mul(complex(0, 1), complex(0, 1), Square).
% Multiplying by the conjugate leaves the norm and no imaginary part.
conjugate_product(Name, Product) :+
    point(Name, Z), complex_conjugate(Z, Conjugate), complex_mul(Z, Conjugate, Product).
% The Gaussian norm is multiplicative: N(z) * N(w) = N(z*w).
norm_multiplicative(Nz, Nw, Nzw) :+
    point(z, Z), point(w, W), product(ZW),
    complex_norm(Z, Nz), complex_norm(W, Nw), complex_norm(ZW, Nzw).
% Eight eighth-turns return to the positive real axis, at 2^4.
integer_power(Exponent, Result) :+ turn(Base), turns(Exponent), complex_power(Base, Exponent, Result).
modulus(Name, Modulus) :+ point(Name, Z), complex_modulus(Z, Modulus).

% Leaving the Gaussian integers: polar form turns multiplication into addition
% of angles, which is what makes a complex power well defined.
% The quadrant is chosen explicitly, since acos alone only covers half a turn.
pi_value(3.141592653589793).
complex_polar(complex(X, Y), polar(R, Angle)) :-
    R is sqrt(X*X+Y*Y), R > 0, Reference is acos(abs(X)/R),
    quadrant_angle(X, Y, Reference, Angle).
quadrant_angle(X, Y, Reference, Reference) :- X >= 0, Y >= 0.
quadrant_angle(X, Y, Reference, Angle) :- X < 0, Y >= 0, pi_value(Pi), Angle is Pi-Reference.
quadrant_angle(X, Y, Reference, Angle) :- X < 0, Y < 0, pi_value(Pi), Angle is Pi+Reference.
quadrant_angle(X, Y, Reference, Angle) :- X >= 0, Y < 0, pi_value(Pi), Angle is 2*Pi-Reference.
% z^w = |z|^c * e^(-d*t) * (cos(d*ln|z| + c*t) + i*sin(d*ln|z| + c*t)).
complex_exponentiation(Z, complex(C, D), complex(E, F)) :-
    complex_polar(Z, polar(R, Angle)),
    Magnitude is R**C*exp(-D*Angle), Phase is D*log(R)+C*Angle,
    E is Magnitude*cos(Phase), F is Magnitude*sin(Phase).
% Inverse sine and cosine of a complex argument, through the same real parts.
complex_half_axes(complex(A, B), Minor, Major) :-
    Outer is sqrt((1+A)*(1+A)+B*B), Inner is sqrt((1-A)*(1-A)+B*B),
    Minor is (Outer-Inner)/2, Major is (Outer+Inner)/2.
complex_asin(Z, complex(C, D)) :-
    complex_half_axes(Z, Minor, Major), C is asin(Minor),
    D is log(Major+sqrt(Major*Major-1)).
complex_acos(Z, complex(C, D)) :-
    complex_half_axes(Z, Minor, Major), C is acos(Minor),
    D is -log(Major+sqrt(Major*Major-1)).

% The complex logarithm of Z in a complex base, through their polar forms.
complex_log(Base, Z, Result) :-
    complex_polar(Base, polar(BaseR, BaseAngle)), complex_polar(Z, polar(R, Angle)),
    LogBase is log(BaseR), LogR is log(R),
    complex_div(complex(LogR, Angle), complex(LogBase, BaseAngle), Result).
% Sine and cosine of a complex argument, through the real hyperbolic parts.
complex_sin(complex(A, B), complex(C, D)) :-
    C is sin(A)*(exp(B)+exp(-B))/2, D is cos(A)*(exp(B)-exp(-B))/2.
complex_cos(complex(A, B), complex(C, D)) :-
    C is cos(A)*(exp(B)+exp(-B))/2, D is -sin(A)*(exp(B)-exp(-B))/2.
complex_tan(Z, Result) :-
    complex_sin(Z, Sine), complex_cos(Z, Cosine), complex_div(Sine, Cosine, Result).
complex_atan(Z, Result) :-
    complex_sub(complex(0, 1), Z, Numerator), complex_add(complex(0, 1), Z, Denominator),
    complex_div(Numerator, Denominator, Ratio),
    complex_log(complex(2.718281828459045, 0), Ratio, Logarithm),
    complex_div(Logarithm, complex(0, 2), Result).

% The square root of -1, Euler's identity, i to the power i, and a real power
% of e, each as an ordinary complex exponentiation.
exponent_case(root, complex(-1, 0), complex(0.5, 0)).
exponent_case(euler, complex(2.718281828459045, 0), complex(0, 3.141592653589793)).
exponent_case(self_power, complex(0, 1), complex(0, 1)).
exponent_case(real_power, complex(2.718281828459045, 0), complex(-1.57079632679, 0)).
inverse_case(complex(2, 0)).

power(Name, Value) :+ exponent_case(Name, Z, W), complex_exponentiation(Z, W, Value).
arcsine(Z, Value) :+ inverse_case(Z), complex_asin(Z, Value).
arccosine(Z, Value) :+ inverse_case(Z), complex_acos(Z, Value).

% A logarithm in base e recovers Euler's identity; one in base i recovers 1.
logarithm(natural, Value) :+ complex_log(complex(2.718281828459045, 0), complex(-1, 0), Value).
logarithm(imaginary, Value) :+ complex_log(complex(0, 1), complex(0, 1), Value).
% Sine and cosine invert the arcsine and arccosine above, back to 2.
sine(Value) :+ arcsine(_, Angle), complex_sin(Angle, Value).
cosine(Value) :+ arccosine(_, Angle), complex_cos(Angle, Value).
% Tangent and arctangent likewise round-trip 1+2i.
arctangent(Value) :+ complex_atan(complex(1, 2), Value).
tangent(Value) :+ arctangent(Angle), complex_tan(Angle, Value).
