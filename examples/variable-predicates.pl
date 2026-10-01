% A predicate position is data, so a rule can rename several relations at once.
t(alice, source_name, 'Alice').
t(alice, source_age, 30).
maps(source_name, name).
maps(source_age, age).
t(S, Target, O) :+ t(S, Source, O), maps(Source, Target).
true :+ t(alice, name, Name).
true :+ t(alice, age, Age).
