distinct_records(koko, record(cat_rule, koko), record(breed_rule, koko)).

clause(1, animal(koko), true).
clause(2, type(record(cat_rule, var('X')), cat), animal(var('X'))).
clause(3, type(record(breed_rule, var('X')), british_shorthair), animal(var('X'))).
clause(4, distinct_records(var('X'), var('Cat'), var('Breed')), ','(animal(var('X')), ','(type(var('Cat'), cat), ','(type(var('Breed'), british_shorthair), \=(var('Cat'), var('Breed')))))).

step(distinct_records(koko, record(cat_rule, koko), record(breed_rule, koko)), rule(4), [=('X', koko), =('Cat', record(cat_rule, koko)), =('Breed', record(breed_rule, koko))], [animal(koko), type(record(cat_rule, koko), cat), type(record(breed_rule, koko), british_shorthair), \=(record(cat_rule, koko), record(breed_rule, koko))]).
step(animal(koko), fact(1), [], []).
step(type(record(cat_rule, koko), cat), rule(2), [=('X', koko)], [animal(koko)]).
step(type(record(breed_rule, koko), british_shorthair), rule(3), [=('X', koko)], [animal(koko)]).
step(\=(record(cat_rule, koko), record(breed_rule, koko)), builtin, [], []).
