sum(complex(4, 6)).
product(complex(-5, 10)).
quotient(complex(3, 4)).
ratio(complex(2.2, -0.4)).
unit_square(complex(-1, 0)).
conjugate_product(z, complex(25, 0)).
conjugate_product(w, complex(5, 0)).
norm_multiplicative(25, 5, 125).
integer_power(8, complex(16, 0)).
modulus(z, 5.0).
modulus(w, 2.23606797749979).
power(root, complex(6.123233995736766e-17, 1.0)).
power(euler, complex(-1.0, 1.2246467991473532e-16)).
power(self_power, complex(0.20787957635076193, 0.0)).
power(real_power, complex(0.20787957635177984, 0.0)).
arcsine(complex(2, 0), complex(1.5707963267948966, 1.3169578969248166)).
arccosine(complex(2, 0), complex(0.0, -1.3169578969248166)).
logarithm(natural, complex(0.0, 3.141592653589793)).
logarithm(imaginary, complex(1.0, 0.0)).
sine(complex(1.9999999999999998, 1.0605752387249067e-16)).
cosine(complex(1.9999999999999998, 0.0)).
arctangent(complex(1.3389725222944935, 0.402359478108525)).
tangent(complex(1.0, 1.9999999999999996)).

clause(1, complex_add(complex(var('A'), var('B')), complex(var('C'), var('D')), complex(var('R'), var('I'))), ','(is(var('R'), +(var('A'), var('C'))), is(var('I'), +(var('B'), var('D'))))).
clause(2, complex_sub(complex(var('A'), var('B')), complex(var('C'), var('D')), complex(var('R'), var('I'))), ','(is(var('R'), -(var('A'), var('C'))), is(var('I'), -(var('B'), var('D'))))).
clause(3, complex_mul(complex(var('A'), var('B')), complex(var('C'), var('D')), complex(var('R'), var('I'))), ','(is(var('R'), -(*(var('A'), var('C')), *(var('B'), var('D')))), is(var('I'), +(*(var('A'), var('D')), *(var('B'), var('C')))))).
clause(4, complex_conjugate(complex(var('A'), var('B')), complex(var('A'), var('N'))), is(var('N'), -(var('B')))).
clause(5, complex_div(complex(var('A'), var('B')), complex(var('C'), var('D')), complex(var('R'), var('I'))), ','(is(var('Norm'), +(*(var('C'), var('C')), *(var('D'), var('D')))), ','(>(var('Norm'), 0), ','(is(var('R'), /(+(*(var('A'), var('C')), *(var('B'), var('D'))), var('Norm'))), is(var('I'), /(-(*(var('B'), var('C')), *(var('A'), var('D'))), var('Norm'))))))).
clause(6, complex_norm(complex(var('A'), var('B')), var('Norm')), is(var('Norm'), +(*(var('A'), var('A')), *(var('B'), var('B'))))).
clause(7, complex_modulus(var('Z'), var('Modulus')), ','(complex_norm(var('Z'), var('Norm')), is(var('Modulus'), sqrt(var('Norm'))))).
clause(8, complex_power(var('__anon0'), 0, complex(1, 0)), true).
clause(9, complex_power(var('Base'), var('Exponent'), var('Result')), ','(>(var('Exponent'), 0), ','(is(var('Half'), //(var('Exponent'), 2)), ','(complex_mul(var('Base'), var('Base'), var('Squared')), ','(complex_power(var('Squared'), var('Half'), var('Partial')), finish_complex_power(var('Exponent'), var('Base'), var('Partial'), var('Result'))))))).
clause(10, finish_complex_power(var('Exponent'), var('__anon1'), var('Partial'), var('Partial')), '=:='(0, mod(var('Exponent'), 2))).
clause(11, finish_complex_power(var('Exponent'), var('Base'), var('Partial'), var('Result')), ','('=:='(1, mod(var('Exponent'), 2)), complex_mul(var('Base'), var('Partial'), var('Result')))).
clause(12, point(z, complex(3, 4)), true).
clause(13, point(w, complex(1, 2)), true).
clause(14, turn(complex(1, 1)), true).
clause(15, turns(8), true).
clause(16, sum(var('Sum')), ','(point(z, var('Z')), ','(point(w, var('W')), complex_add(var('Z'), var('W'), var('Sum'))))).
clause(17, product(var('Product')), ','(point(z, var('Z')), ','(point(w, var('W')), complex_mul(var('Z'), var('W'), var('Product'))))).
clause(18, quotient(var('Quotient')), ','(product(var('Product')), ','(point(w, var('W')), complex_div(var('Product'), var('W'), var('Quotient'))))).
clause(19, ratio(var('Ratio')), ','(point(z, var('Z')), ','(point(w, var('W')), complex_div(var('Z'), var('W'), var('Ratio'))))).
clause(20, unit_square(var('Square')), complex_mul(complex(0, 1), complex(0, 1), var('Square'))).
clause(21, conjugate_product(var('Name'), var('Product')), ','(point(var('Name'), var('Z')), ','(complex_conjugate(var('Z'), var('Conjugate')), complex_mul(var('Z'), var('Conjugate'), var('Product'))))).
clause(22, norm_multiplicative(var('Nz'), var('Nw'), var('Nzw')), ','(point(z, var('Z')), ','(point(w, var('W')), ','(product(var('ZW')), ','(complex_norm(var('Z'), var('Nz')), ','(complex_norm(var('W'), var('Nw')), complex_norm(var('ZW'), var('Nzw')))))))).
clause(23, integer_power(var('Exponent'), var('Result')), ','(turn(var('Base')), ','(turns(var('Exponent')), complex_power(var('Base'), var('Exponent'), var('Result'))))).
clause(24, modulus(var('Name'), var('Modulus')), ','(point(var('Name'), var('Z')), complex_modulus(var('Z'), var('Modulus')))).
clause(25, pi_value(3.141592653589793), true).
clause(26, complex_polar(complex(var('X'), var('Y')), polar(var('R'), var('Angle'))), ','(is(var('R'), sqrt(+(*(var('X'), var('X')), *(var('Y'), var('Y'))))), ','(>(var('R'), 0), ','(is(var('Reference'), acos(/(abs(var('X')), var('R')))), quadrant_angle(var('X'), var('Y'), var('Reference'), var('Angle')))))).
clause(27, quadrant_angle(var('X'), var('Y'), var('Reference'), var('Reference')), ','(>=(var('X'), 0), >=(var('Y'), 0))).
clause(28, quadrant_angle(var('X'), var('Y'), var('Reference'), var('Angle')), ','(<(var('X'), 0), ','(>=(var('Y'), 0), ','(pi_value(var('Pi')), is(var('Angle'), -(var('Pi'), var('Reference'))))))).
clause(31, complex_exponentiation(var('Z'), complex(var('C'), var('D')), complex(var('E'), var('F'))), ','(complex_polar(var('Z'), polar(var('R'), var('Angle'))), ','(is(var('Magnitude'), *(**(var('R'), var('C')), exp(*(-(var('D')), var('Angle'))))), ','(is(var('Phase'), +(*(var('D'), log(var('R'))), *(var('C'), var('Angle')))), ','(is(var('E'), *(var('Magnitude'), cos(var('Phase')))), is(var('F'), *(var('Magnitude'), sin(var('Phase'))))))))).
clause(32, complex_half_axes(complex(var('A'), var('B')), var('Minor'), var('Major')), ','(is(var('Outer'), sqrt(+(*(+(1, var('A')), +(1, var('A'))), *(var('B'), var('B'))))), ','(is(var('Inner'), sqrt(+(*(-(1, var('A')), -(1, var('A'))), *(var('B'), var('B'))))), ','(is(var('Minor'), /(-(var('Outer'), var('Inner')), 2)), is(var('Major'), /(+(var('Outer'), var('Inner')), 2)))))).
clause(33, complex_asin(var('Z'), complex(var('C'), var('D'))), ','(complex_half_axes(var('Z'), var('Minor'), var('Major')), ','(is(var('C'), asin(var('Minor'))), is(var('D'), log(+(var('Major'), sqrt(-(*(var('Major'), var('Major')), 1)))))))).
clause(34, complex_acos(var('Z'), complex(var('C'), var('D'))), ','(complex_half_axes(var('Z'), var('Minor'), var('Major')), ','(is(var('C'), acos(var('Minor'))), is(var('D'), -(log(+(var('Major'), sqrt(-(*(var('Major'), var('Major')), 1))))))))).
clause(35, complex_log(var('Base'), var('Z'), var('Result')), ','(complex_polar(var('Base'), polar(var('BaseR'), var('BaseAngle'))), ','(complex_polar(var('Z'), polar(var('R'), var('Angle'))), ','(is(var('LogBase'), log(var('BaseR'))), ','(is(var('LogR'), log(var('R'))), complex_div(complex(var('LogR'), var('Angle')), complex(var('LogBase'), var('BaseAngle')), var('Result'))))))).
clause(36, complex_sin(complex(var('A'), var('B')), complex(var('C'), var('D'))), ','(is(var('C'), /(*(sin(var('A')), +(exp(var('B')), exp(-(var('B'))))), 2)), is(var('D'), /(*(cos(var('A')), -(exp(var('B')), exp(-(var('B'))))), 2)))).
clause(37, complex_cos(complex(var('A'), var('B')), complex(var('C'), var('D'))), ','(is(var('C'), /(*(cos(var('A')), +(exp(var('B')), exp(-(var('B'))))), 2)), is(var('D'), /(*(-(sin(var('A'))), -(exp(var('B')), exp(-(var('B'))))), 2)))).
clause(38, complex_tan(var('Z'), var('Result')), ','(complex_sin(var('Z'), var('Sine')), ','(complex_cos(var('Z'), var('Cosine')), complex_div(var('Sine'), var('Cosine'), var('Result'))))).
clause(39, complex_atan(var('Z'), var('Result')), ','(complex_sub(complex(0, 1), var('Z'), var('Numerator')), ','(complex_add(complex(0, 1), var('Z'), var('Denominator')), ','(complex_div(var('Numerator'), var('Denominator'), var('Ratio')), ','(complex_log(complex(2.718281828459045, 0), var('Ratio'), var('Logarithm')), complex_div(var('Logarithm'), complex(0, 2), var('Result'))))))).
clause(40, exponent_case(root, complex(-1, 0), complex(0.5, 0)), true).
clause(41, exponent_case(euler, complex(2.718281828459045, 0), complex(0, 3.141592653589793)), true).
clause(42, exponent_case(self_power, complex(0, 1), complex(0, 1)), true).
clause(43, exponent_case(real_power, complex(2.718281828459045, 0), complex(-1.57079632679, 0)), true).
clause(44, inverse_case(complex(2, 0)), true).
clause(45, power(var('Name'), var('Value')), ','(exponent_case(var('Name'), var('Z'), var('W')), complex_exponentiation(var('Z'), var('W'), var('Value')))).
clause(46, arcsine(var('Z'), var('Value')), ','(inverse_case(var('Z')), complex_asin(var('Z'), var('Value')))).
clause(47, arccosine(var('Z'), var('Value')), ','(inverse_case(var('Z')), complex_acos(var('Z'), var('Value')))).
clause(48, logarithm(natural, var('Value')), complex_log(complex(2.718281828459045, 0), complex(-1, 0), var('Value'))).
clause(49, logarithm(imaginary, var('Value')), complex_log(complex(0, 1), complex(0, 1), var('Value'))).
clause(50, sine(var('Value')), ','(arcsine(var('__anon2'), var('Angle')), complex_sin(var('Angle'), var('Value')))).
clause(51, cosine(var('Value')), ','(arccosine(var('__anon3'), var('Angle')), complex_cos(var('Angle'), var('Value')))).
clause(52, arctangent(var('Value')), complex_atan(complex(1, 2), var('Value'))).
clause(53, tangent(var('Value')), ','(arctangent(var('Angle')), complex_tan(var('Angle'), var('Value')))).

step(sum(complex(4, 6)), rule(16), [=('Sum', complex(4, 6)), =('Z', complex(3, 4)), =('W', complex(1, 2))], [point(z, complex(3, 4)), point(w, complex(1, 2)), complex_add(complex(3, 4), complex(1, 2), complex(4, 6))]).
step(point(z, complex(3, 4)), fact(12), [], []).
step(point(w, complex(1, 2)), fact(13), [], []).
step(complex_add(complex(3, 4), complex(1, 2), complex(4, 6)), rule(1), [=('A', 3), =('B', 4), =('C', 1), =('D', 2), =('R', 4), =('I', 6)], [is(4, +(3, 1)), is(6, +(4, 2))]).
step(is(4, +(3, 1)), builtin, [], []).
step(is(6, +(4, 2)), builtin, [], []).
step(product(complex(-5, 10)), rule(17), [=('Product', complex(-5, 10)), =('Z', complex(3, 4)), =('W', complex(1, 2))], [point(z, complex(3, 4)), point(w, complex(1, 2)), complex_mul(complex(3, 4), complex(1, 2), complex(-5, 10))]).
step(complex_mul(complex(3, 4), complex(1, 2), complex(-5, 10)), rule(3), [=('A', 3), =('B', 4), =('C', 1), =('D', 2), =('R', -5), =('I', 10)], [is(-5, -(*(3, 1), *(4, 2))), is(10, +(*(3, 2), *(4, 1)))]).
step(is(-5, -(*(3, 1), *(4, 2))), builtin, [], []).
step(is(10, +(*(3, 2), *(4, 1))), builtin, [], []).
step(quotient(complex(3, 4)), rule(18), [=('Quotient', complex(3, 4)), =('Product', complex(-5, 10)), =('W', complex(1, 2))], [product(complex(-5, 10)), point(w, complex(1, 2)), complex_div(complex(-5, 10), complex(1, 2), complex(3, 4))]).
step(complex_div(complex(-5, 10), complex(1, 2), complex(3, 4)), rule(5), [=('A', -5), =('B', 10), =('C', 1), =('D', 2), =('R', 3), =('I', 4), =('Norm', 5)], [is(5, +(*(1, 1), *(2, 2))), >(5, 0), is(3, /(+(*(-5, 1), *(10, 2)), 5)), is(4, /(-(*(10, 1), *(-5, 2)), 5))]).
step(is(5, +(*(1, 1), *(2, 2))), builtin, [], []).
step(>(5, 0), builtin, [], []).
step(is(3, /(+(*(-5, 1), *(10, 2)), 5)), builtin, [], []).
step(is(4, /(-(*(10, 1), *(-5, 2)), 5)), builtin, [], []).
step(ratio(complex(2.2, -0.4)), rule(19), [=('Ratio', complex(2.2, -0.4)), =('Z', complex(3, 4)), =('W', complex(1, 2))], [point(z, complex(3, 4)), point(w, complex(1, 2)), complex_div(complex(3, 4), complex(1, 2), complex(2.2, -0.4))]).
step(complex_div(complex(3, 4), complex(1, 2), complex(2.2, -0.4)), rule(5), [=('A', 3), =('B', 4), =('C', 1), =('D', 2), =('R', 2.2), =('I', -0.4), =('Norm', 5)], [is(5, +(*(1, 1), *(2, 2))), >(5, 0), is(2.2, /(+(*(3, 1), *(4, 2)), 5)), is(-0.4, /(-(*(4, 1), *(3, 2)), 5))]).
step(is(2.2, /(+(*(3, 1), *(4, 2)), 5)), builtin, [], []).
step(is(-0.4, /(-(*(4, 1), *(3, 2)), 5)), builtin, [], []).
step(unit_square(complex(-1, 0)), rule(20), [=('Square', complex(-1, 0))], [complex_mul(complex(0, 1), complex(0, 1), complex(-1, 0))]).
step(complex_mul(complex(0, 1), complex(0, 1), complex(-1, 0)), rule(3), [=('A', 0), =('B', 1), =('C', 0), =('D', 1), =('R', -1), =('I', 0)], [is(-1, -(*(0, 0), *(1, 1))), is(0, +(*(0, 1), *(1, 0)))]).
step(is(-1, -(*(0, 0), *(1, 1))), builtin, [], []).
step(is(0, +(*(0, 1), *(1, 0))), builtin, [], []).
step(conjugate_product(z, complex(25, 0)), rule(21), [=('Name', z), =('Product', complex(25, 0)), =('Z', complex(3, 4)), =('Conjugate', complex(3, -4))], [point(z, complex(3, 4)), complex_conjugate(complex(3, 4), complex(3, -4)), complex_mul(complex(3, 4), complex(3, -4), complex(25, 0))]).
step(complex_conjugate(complex(3, 4), complex(3, -4)), rule(4), [=('A', 3), =('B', 4), =('N', -4)], [is(-4, -(4))]).
step(is(-4, -(4)), builtin, [], []).
step(complex_mul(complex(3, 4), complex(3, -4), complex(25, 0)), rule(3), [=('A', 3), =('B', 4), =('C', 3), =('D', -4), =('R', 25), =('I', 0)], [is(25, -(*(3, 3), *(4, -4))), is(0, +(*(3, -4), *(4, 3)))]).
step(is(25, -(*(3, 3), *(4, -4))), builtin, [], []).
step(is(0, +(*(3, -4), *(4, 3))), builtin, [], []).
step(conjugate_product(w, complex(5, 0)), rule(21), [=('Name', w), =('Product', complex(5, 0)), =('Z', complex(1, 2)), =('Conjugate', complex(1, -2))], [point(w, complex(1, 2)), complex_conjugate(complex(1, 2), complex(1, -2)), complex_mul(complex(1, 2), complex(1, -2), complex(5, 0))]).
step(complex_conjugate(complex(1, 2), complex(1, -2)), rule(4), [=('A', 1), =('B', 2), =('N', -2)], [is(-2, -(2))]).
step(is(-2, -(2)), builtin, [], []).
step(complex_mul(complex(1, 2), complex(1, -2), complex(5, 0)), rule(3), [=('A', 1), =('B', 2), =('C', 1), =('D', -2), =('R', 5), =('I', 0)], [is(5, -(*(1, 1), *(2, -2))), is(0, +(*(1, -2), *(2, 1)))]).
step(is(5, -(*(1, 1), *(2, -2))), builtin, [], []).
step(is(0, +(*(1, -2), *(2, 1))), builtin, [], []).
step(norm_multiplicative(25, 5, 125), rule(22), [=('Nz', 25), =('Nw', 5), =('Nzw', 125), =('Z', complex(3, 4)), =('W', complex(1, 2)), =('ZW', complex(-5, 10))], [point(z, complex(3, 4)), point(w, complex(1, 2)), product(complex(-5, 10)), complex_norm(complex(3, 4), 25), complex_norm(complex(1, 2), 5), complex_norm(complex(-5, 10), 125)]).
step(complex_norm(complex(3, 4), 25), rule(6), [=('A', 3), =('B', 4), =('Norm', 25)], [is(25, +(*(3, 3), *(4, 4)))]).
step(is(25, +(*(3, 3), *(4, 4))), builtin, [], []).
step(complex_norm(complex(1, 2), 5), rule(6), [=('A', 1), =('B', 2), =('Norm', 5)], [is(5, +(*(1, 1), *(2, 2)))]).
step(complex_norm(complex(-5, 10), 125), rule(6), [=('A', -5), =('B', 10), =('Norm', 125)], [is(125, +(*(-5, -5), *(10, 10)))]).
step(is(125, +(*(-5, -5), *(10, 10))), builtin, [], []).
step(integer_power(8, complex(16, 0)), rule(23), [=('Exponent', 8), =('Result', complex(16, 0)), =('Base', complex(1, 1))], [turn(complex(1, 1)), turns(8), complex_power(complex(1, 1), 8, complex(16, 0))]).
step(turn(complex(1, 1)), fact(14), [], []).
step(turns(8), fact(15), [], []).
step(complex_power(complex(1, 1), 8, complex(16, 0)), rule(9), [=('Base', complex(1, 1)), =('Exponent', 8), =('Result', complex(16, 0)), =('Half', 4), =('Squared', complex(0, 2)), =('Partial', complex(16, 0))], [>(8, 0), is(4, //(8, 2)), complex_mul(complex(1, 1), complex(1, 1), complex(0, 2)), complex_power(complex(0, 2), 4, complex(16, 0)), finish_complex_power(8, complex(1, 1), complex(16, 0), complex(16, 0))]).
step(>(8, 0), builtin, [], []).
step(is(4, //(8, 2)), builtin, [], []).
step(complex_mul(complex(1, 1), complex(1, 1), complex(0, 2)), rule(3), [=('A', 1), =('B', 1), =('C', 1), =('D', 1), =('R', 0), =('I', 2)], [is(0, -(*(1, 1), *(1, 1))), is(2, +(*(1, 1), *(1, 1)))]).
step(is(0, -(*(1, 1), *(1, 1))), builtin, [], []).
step(is(2, +(*(1, 1), *(1, 1))), builtin, [], []).
step(complex_power(complex(0, 2), 4, complex(16, 0)), rule(9), [=('Base', complex(0, 2)), =('Exponent', 4), =('Result', complex(16, 0)), =('Half', 2), =('Squared', complex(-4, 0)), =('Partial', complex(16, 0))], [>(4, 0), is(2, //(4, 2)), complex_mul(complex(0, 2), complex(0, 2), complex(-4, 0)), complex_power(complex(-4, 0), 2, complex(16, 0)), finish_complex_power(4, complex(0, 2), complex(16, 0), complex(16, 0))]).
step(>(4, 0), builtin, [], []).
step(is(2, //(4, 2)), builtin, [], []).
step(complex_mul(complex(0, 2), complex(0, 2), complex(-4, 0)), rule(3), [=('A', 0), =('B', 2), =('C', 0), =('D', 2), =('R', -4), =('I', 0)], [is(-4, -(*(0, 0), *(2, 2))), is(0, +(*(0, 2), *(2, 0)))]).
step(is(-4, -(*(0, 0), *(2, 2))), builtin, [], []).
step(is(0, +(*(0, 2), *(2, 0))), builtin, [], []).
step(complex_power(complex(-4, 0), 2, complex(16, 0)), rule(9), [=('Base', complex(-4, 0)), =('Exponent', 2), =('Result', complex(16, 0)), =('Half', 1), =('Squared', complex(16, 0)), =('Partial', complex(16, 0))], [>(2, 0), is(1, //(2, 2)), complex_mul(complex(-4, 0), complex(-4, 0), complex(16, 0)), complex_power(complex(16, 0), 1, complex(16, 0)), finish_complex_power(2, complex(-4, 0), complex(16, 0), complex(16, 0))]).
step(>(2, 0), builtin, [], []).
step(is(1, //(2, 2)), builtin, [], []).
step(complex_mul(complex(-4, 0), complex(-4, 0), complex(16, 0)), rule(3), [=('A', -4), =('B', 0), =('C', -4), =('D', 0), =('R', 16), =('I', 0)], [is(16, -(*(-4, -4), *(0, 0))), is(0, +(*(-4, 0), *(0, -4)))]).
step(is(16, -(*(-4, -4), *(0, 0))), builtin, [], []).
step(is(0, +(*(-4, 0), *(0, -4))), builtin, [], []).
step(complex_power(complex(16, 0), 1, complex(16, 0)), rule(9), [=('Base', complex(16, 0)), =('Exponent', 1), =('Result', complex(16, 0)), =('Half', 0), =('Squared', complex(256, 0)), =('Partial', complex(1, 0))], [>(1, 0), is(0, //(1, 2)), complex_mul(complex(16, 0), complex(16, 0), complex(256, 0)), complex_power(complex(256, 0), 0, complex(1, 0)), finish_complex_power(1, complex(16, 0), complex(1, 0), complex(16, 0))]).
step(>(1, 0), builtin, [], []).
step(is(0, //(1, 2)), builtin, [], []).
step(complex_mul(complex(16, 0), complex(16, 0), complex(256, 0)), rule(3), [=('A', 16), =('B', 0), =('C', 16), =('D', 0), =('R', 256), =('I', 0)], [is(256, -(*(16, 16), *(0, 0))), is(0, +(*(16, 0), *(0, 16)))]).
step(is(256, -(*(16, 16), *(0, 0))), builtin, [], []).
step(is(0, +(*(16, 0), *(0, 16))), builtin, [], []).
step(complex_power(complex(256, 0), 0, complex(1, 0)), fact(8), [=('__anon0', complex(256, 0))], []).
step(finish_complex_power(1, complex(16, 0), complex(1, 0), complex(16, 0)), rule(11), [=('Exponent', 1), =('Base', complex(16, 0)), =('Partial', complex(1, 0)), =('Result', complex(16, 0))], ['=:='(1, mod(1, 2)), complex_mul(complex(16, 0), complex(1, 0), complex(16, 0))]).
step('=:='(1, mod(1, 2)), builtin, [], []).
step(complex_mul(complex(16, 0), complex(1, 0), complex(16, 0)), rule(3), [=('A', 16), =('B', 0), =('C', 1), =('D', 0), =('R', 16), =('I', 0)], [is(16, -(*(16, 1), *(0, 0))), is(0, +(*(16, 0), *(0, 1)))]).
step(is(16, -(*(16, 1), *(0, 0))), builtin, [], []).
step(is(0, +(*(16, 0), *(0, 1))), builtin, [], []).
step(finish_complex_power(2, complex(-4, 0), complex(16, 0), complex(16, 0)), rule(10), [=('Exponent', 2), =('__anon1', complex(-4, 0)), =('Partial', complex(16, 0))], ['=:='(0, mod(2, 2))]).
step('=:='(0, mod(2, 2)), builtin, [], []).
step(finish_complex_power(4, complex(0, 2), complex(16, 0), complex(16, 0)), rule(10), [=('Exponent', 4), =('__anon1', complex(0, 2)), =('Partial', complex(16, 0))], ['=:='(0, mod(4, 2))]).
step('=:='(0, mod(4, 2)), builtin, [], []).
step(finish_complex_power(8, complex(1, 1), complex(16, 0), complex(16, 0)), rule(10), [=('Exponent', 8), =('__anon1', complex(1, 1)), =('Partial', complex(16, 0))], ['=:='(0, mod(8, 2))]).
step('=:='(0, mod(8, 2)), builtin, [], []).
step(modulus(z, 5.0), rule(24), [=('Name', z), =('Modulus', 5.0), =('Z', complex(3, 4))], [point(z, complex(3, 4)), complex_modulus(complex(3, 4), 5.0)]).
step(complex_modulus(complex(3, 4), 5.0), rule(7), [=('Z', complex(3, 4)), =('Modulus', 5.0), =('Norm', 25)], [complex_norm(complex(3, 4), 25), is(5.0, sqrt(25))]).
step(is(5.0, sqrt(25)), builtin, [], []).
step(modulus(w, 2.23606797749979), rule(24), [=('Name', w), =('Modulus', 2.23606797749979), =('Z', complex(1, 2))], [point(w, complex(1, 2)), complex_modulus(complex(1, 2), 2.23606797749979)]).
step(complex_modulus(complex(1, 2), 2.23606797749979), rule(7), [=('Z', complex(1, 2)), =('Modulus', 2.23606797749979), =('Norm', 5)], [complex_norm(complex(1, 2), 5), is(2.23606797749979, sqrt(5))]).
step(is(2.23606797749979, sqrt(5)), builtin, [], []).
step(power(root, complex(6.123233995736766e-17, 1.0)), rule(45), [=('Name', root), =('Value', complex(6.123233995736766e-17, 1.0)), =('Z', complex(-1, 0)), =('W', complex(0.5, 0))], [exponent_case(root, complex(-1, 0), complex(0.5, 0)), complex_exponentiation(complex(-1, 0), complex(0.5, 0), complex(6.123233995736766e-17, 1.0))]).
step(exponent_case(root, complex(-1, 0), complex(0.5, 0)), fact(40), [], []).
step(complex_exponentiation(complex(-1, 0), complex(0.5, 0), complex(6.123233995736766e-17, 1.0)), rule(31), [=('Z', complex(-1, 0)), =('C', 0.5), =('D', 0), =('E', 6.123233995736766e-17), =('F', 1.0), =('R', 1.0), =('Angle', 3.141592653589793), =('Magnitude', 1.0), =('Phase', 1.5707963267948966)], [complex_polar(complex(-1, 0), polar(1.0, 3.141592653589793)), is(1.0, *(**(1.0, 0.5), exp(*(-(0), 3.141592653589793)))), is(1.5707963267948966, +(*(0, log(1.0)), *(0.5, 3.141592653589793))), is(6.123233995736766e-17, *(1.0, cos(1.5707963267948966))), is(1.0, *(1.0, sin(1.5707963267948966)))]).
step(complex_polar(complex(-1, 0), polar(1.0, 3.141592653589793)), rule(26), [=('X', -1), =('Y', 0), =('R', 1.0), =('Angle', 3.141592653589793), =('Reference', 0.0)], [is(1.0, sqrt(+(*(-1, -1), *(0, 0)))), >(1.0, 0), is(0.0, acos(/(abs(-1), 1.0))), quadrant_angle(-1, 0, 0.0, 3.141592653589793)]).
step(is(1.0, sqrt(+(*(-1, -1), *(0, 0)))), builtin, [], []).
step(>(1.0, 0), builtin, [], []).
step(is(0.0, acos(/(abs(-1), 1.0))), builtin, [], []).
step(quadrant_angle(-1, 0, 0.0, 3.141592653589793), rule(28), [=('X', -1), =('Y', 0), =('Reference', 0.0), =('Angle', 3.141592653589793), =('Pi', 3.141592653589793)], [<(-1, 0), >=(0, 0), pi_value(3.141592653589793), is(3.141592653589793, -(3.141592653589793, 0.0))]).
step(<(-1, 0), builtin, [], []).
step(>=(0, 0), builtin, [], []).
step(pi_value(3.141592653589793), fact(25), [], []).
step(is(3.141592653589793, -(3.141592653589793, 0.0)), builtin, [], []).
step(is(1.0, *(**(1.0, 0.5), exp(*(-(0), 3.141592653589793)))), builtin, [], []).
step(is(1.5707963267948966, +(*(0, log(1.0)), *(0.5, 3.141592653589793))), builtin, [], []).
step(is(6.123233995736766e-17, *(1.0, cos(1.5707963267948966))), builtin, [], []).
step(is(1.0, *(1.0, sin(1.5707963267948966))), builtin, [], []).
step(power(euler, complex(-1.0, 1.2246467991473532e-16)), rule(45), [=('Name', euler), =('Value', complex(-1.0, 1.2246467991473532e-16)), =('Z', complex(2.718281828459045, 0)), =('W', complex(0, 3.141592653589793))], [exponent_case(euler, complex(2.718281828459045, 0), complex(0, 3.141592653589793)), complex_exponentiation(complex(2.718281828459045, 0), complex(0, 3.141592653589793), complex(-1.0, 1.2246467991473532e-16))]).
step(exponent_case(euler, complex(2.718281828459045, 0), complex(0, 3.141592653589793)), fact(41), [], []).
step(complex_exponentiation(complex(2.718281828459045, 0), complex(0, 3.141592653589793), complex(-1.0, 1.2246467991473532e-16)), rule(31), [=('Z', complex(2.718281828459045, 0)), =('C', 0), =('D', 3.141592653589793), =('E', -1.0), =('F', 1.2246467991473532e-16), =('R', 2.718281828459045), =('Angle', 0.0), =('Magnitude', 1.0), =('Phase', 3.141592653589793)], [complex_polar(complex(2.718281828459045, 0), polar(2.718281828459045, 0.0)), is(1.0, *(**(2.718281828459045, 0), exp(*(-(3.141592653589793), 0.0)))), is(3.141592653589793, +(*(3.141592653589793, log(2.718281828459045)), *(0, 0.0))), is(-1.0, *(1.0, cos(3.141592653589793))), is(1.2246467991473532e-16, *(1.0, sin(3.141592653589793)))]).
step(complex_polar(complex(2.718281828459045, 0), polar(2.718281828459045, 0.0)), rule(26), [=('X', 2.718281828459045), =('Y', 0), =('R', 2.718281828459045), =('Angle', 0.0), =('Reference', 0.0)], [is(2.718281828459045, sqrt(+(*(2.718281828459045, 2.718281828459045), *(0, 0)))), >(2.718281828459045, 0), is(0.0, acos(/(abs(2.718281828459045), 2.718281828459045))), quadrant_angle(2.718281828459045, 0, 0.0, 0.0)]).
step(is(2.718281828459045, sqrt(+(*(2.718281828459045, 2.718281828459045), *(0, 0)))), builtin, [], []).
step(>(2.718281828459045, 0), builtin, [], []).
step(is(0.0, acos(/(abs(2.718281828459045), 2.718281828459045))), builtin, [], []).
step(quadrant_angle(2.718281828459045, 0, 0.0, 0.0), rule(27), [=('X', 2.718281828459045), =('Y', 0), =('Reference', 0.0)], [>=(2.718281828459045, 0), >=(0, 0)]).
step(>=(2.718281828459045, 0), builtin, [], []).
step(is(1.0, *(**(2.718281828459045, 0), exp(*(-(3.141592653589793), 0.0)))), builtin, [], []).
step(is(3.141592653589793, +(*(3.141592653589793, log(2.718281828459045)), *(0, 0.0))), builtin, [], []).
step(is(-1.0, *(1.0, cos(3.141592653589793))), builtin, [], []).
step(is(1.2246467991473532e-16, *(1.0, sin(3.141592653589793))), builtin, [], []).
step(power(self_power, complex(0.20787957635076193, 0.0)), rule(45), [=('Name', self_power), =('Value', complex(0.20787957635076193, 0.0)), =('Z', complex(0, 1)), =('W', complex(0, 1))], [exponent_case(self_power, complex(0, 1), complex(0, 1)), complex_exponentiation(complex(0, 1), complex(0, 1), complex(0.20787957635076193, 0.0))]).
step(exponent_case(self_power, complex(0, 1), complex(0, 1)), fact(42), [], []).
step(complex_exponentiation(complex(0, 1), complex(0, 1), complex(0.20787957635076193, 0.0)), rule(31), [=('Z', complex(0, 1)), =('C', 0), =('D', 1), =('E', 0.20787957635076193), =('F', 0.0), =('R', 1.0), =('Angle', 1.5707963267948966), =('Magnitude', 0.20787957635076193), =('Phase', 0.0)], [complex_polar(complex(0, 1), polar(1.0, 1.5707963267948966)), is(0.20787957635076193, *(**(1.0, 0), exp(*(-(1), 1.5707963267948966)))), is(0.0, +(*(1, log(1.0)), *(0, 1.5707963267948966))), is(0.20787957635076193, *(0.20787957635076193, cos(0.0))), is(0.0, *(0.20787957635076193, sin(0.0)))]).
step(complex_polar(complex(0, 1), polar(1.0, 1.5707963267948966)), rule(26), [=('X', 0), =('Y', 1), =('R', 1.0), =('Angle', 1.5707963267948966), =('Reference', 1.5707963267948966)], [is(1.0, sqrt(+(*(0, 0), *(1, 1)))), >(1.0, 0), is(1.5707963267948966, acos(/(abs(0), 1.0))), quadrant_angle(0, 1, 1.5707963267948966, 1.5707963267948966)]).
step(is(1.0, sqrt(+(*(0, 0), *(1, 1)))), builtin, [], []).
step(is(1.5707963267948966, acos(/(abs(0), 1.0))), builtin, [], []).
step(quadrant_angle(0, 1, 1.5707963267948966, 1.5707963267948966), rule(27), [=('X', 0), =('Y', 1), =('Reference', 1.5707963267948966)], [>=(0, 0), >=(1, 0)]).
step(>=(1, 0), builtin, [], []).
step(is(0.20787957635076193, *(**(1.0, 0), exp(*(-(1), 1.5707963267948966)))), builtin, [], []).
step(is(0.0, +(*(1, log(1.0)), *(0, 1.5707963267948966))), builtin, [], []).
step(is(0.20787957635076193, *(0.20787957635076193, cos(0.0))), builtin, [], []).
step(is(0.0, *(0.20787957635076193, sin(0.0))), builtin, [], []).
step(power(real_power, complex(0.20787957635177984, 0.0)), rule(45), [=('Name', real_power), =('Value', complex(0.20787957635177984, 0.0)), =('Z', complex(2.718281828459045, 0)), =('W', complex(-1.57079632679, 0))], [exponent_case(real_power, complex(2.718281828459045, 0), complex(-1.57079632679, 0)), complex_exponentiation(complex(2.718281828459045, 0), complex(-1.57079632679, 0), complex(0.20787957635177984, 0.0))]).
step(exponent_case(real_power, complex(2.718281828459045, 0), complex(-1.57079632679, 0)), fact(43), [], []).
step(complex_exponentiation(complex(2.718281828459045, 0), complex(-1.57079632679, 0), complex(0.20787957635177984, 0.0)), rule(31), [=('Z', complex(2.718281828459045, 0)), =('C', -1.57079632679), =('D', 0), =('E', 0.20787957635177984), =('F', 0.0), =('R', 2.718281828459045), =('Angle', 0.0), =('Magnitude', 0.20787957635177984), =('Phase', 0.0)], [complex_polar(complex(2.718281828459045, 0), polar(2.718281828459045, 0.0)), is(0.20787957635177984, *(**(2.718281828459045, -1.57079632679), exp(*(-(0), 0.0)))), is(0.0, +(*(0, log(2.718281828459045)), *(-1.57079632679, 0.0))), is(0.20787957635177984, *(0.20787957635177984, cos(0.0))), is(0.0, *(0.20787957635177984, sin(0.0)))]).
step(is(0.20787957635177984, *(**(2.718281828459045, -1.57079632679), exp(*(-(0), 0.0)))), builtin, [], []).
step(is(0.0, +(*(0, log(2.718281828459045)), *(-1.57079632679, 0.0))), builtin, [], []).
step(is(0.20787957635177984, *(0.20787957635177984, cos(0.0))), builtin, [], []).
step(is(0.0, *(0.20787957635177984, sin(0.0))), builtin, [], []).
step(arcsine(complex(2, 0), complex(1.5707963267948966, 1.3169578969248166)), rule(46), [=('Z', complex(2, 0)), =('Value', complex(1.5707963267948966, 1.3169578969248166))], [inverse_case(complex(2, 0)), complex_asin(complex(2, 0), complex(1.5707963267948966, 1.3169578969248166))]).
step(inverse_case(complex(2, 0)), fact(44), [], []).
step(complex_asin(complex(2, 0), complex(1.5707963267948966, 1.3169578969248166)), rule(33), [=('Z', complex(2, 0)), =('C', 1.5707963267948966), =('D', 1.3169578969248166), =('Minor', 1.0), =('Major', 2.0)], [complex_half_axes(complex(2, 0), 1.0, 2.0), is(1.5707963267948966, asin(1.0)), is(1.3169578969248166, log(+(2.0, sqrt(-(*(2.0, 2.0), 1)))))]).
step(complex_half_axes(complex(2, 0), 1.0, 2.0), rule(32), [=('A', 2), =('B', 0), =('Minor', 1.0), =('Major', 2.0), =('Outer', 3.0), =('Inner', 1.0)], [is(3.0, sqrt(+(*(+(1, 2), +(1, 2)), *(0, 0)))), is(1.0, sqrt(+(*(-(1, 2), -(1, 2)), *(0, 0)))), is(1.0, /(-(3.0, 1.0), 2)), is(2.0, /(+(3.0, 1.0), 2))]).
step(is(3.0, sqrt(+(*(+(1, 2), +(1, 2)), *(0, 0)))), builtin, [], []).
step(is(1.0, sqrt(+(*(-(1, 2), -(1, 2)), *(0, 0)))), builtin, [], []).
step(is(1.0, /(-(3.0, 1.0), 2)), builtin, [], []).
step(is(2.0, /(+(3.0, 1.0), 2)), builtin, [], []).
step(is(1.5707963267948966, asin(1.0)), builtin, [], []).
step(is(1.3169578969248166, log(+(2.0, sqrt(-(*(2.0, 2.0), 1))))), builtin, [], []).
step(arccosine(complex(2, 0), complex(0.0, -1.3169578969248166)), rule(47), [=('Z', complex(2, 0)), =('Value', complex(0.0, -1.3169578969248166))], [inverse_case(complex(2, 0)), complex_acos(complex(2, 0), complex(0.0, -1.3169578969248166))]).
step(complex_acos(complex(2, 0), complex(0.0, -1.3169578969248166)), rule(34), [=('Z', complex(2, 0)), =('C', 0.0), =('D', -1.3169578969248166), =('Minor', 1.0), =('Major', 2.0)], [complex_half_axes(complex(2, 0), 1.0, 2.0), is(0.0, acos(1.0)), is(-1.3169578969248166, -(log(+(2.0, sqrt(-(*(2.0, 2.0), 1))))))]).
step(is(0.0, acos(1.0)), builtin, [], []).
step(is(-1.3169578969248166, -(log(+(2.0, sqrt(-(*(2.0, 2.0), 1)))))), builtin, [], []).
step(logarithm(natural, complex(0.0, 3.141592653589793)), rule(48), [=('Value', complex(0.0, 3.141592653589793))], [complex_log(complex(2.718281828459045, 0), complex(-1, 0), complex(0.0, 3.141592653589793))]).
step(complex_log(complex(2.718281828459045, 0), complex(-1, 0), complex(0.0, 3.141592653589793)), rule(35), [=('Base', complex(2.718281828459045, 0)), =('Z', complex(-1, 0)), =('Result', complex(0.0, 3.141592653589793)), =('BaseR', 2.718281828459045), =('BaseAngle', 0.0), =('R', 1.0), =('Angle', 3.141592653589793), =('LogBase', 1.0), =('LogR', 0.0)], [complex_polar(complex(2.718281828459045, 0), polar(2.718281828459045, 0.0)), complex_polar(complex(-1, 0), polar(1.0, 3.141592653589793)), is(1.0, log(2.718281828459045)), is(0.0, log(1.0)), complex_div(complex(0.0, 3.141592653589793), complex(1.0, 0.0), complex(0.0, 3.141592653589793))]).
step(is(1.0, log(2.718281828459045)), builtin, [], []).
step(is(0.0, log(1.0)), builtin, [], []).
step(complex_div(complex(0.0, 3.141592653589793), complex(1.0, 0.0), complex(0.0, 3.141592653589793)), rule(5), [=('A', 0.0), =('B', 3.141592653589793), =('C', 1.0), =('D', 0.0), =('R', 0.0), =('I', 3.141592653589793), =('Norm', 1.0)], [is(1.0, +(*(1.0, 1.0), *(0.0, 0.0))), >(1.0, 0), is(0.0, /(+(*(0.0, 1.0), *(3.141592653589793, 0.0)), 1.0)), is(3.141592653589793, /(-(*(3.141592653589793, 1.0), *(0.0, 0.0)), 1.0))]).
step(is(1.0, +(*(1.0, 1.0), *(0.0, 0.0))), builtin, [], []).
step(is(0.0, /(+(*(0.0, 1.0), *(3.141592653589793, 0.0)), 1.0)), builtin, [], []).
step(is(3.141592653589793, /(-(*(3.141592653589793, 1.0), *(0.0, 0.0)), 1.0)), builtin, [], []).
step(logarithm(imaginary, complex(1.0, 0.0)), rule(49), [=('Value', complex(1.0, 0.0))], [complex_log(complex(0, 1), complex(0, 1), complex(1.0, 0.0))]).
step(complex_log(complex(0, 1), complex(0, 1), complex(1.0, 0.0)), rule(35), [=('Base', complex(0, 1)), =('Z', complex(0, 1)), =('Result', complex(1.0, 0.0)), =('BaseR', 1.0), =('BaseAngle', 1.5707963267948966), =('R', 1.0), =('Angle', 1.5707963267948966), =('LogBase', 0.0), =('LogR', 0.0)], [complex_polar(complex(0, 1), polar(1.0, 1.5707963267948966)), complex_polar(complex(0, 1), polar(1.0, 1.5707963267948966)), is(0.0, log(1.0)), is(0.0, log(1.0)), complex_div(complex(0.0, 1.5707963267948966), complex(0.0, 1.5707963267948966), complex(1.0, 0.0))]).
step(complex_div(complex(0.0, 1.5707963267948966), complex(0.0, 1.5707963267948966), complex(1.0, 0.0)), rule(5), [=('A', 0.0), =('B', 1.5707963267948966), =('C', 0.0), =('D', 1.5707963267948966), =('R', 1.0), =('I', 0.0), =('Norm', 2.4674011002723395)], [is(2.4674011002723395, +(*(0.0, 0.0), *(1.5707963267948966, 1.5707963267948966))), >(2.4674011002723395, 0), is(1.0, /(+(*(0.0, 0.0), *(1.5707963267948966, 1.5707963267948966)), 2.4674011002723395)), is(0.0, /(-(*(1.5707963267948966, 0.0), *(0.0, 1.5707963267948966)), 2.4674011002723395))]).
step(is(2.4674011002723395, +(*(0.0, 0.0), *(1.5707963267948966, 1.5707963267948966))), builtin, [], []).
step(>(2.4674011002723395, 0), builtin, [], []).
step(is(1.0, /(+(*(0.0, 0.0), *(1.5707963267948966, 1.5707963267948966)), 2.4674011002723395)), builtin, [], []).
step(is(0.0, /(-(*(1.5707963267948966, 0.0), *(0.0, 1.5707963267948966)), 2.4674011002723395)), builtin, [], []).
step(sine(complex(1.9999999999999998, 1.0605752387249067e-16)), rule(50), [=('Value', complex(1.9999999999999998, 1.0605752387249067e-16)), =('__anon2', complex(2, 0)), =('Angle', complex(1.5707963267948966, 1.3169578969248166))], [arcsine(complex(2, 0), complex(1.5707963267948966, 1.3169578969248166)), complex_sin(complex(1.5707963267948966, 1.3169578969248166), complex(1.9999999999999998, 1.0605752387249067e-16))]).
step(complex_sin(complex(1.5707963267948966, 1.3169578969248166), complex(1.9999999999999998, 1.0605752387249067e-16)), rule(36), [=('A', 1.5707963267948966), =('B', 1.3169578969248166), =('C', 1.9999999999999998), =('D', 1.0605752387249067e-16)], [is(1.9999999999999998, /(*(sin(1.5707963267948966), +(exp(1.3169578969248166), exp(-(1.3169578969248166)))), 2)), is(1.0605752387249067e-16, /(*(cos(1.5707963267948966), -(exp(1.3169578969248166), exp(-(1.3169578969248166)))), 2))]).
step(is(1.9999999999999998, /(*(sin(1.5707963267948966), +(exp(1.3169578969248166), exp(-(1.3169578969248166)))), 2)), builtin, [], []).
step(is(1.0605752387249067e-16, /(*(cos(1.5707963267948966), -(exp(1.3169578969248166), exp(-(1.3169578969248166)))), 2)), builtin, [], []).
step(cosine(complex(1.9999999999999998, 0.0)), rule(51), [=('Value', complex(1.9999999999999998, 0.0)), =('__anon3', complex(2, 0)), =('Angle', complex(0.0, -1.3169578969248166))], [arccosine(complex(2, 0), complex(0.0, -1.3169578969248166)), complex_cos(complex(0.0, -1.3169578969248166), complex(1.9999999999999998, 0.0))]).
step(complex_cos(complex(0.0, -1.3169578969248166), complex(1.9999999999999998, 0.0)), rule(37), [=('A', 0.0), =('B', -1.3169578969248166), =('C', 1.9999999999999998), =('D', 0.0)], [is(1.9999999999999998, /(*(cos(0.0), +(exp(-1.3169578969248166), exp(-(-1.3169578969248166)))), 2)), is(0.0, /(*(-(sin(0.0)), -(exp(-1.3169578969248166), exp(-(-1.3169578969248166)))), 2))]).
step(is(1.9999999999999998, /(*(cos(0.0), +(exp(-1.3169578969248166), exp(-(-1.3169578969248166)))), 2)), builtin, [], []).
step(is(0.0, /(*(-(sin(0.0)), -(exp(-1.3169578969248166), exp(-(-1.3169578969248166)))), 2)), builtin, [], []).
step(arctangent(complex(1.3389725222944935, 0.402359478108525)), rule(52), [=('Value', complex(1.3389725222944935, 0.402359478108525))], [complex_atan(complex(1, 2), complex(1.3389725222944935, 0.402359478108525))]).
step(complex_atan(complex(1, 2), complex(1.3389725222944935, 0.402359478108525)), rule(39), [=('Z', complex(1, 2)), =('Result', complex(1.3389725222944935, 0.402359478108525)), =('Numerator', complex(-1, -1)), =('Denominator', complex(1, 3)), =('Ratio', complex(-0.4, 0.2)), =('Logarithm', complex(-0.80471895621705, 2.677945044588987))], [complex_sub(complex(0, 1), complex(1, 2), complex(-1, -1)), complex_add(complex(0, 1), complex(1, 2), complex(1, 3)), complex_div(complex(-1, -1), complex(1, 3), complex(-0.4, 0.2)), complex_log(complex(2.718281828459045, 0), complex(-0.4, 0.2), complex(-0.80471895621705, 2.677945044588987)), complex_div(complex(-0.80471895621705, 2.677945044588987), complex(0, 2), complex(1.3389725222944935, 0.402359478108525))]).
step(complex_sub(complex(0, 1), complex(1, 2), complex(-1, -1)), rule(2), [=('A', 0), =('B', 1), =('C', 1), =('D', 2), =('R', -1), =('I', -1)], [is(-1, -(0, 1)), is(-1, -(1, 2))]).
step(is(-1, -(0, 1)), builtin, [], []).
step(is(-1, -(1, 2)), builtin, [], []).
step(complex_add(complex(0, 1), complex(1, 2), complex(1, 3)), rule(1), [=('A', 0), =('B', 1), =('C', 1), =('D', 2), =('R', 1), =('I', 3)], [is(1, +(0, 1)), is(3, +(1, 2))]).
step(is(1, +(0, 1)), builtin, [], []).
step(is(3, +(1, 2)), builtin, [], []).
step(complex_div(complex(-1, -1), complex(1, 3), complex(-0.4, 0.2)), rule(5), [=('A', -1), =('B', -1), =('C', 1), =('D', 3), =('R', -0.4), =('I', 0.2), =('Norm', 10)], [is(10, +(*(1, 1), *(3, 3))), >(10, 0), is(-0.4, /(+(*(-1, 1), *(-1, 3)), 10)), is(0.2, /(-(*(-1, 1), *(-1, 3)), 10))]).
step(is(10, +(*(1, 1), *(3, 3))), builtin, [], []).
step(>(10, 0), builtin, [], []).
step(is(-0.4, /(+(*(-1, 1), *(-1, 3)), 10)), builtin, [], []).
step(is(0.2, /(-(*(-1, 1), *(-1, 3)), 10)), builtin, [], []).
step(complex_log(complex(2.718281828459045, 0), complex(-0.4, 0.2), complex(-0.80471895621705, 2.677945044588987)), rule(35), [=('Base', complex(2.718281828459045, 0)), =('Z', complex(-0.4, 0.2)), =('Result', complex(-0.80471895621705, 2.677945044588987)), =('BaseR', 2.718281828459045), =('BaseAngle', 0.0), =('R', 0.447213595499958), =('Angle', 2.677945044588987), =('LogBase', 1.0), =('LogR', -0.80471895621705)], [complex_polar(complex(2.718281828459045, 0), polar(2.718281828459045, 0.0)), complex_polar(complex(-0.4, 0.2), polar(0.447213595499958, 2.677945044588987)), is(1.0, log(2.718281828459045)), is(-0.80471895621705, log(0.447213595499958)), complex_div(complex(-0.80471895621705, 2.677945044588987), complex(1.0, 0.0), complex(-0.80471895621705, 2.677945044588987))]).
step(complex_polar(complex(-0.4, 0.2), polar(0.447213595499958, 2.677945044588987)), rule(26), [=('X', -0.4), =('Y', 0.2), =('R', 0.447213595499958), =('Angle', 2.677945044588987), =('Reference', 0.46364760900080615)], [is(0.447213595499958, sqrt(+(*(-0.4, -0.4), *(0.2, 0.2)))), >(0.447213595499958, 0), is(0.46364760900080615, acos(/(abs(-0.4), 0.447213595499958))), quadrant_angle(-0.4, 0.2, 0.46364760900080615, 2.677945044588987)]).
step(is(0.447213595499958, sqrt(+(*(-0.4, -0.4), *(0.2, 0.2)))), builtin, [], []).
step(>(0.447213595499958, 0), builtin, [], []).
step(is(0.46364760900080615, acos(/(abs(-0.4), 0.447213595499958))), builtin, [], []).
step(quadrant_angle(-0.4, 0.2, 0.46364760900080615, 2.677945044588987), rule(28), [=('X', -0.4), =('Y', 0.2), =('Reference', 0.46364760900080615), =('Angle', 2.677945044588987), =('Pi', 3.141592653589793)], [<(-0.4, 0), >=(0.2, 0), pi_value(3.141592653589793), is(2.677945044588987, -(3.141592653589793, 0.46364760900080615))]).
step(<(-0.4, 0), builtin, [], []).
step(>=(0.2, 0), builtin, [], []).
step(is(2.677945044588987, -(3.141592653589793, 0.46364760900080615)), builtin, [], []).
step(is(-0.80471895621705, log(0.447213595499958)), builtin, [], []).
step(complex_div(complex(-0.80471895621705, 2.677945044588987), complex(1.0, 0.0), complex(-0.80471895621705, 2.677945044588987)), rule(5), [=('A', -0.80471895621705), =('B', 2.677945044588987), =('C', 1.0), =('D', 0.0), =('R', -0.80471895621705), =('I', 2.677945044588987), =('Norm', 1.0)], [is(1.0, +(*(1.0, 1.0), *(0.0, 0.0))), >(1.0, 0), is(-0.80471895621705, /(+(*(-0.80471895621705, 1.0), *(2.677945044588987, 0.0)), 1.0)), is(2.677945044588987, /(-(*(2.677945044588987, 1.0), *(-0.80471895621705, 0.0)), 1.0))]).
step(is(-0.80471895621705, /(+(*(-0.80471895621705, 1.0), *(2.677945044588987, 0.0)), 1.0)), builtin, [], []).
step(is(2.677945044588987, /(-(*(2.677945044588987, 1.0), *(-0.80471895621705, 0.0)), 1.0)), builtin, [], []).
step(complex_div(complex(-0.80471895621705, 2.677945044588987), complex(0, 2), complex(1.3389725222944935, 0.402359478108525)), rule(5), [=('A', -0.80471895621705), =('B', 2.677945044588987), =('C', 0), =('D', 2), =('R', 1.3389725222944935), =('I', 0.402359478108525), =('Norm', 4)], [is(4, +(*(0, 0), *(2, 2))), >(4, 0), is(1.3389725222944935, /(+(*(-0.80471895621705, 0), *(2.677945044588987, 2)), 4)), is(0.402359478108525, /(-(*(2.677945044588987, 0), *(-0.80471895621705, 2)), 4))]).
step(is(4, +(*(0, 0), *(2, 2))), builtin, [], []).
step(is(1.3389725222944935, /(+(*(-0.80471895621705, 0), *(2.677945044588987, 2)), 4)), builtin, [], []).
step(is(0.402359478108525, /(-(*(2.677945044588987, 0), *(-0.80471895621705, 2)), 4)), builtin, [], []).
step(tangent(complex(1.0, 1.9999999999999996)), rule(53), [=('Value', complex(1.0, 1.9999999999999996)), =('Angle', complex(1.3389725222944935, 0.402359478108525))], [arctangent(complex(1.3389725222944935, 0.402359478108525)), complex_tan(complex(1.3389725222944935, 0.402359478108525), complex(1.0, 1.9999999999999996))]).
step(complex_tan(complex(1.3389725222944935, 0.402359478108525), complex(1.0, 1.9999999999999996)), rule(38), [=('Z', complex(1.3389725222944935, 0.402359478108525)), =('Result', complex(1.0, 1.9999999999999996)), =('Sine', complex(1.0530987581299995, 0.09495785578322327)), =('Cosine', complex(0.2486028939392893, -0.4022479320953552))], [complex_sin(complex(1.3389725222944935, 0.402359478108525), complex(1.0530987581299995, 0.09495785578322327)), complex_cos(complex(1.3389725222944935, 0.402359478108525), complex(0.2486028939392893, -0.4022479320953552)), complex_div(complex(1.0530987581299995, 0.09495785578322327), complex(0.2486028939392893, -0.4022479320953552), complex(1.0, 1.9999999999999996))]).
step(complex_sin(complex(1.3389725222944935, 0.402359478108525), complex(1.0530987581299995, 0.09495785578322327)), rule(36), [=('A', 1.3389725222944935), =('B', 0.402359478108525), =('C', 1.0530987581299995), =('D', 0.09495785578322327)], [is(1.0530987581299995, /(*(sin(1.3389725222944935), +(exp(0.402359478108525), exp(-(0.402359478108525)))), 2)), is(0.09495785578322327, /(*(cos(1.3389725222944935), -(exp(0.402359478108525), exp(-(0.402359478108525)))), 2))]).
step(is(1.0530987581299995, /(*(sin(1.3389725222944935), +(exp(0.402359478108525), exp(-(0.402359478108525)))), 2)), builtin, [], []).
step(is(0.09495785578322327, /(*(cos(1.3389725222944935), -(exp(0.402359478108525), exp(-(0.402359478108525)))), 2)), builtin, [], []).
step(complex_cos(complex(1.3389725222944935, 0.402359478108525), complex(0.2486028939392893, -0.4022479320953552)), rule(37), [=('A', 1.3389725222944935), =('B', 0.402359478108525), =('C', 0.2486028939392893), =('D', -0.4022479320953552)], [is(0.2486028939392893, /(*(cos(1.3389725222944935), +(exp(0.402359478108525), exp(-(0.402359478108525)))), 2)), is(-0.4022479320953552, /(*(-(sin(1.3389725222944935)), -(exp(0.402359478108525), exp(-(0.402359478108525)))), 2))]).
step(is(0.2486028939392893, /(*(cos(1.3389725222944935), +(exp(0.402359478108525), exp(-(0.402359478108525)))), 2)), builtin, [], []).
step(is(-0.4022479320953552, /(*(-(sin(1.3389725222944935)), -(exp(0.402359478108525), exp(-(0.402359478108525)))), 2)), builtin, [], []).
step(complex_div(complex(1.0530987581299995, 0.09495785578322327), complex(0.2486028939392893, -0.4022479320953552), complex(1.0, 1.9999999999999996)), rule(5), [=('A', 1.0530987581299995), =('B', 0.09495785578322327), =('C', 0.2486028939392893), =('D', -0.4022479320953552), =('R', 1.0), =('I', 1.9999999999999996), =('Norm', 0.22360679774997902)], [is(0.22360679774997902, +(*(0.2486028939392893, 0.2486028939392893), *(-0.4022479320953552, -0.4022479320953552))), >(0.22360679774997902, 0), is(1.0, /(+(*(1.0530987581299995, 0.2486028939392893), *(0.09495785578322327, -0.4022479320953552)), 0.22360679774997902)), is(1.9999999999999996, /(-(*(0.09495785578322327, 0.2486028939392893), *(1.0530987581299995, -0.4022479320953552)), 0.22360679774997902))]).
step(is(0.22360679774997902, +(*(0.2486028939392893, 0.2486028939392893), *(-0.4022479320953552, -0.4022479320953552))), builtin, [], []).
step(>(0.22360679774997902, 0), builtin, [], []).
step(is(1.0, /(+(*(1.0530987581299995, 0.2486028939392893), *(0.09495785578322327, -0.4022479320953552)), 0.22360679774997902)), builtin, [], []).
step(is(1.9999999999999996, /(-(*(0.09495785578322327, 0.2486028939392893), *(1.0530987581299995, -0.4022479320953552)), 0.22360679774997902)), builtin, [], []).
