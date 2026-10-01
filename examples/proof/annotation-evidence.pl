claim(alice, name, literal('Alice', datatype(string))).
evidence(alice, name, literal('Alice', datatype(string)), bob, date(2021, 7, 7)).

clause(1, statement(s1, triple(alice, name, literal('Alice', datatype(string)))), true).
clause(2, stated_by(s1, bob), true).
clause(3, recorded(s1, date(2021, 7, 7)), true).
clause(4, claim(var('S'), var('P'), var('O')), statement(var('__anon0'), triple(var('S'), var('P'), var('O')))).
clause(5, evidence(var('S'), var('P'), var('O'), var('Author'), var('Date')), ','(statement(var('Id'), triple(var('S'), var('P'), var('O'))), ','(stated_by(var('Id'), var('Author')), recorded(var('Id'), var('Date'))))).

step(claim(alice, name, literal('Alice', datatype(string))), rule(4), '.'(=('S', alice), '.'(=('P', name), '.'(=('O', literal('Alice', datatype(string))), '.'(=('__anon0', s1), [])))), '.'(statement(s1, triple(alice, name, literal('Alice', datatype(string)))), [])).
step(statement(s1, triple(alice, name, literal('Alice', datatype(string)))), fact(1), [], []).
step(evidence(alice, name, literal('Alice', datatype(string)), bob, date(2021, 7, 7)), rule(5), '.'(=('S', alice), '.'(=('P', name), '.'(=('O', literal('Alice', datatype(string))), '.'(=('Author', bob), '.'(=('Date', date(2021, 7, 7)), '.'(=('Id', s1), [])))))), '.'(statement(s1, triple(alice, name, literal('Alice', datatype(string)))), '.'(stated_by(s1, bob), '.'(recorded(s1, date(2021, 7, 7)), [])))).
step(stated_by(s1, bob), fact(2), [], []).
step(recorded(s1, date(2021, 7, 7)), fact(3), [], []).
