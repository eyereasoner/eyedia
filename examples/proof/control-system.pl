control1(actuator1, 39.27346198678276).
control1(actuator2, 26.08).

clause(1, measurement1(input1, [6, 11]), true).
clause(3, measurement2(input2, true), true).
clause(5, measurement3(disturbance1, 35766), true).
clause(6, measurement4(output2, 24), true).
clause(9, observation3(state3, 22), true).
clause(10, target2(output2, 29), true).
clause(11, control1(actuator1, var('C')), ','(measurement10(input1, var('M1')), ','(measurement2(input2, true), ','(measurement3(disturbance1, var('D1')), ','(is(var('C1'), *(var('M1'), 19.6)), ','(is(var('C2'), /(log(var('D1')), log(10))), is(var('C'), -(var('C1'), var('C2'))))))))).
clause(12, control1(actuator2, var('C')), ','(observation3(state3, var('P3')), ','(measurement4(output2, var('M4')), ','(target2(output2, var('T2')), ','(is(var('E'), -(var('T2'), var('M4'))), ','(is(var('D'), -(var('P3'), var('M4'))), ','(is(var('C1'), *(5.8, var('E'))), ','(is(var('N'), /(7.3, var('E'))), ','(is(var('C2'), *(var('N'), var('D'))), is(var('C'), +(var('C1'), var('C2')))))))))))).
clause(13, measurement10(var('I'), var('M')), ','(measurement1(var('I'), [var('M1'), var('M2')]), ','(<(var('M1'), var('M2')), ','(is(var('M3'), -(var('M2'), var('M1'))), is(var('M'), sqrt(var('M3'))))))).

step(control1(actuator1, 39.27346198678276), rule(11), [=('C', 39.27346198678276), =('M1', 2.23606797749979), =('D1', 35766), =('C1', 43.82693235899588), =('C2', 4.553470372213121)], [measurement10(input1, 2.23606797749979), measurement2(input2, true), measurement3(disturbance1, 35766), is(43.82693235899588, *(2.23606797749979, 19.6)), is(4.553470372213121, /(log(35766), log(10))), is(39.27346198678276, -(43.82693235899588, 4.553470372213121))]).
step(measurement10(input1, 2.23606797749979), rule(13), [=('I', input1), =('M', 2.23606797749979), =('M1', 6), =('M2', 11), =('M3', 5)], [measurement1(input1, [6, 11]), <(6, 11), is(5, -(11, 6)), is(2.23606797749979, sqrt(5))]).
step(measurement1(input1, [6, 11]), fact(1), [], []).
step(<(6, 11), builtin, [], []).
step(is(5, -(11, 6)), builtin, [], []).
step(is(2.23606797749979, sqrt(5)), builtin, [], []).
step(measurement2(input2, true), fact(3), [], []).
step(measurement3(disturbance1, 35766), fact(5), [], []).
step(is(43.82693235899588, *(2.23606797749979, 19.6)), builtin, [], []).
step(is(4.553470372213121, /(log(35766), log(10))), builtin, [], []).
step(is(39.27346198678276, -(43.82693235899588, 4.553470372213121)), builtin, [], []).
step(control1(actuator2, 26.08), rule(12), [=('C', 26.08), =('P3', 22), =('M4', 24), =('T2', 29), =('E', 5), =('D', -2), =('C1', 29.0), =('N', 1.46), =('C2', -2.92)], [observation3(state3, 22), measurement4(output2, 24), target2(output2, 29), is(5, -(29, 24)), is(-2, -(22, 24)), is(29.0, *(5.8, 5)), is(1.46, /(7.3, 5)), is(-2.92, *(1.46, -2)), is(26.08, +(29.0, -2.92))]).
step(observation3(state3, 22), fact(9), [], []).
step(measurement4(output2, 24), fact(6), [], []).
step(target2(output2, 29), fact(10), [], []).
step(is(5, -(29, 24)), builtin, [], []).
step(is(-2, -(22, 24)), builtin, [], []).
step(is(29.0, *(5.8, 5)), builtin, [], []).
step(is(1.46, /(7.3, 5)), builtin, [], []).
step(is(-2.92, *(1.46, -2)), builtin, [], []).
step(is(26.08, +(29.0, -2.92)), builtin, [], []).
