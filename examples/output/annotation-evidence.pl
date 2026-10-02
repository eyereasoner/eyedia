claim(alice, name, literal('Alice', datatype(string))).
reifies(s1, alice, name, literal('Alice', datatype(string))).
statement_author(s1, bob).
statement_date(s1, date(2021, 7, 7)).
evidence(alice, name, literal('Alice', datatype(string)), bob, date(2021, 7, 7)).
