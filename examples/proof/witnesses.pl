has_record(alice, record(person_rule, alice)).
record_owner(record(person_rule, alice), alice).
has_record(bob, record(person_rule, bob)).
record_owner(record(person_rule, bob), bob).

clause(1, person(alice), true).
clause(2, person(bob), true).
clause(3, ','(has_record(var('Name'), record(person_rule, var('Name'))), record_owner(record(person_rule, var('Name')), var('Name'))), person(var('Name'))).

step(has_record(alice, record(person_rule, alice)), rule(3), [=('Name', alice)], [person(alice)]).
step(person(alice), fact(1), [], []).
step(record_owner(record(person_rule, alice), alice), rule(3), [=('Name', alice)], [person(alice)]).
step(has_record(bob, record(person_rule, bob)), rule(3), [=('Name', bob)], [person(bob)]).
step(person(bob), fact(2), [], []).
step(record_owner(record(person_rule, bob), bob), rule(3), [=('Name', bob)], [person(bob)]).
