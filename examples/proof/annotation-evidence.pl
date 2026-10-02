claim(alice, name, literal('Alice', datatype(string))).
reifies(s1, alice, name, literal('Alice', datatype(string))).
statement_author(s1, bob).
statement_date(s1, date(2021, 7, 7)).
evidence(alice, name, literal('Alice', datatype(string)), bob, date(2021, 7, 7)).

clause(1, statement(s1, triple(alice, name, literal('Alice', datatype(string)))), true).
clause(2, stated_by(s1, bob), true).
clause(3, recorded(s1, date(2021, 7, 7)), true).
clause(4, claim(var('S'), var('P'), var('O')), statement(var('__anon0'), triple(var('S'), var('P'), var('O')))).
clause(5, reifies(var('Id'), var('S'), var('P'), var('O')), statement(var('Id'), triple(var('S'), var('P'), var('O')))).
clause(6, statement_author(var('Id'), var('Author')), ','(statement(var('Id'), var('__anon1')), stated_by(var('Id'), var('Author')))).
clause(7, statement_date(var('Id'), var('Date')), ','(statement(var('Id'), var('__anon2')), recorded(var('Id'), var('Date')))).
clause(8, evidence(var('S'), var('P'), var('O'), var('Author'), var('Date')), ','(statement(var('Id'), triple(var('S'), var('P'), var('O'))), ','(stated_by(var('Id'), var('Author')), recorded(var('Id'), var('Date'))))).

step(claim(alice, name, literal('Alice', datatype(string))), rule(4), '.'(=('S', alice), '.'(=('P', name), '.'(=('O', literal('Alice', datatype(string))), '.'(=('__anon0', s1), [])))), '.'(statement(s1, triple(alice, name, literal('Alice', datatype(string)))), [])).
step(statement(s1, triple(alice, name, literal('Alice', datatype(string)))), fact(1), [], []).
step(reifies(s1, alice, name, literal('Alice', datatype(string))), rule(5), '.'(=('Id', s1), '.'(=('S', alice), '.'(=('P', name), '.'(=('O', literal('Alice', datatype(string))), [])))), '.'(statement(s1, triple(alice, name, literal('Alice', datatype(string)))), [])).
step(statement_author(s1, bob), rule(6), '.'(=('Id', s1), '.'(=('Author', bob), '.'(=('__anon1', triple(alice, name, literal('Alice', datatype(string)))), []))), '.'(statement(s1, triple(alice, name, literal('Alice', datatype(string)))), '.'(stated_by(s1, bob), []))).
step(stated_by(s1, bob), fact(2), [], []).
step(statement_date(s1, date(2021, 7, 7)), rule(7), '.'(=('Id', s1), '.'(=('Date', date(2021, 7, 7)), '.'(=('__anon2', triple(alice, name, literal('Alice', datatype(string)))), []))), '.'(statement(s1, triple(alice, name, literal('Alice', datatype(string)))), '.'(recorded(s1, date(2021, 7, 7)), []))).
step(recorded(s1, date(2021, 7, 7)), fact(3), [], []).
step(evidence(alice, name, literal('Alice', datatype(string)), bob, date(2021, 7, 7)), rule(8), '.'(=('S', alice), '.'(=('P', name), '.'(=('O', literal('Alice', datatype(string))), '.'(=('Author', bob), '.'(=('Date', date(2021, 7, 7)), '.'(=('Id', s1), [])))))), '.'(statement(s1, triple(alice, name, literal('Alice', datatype(string)))), '.'(stated_by(s1, bob), '.'(recorded(s1, date(2021, 7, 7)), [])))).
