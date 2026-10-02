generation(bob, 1).
generation(carol, 1).
branch(heidi, b).
branch(ivan, b).
branch(judy, c).
generation(dave, 2).
generation(eve, 2).
generation(frank, 2).
generation(grace, 2).
cousin(dave, frank).
cousin(dave, grace).
cousin(eve, frank).
cousin(eve, grace).
cousin(frank, dave).
cousin(frank, eve).
cousin(grace, dave).
cousin(grace, eve).
generation(heidi, 3).
generation(ivan, 3).
generation(judy, 3).
cousin(heidi, judy).
cousin(ivan, judy).
cousin(judy, heidi).
cousin(judy, ivan).

clause(1, parent(adam, bob), true).
clause(2, parent(adam, carol), true).
clause(3, parent(bob, dave), true).
clause(4, parent(bob, eve), true).
clause(5, parent(carol, frank), true).
clause(6, parent(carol, grace), true).
clause(7, parent(dave, heidi), true).
clause(8, parent(eve, ivan), true).
clause(9, parent(frank, judy), true).
clause(10, generation(adam, 0), true).
clause(11, branch(dave, b), true).
clause(12, branch(eve, b), true).
clause(13, branch(frank, c), true).
clause(14, branch(grace, c), true).
clause(15, generation(var('Child'), var('Next')), ','(parent(var('Parent'), var('Child')), ','(generation(var('Parent'), var('N')), is(var('Next'), +(var('N'), 1))))).
clause(16, branch(var('Child'), var('Branch')), ','(parent(var('Parent'), var('Child')), branch(var('Parent'), var('Branch')))).
clause(17, cousin(var('X'), var('Y')), ','(generation(var('X'), var('N')), ','(generation(var('Y'), var('N')), ','(branch(var('X'), var('A')), ','(branch(var('Y'), var('B')), \=(var('A'), var('B'))))))).

step(generation(bob, 1), rule(15), '.'(=('Child', bob), '.'(=('Next', 1), '.'(=('Parent', adam), '.'(=('N', 0), [])))), '.'(parent(adam, bob), '.'(generation(adam, 0), '.'(is(1, +(0, 1)), [])))).
step(parent(adam, bob), fact(1), [], []).
step(generation(adam, 0), fact(10), [], []).
step(is(1, +(0, 1)), builtin, [], []).
step(generation(carol, 1), rule(15), '.'(=('Child', carol), '.'(=('Next', 1), '.'(=('Parent', adam), '.'(=('N', 0), [])))), '.'(parent(adam, carol), '.'(generation(adam, 0), '.'(is(1, +(0, 1)), [])))).
step(parent(adam, carol), fact(2), [], []).
step(branch(heidi, b), rule(16), '.'(=('Child', heidi), '.'(=('Branch', b), '.'(=('Parent', dave), []))), '.'(parent(dave, heidi), '.'(branch(dave, b), []))).
step(parent(dave, heidi), fact(7), [], []).
step(branch(dave, b), fact(11), [], []).
step(branch(ivan, b), rule(16), '.'(=('Child', ivan), '.'(=('Branch', b), '.'(=('Parent', eve), []))), '.'(parent(eve, ivan), '.'(branch(eve, b), []))).
step(parent(eve, ivan), fact(8), [], []).
step(branch(eve, b), fact(12), [], []).
step(branch(judy, c), rule(16), '.'(=('Child', judy), '.'(=('Branch', c), '.'(=('Parent', frank), []))), '.'(parent(frank, judy), '.'(branch(frank, c), []))).
step(parent(frank, judy), fact(9), [], []).
step(branch(frank, c), fact(13), [], []).
step(generation(dave, 2), rule(15), '.'(=('Child', dave), '.'(=('Next', 2), '.'(=('Parent', bob), '.'(=('N', 1), [])))), '.'(parent(bob, dave), '.'(generation(bob, 1), '.'(is(2, +(1, 1)), [])))).
step(parent(bob, dave), fact(3), [], []).
step(is(2, +(1, 1)), builtin, [], []).
step(generation(eve, 2), rule(15), '.'(=('Child', eve), '.'(=('Next', 2), '.'(=('Parent', bob), '.'(=('N', 1), [])))), '.'(parent(bob, eve), '.'(generation(bob, 1), '.'(is(2, +(1, 1)), [])))).
step(parent(bob, eve), fact(4), [], []).
step(generation(frank, 2), rule(15), '.'(=('Child', frank), '.'(=('Next', 2), '.'(=('Parent', carol), '.'(=('N', 1), [])))), '.'(parent(carol, frank), '.'(generation(carol, 1), '.'(is(2, +(1, 1)), [])))).
step(parent(carol, frank), fact(5), [], []).
step(generation(grace, 2), rule(15), '.'(=('Child', grace), '.'(=('Next', 2), '.'(=('Parent', carol), '.'(=('N', 1), [])))), '.'(parent(carol, grace), '.'(generation(carol, 1), '.'(is(2, +(1, 1)), [])))).
step(parent(carol, grace), fact(6), [], []).
step(cousin(dave, frank), rule(17), '.'(=('X', dave), '.'(=('Y', frank), '.'(=('N', 2), '.'(=('A', b), '.'(=('B', c), []))))), '.'(generation(dave, 2), '.'(generation(frank, 2), '.'(branch(dave, b), '.'(branch(frank, c), '.'(\=(b, c), [])))))).
step(\=(b, c), builtin, [], []).
step(cousin(dave, grace), rule(17), '.'(=('X', dave), '.'(=('Y', grace), '.'(=('N', 2), '.'(=('A', b), '.'(=('B', c), []))))), '.'(generation(dave, 2), '.'(generation(grace, 2), '.'(branch(dave, b), '.'(branch(grace, c), '.'(\=(b, c), [])))))).
step(branch(grace, c), fact(14), [], []).
step(cousin(eve, frank), rule(17), '.'(=('X', eve), '.'(=('Y', frank), '.'(=('N', 2), '.'(=('A', b), '.'(=('B', c), []))))), '.'(generation(eve, 2), '.'(generation(frank, 2), '.'(branch(eve, b), '.'(branch(frank, c), '.'(\=(b, c), [])))))).
step(cousin(eve, grace), rule(17), '.'(=('X', eve), '.'(=('Y', grace), '.'(=('N', 2), '.'(=('A', b), '.'(=('B', c), []))))), '.'(generation(eve, 2), '.'(generation(grace, 2), '.'(branch(eve, b), '.'(branch(grace, c), '.'(\=(b, c), [])))))).
step(cousin(frank, dave), rule(17), '.'(=('X', frank), '.'(=('Y', dave), '.'(=('N', 2), '.'(=('A', c), '.'(=('B', b), []))))), '.'(generation(frank, 2), '.'(generation(dave, 2), '.'(branch(frank, c), '.'(branch(dave, b), '.'(\=(c, b), [])))))).
step(\=(c, b), builtin, [], []).
step(cousin(frank, eve), rule(17), '.'(=('X', frank), '.'(=('Y', eve), '.'(=('N', 2), '.'(=('A', c), '.'(=('B', b), []))))), '.'(generation(frank, 2), '.'(generation(eve, 2), '.'(branch(frank, c), '.'(branch(eve, b), '.'(\=(c, b), [])))))).
step(cousin(grace, dave), rule(17), '.'(=('X', grace), '.'(=('Y', dave), '.'(=('N', 2), '.'(=('A', c), '.'(=('B', b), []))))), '.'(generation(grace, 2), '.'(generation(dave, 2), '.'(branch(grace, c), '.'(branch(dave, b), '.'(\=(c, b), [])))))).
step(cousin(grace, eve), rule(17), '.'(=('X', grace), '.'(=('Y', eve), '.'(=('N', 2), '.'(=('A', c), '.'(=('B', b), []))))), '.'(generation(grace, 2), '.'(generation(eve, 2), '.'(branch(grace, c), '.'(branch(eve, b), '.'(\=(c, b), [])))))).
step(generation(heidi, 3), rule(15), '.'(=('Child', heidi), '.'(=('Next', 3), '.'(=('Parent', dave), '.'(=('N', 2), [])))), '.'(parent(dave, heidi), '.'(generation(dave, 2), '.'(is(3, +(2, 1)), [])))).
step(is(3, +(2, 1)), builtin, [], []).
step(generation(ivan, 3), rule(15), '.'(=('Child', ivan), '.'(=('Next', 3), '.'(=('Parent', eve), '.'(=('N', 2), [])))), '.'(parent(eve, ivan), '.'(generation(eve, 2), '.'(is(3, +(2, 1)), [])))).
step(generation(judy, 3), rule(15), '.'(=('Child', judy), '.'(=('Next', 3), '.'(=('Parent', frank), '.'(=('N', 2), [])))), '.'(parent(frank, judy), '.'(generation(frank, 2), '.'(is(3, +(2, 1)), [])))).
step(cousin(heidi, judy), rule(17), '.'(=('X', heidi), '.'(=('Y', judy), '.'(=('N', 3), '.'(=('A', b), '.'(=('B', c), []))))), '.'(generation(heidi, 3), '.'(generation(judy, 3), '.'(branch(heidi, b), '.'(branch(judy, c), '.'(\=(b, c), [])))))).
step(cousin(ivan, judy), rule(17), '.'(=('X', ivan), '.'(=('Y', judy), '.'(=('N', 3), '.'(=('A', b), '.'(=('B', c), []))))), '.'(generation(ivan, 3), '.'(generation(judy, 3), '.'(branch(ivan, b), '.'(branch(judy, c), '.'(\=(b, c), [])))))).
step(cousin(judy, heidi), rule(17), '.'(=('X', judy), '.'(=('Y', heidi), '.'(=('N', 3), '.'(=('A', c), '.'(=('B', b), []))))), '.'(generation(judy, 3), '.'(generation(heidi, 3), '.'(branch(judy, c), '.'(branch(heidi, b), '.'(\=(c, b), [])))))).
step(cousin(judy, ivan), rule(17), '.'(=('X', judy), '.'(=('Y', ivan), '.'(=('N', 3), '.'(=('A', c), '.'(=('B', b), []))))), '.'(generation(judy, 3), '.'(generation(ivan, 3), '.'(branch(judy, c), '.'(branch(ivan, b), '.'(\=(c, b), [])))))).
