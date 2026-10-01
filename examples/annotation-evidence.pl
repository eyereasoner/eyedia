% Statement identifiers attach author and date evidence to a quoted triple.
statement(s1, triple(alice, name, literal('Alice', datatype(string)))).
stated_by(s1, bob).
recorded(s1, date(2021, 7, 7)).
claim(S, P, O) :+ statement(_, triple(S, P, O)).
evidence(S, P, O, Author, Date) :+ statement(Id, triple(S, P, O)), stated_by(Id, Author), recorded(Id, Date).
