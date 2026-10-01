% Distinct rule identifiers give distinct witnesses for the same input binding.
animal(koko).
type(record(cat_rule, X), cat) :+ animal(X).
type(record(breed_rule, X), british_shorthair) :+ animal(X).
distinct_records(X, Cat, Breed) :+ animal(X), type(Cat, cat), type(Breed, british_shorthair), Cat \= Breed.
true :+ distinct_records(Animal, Cat, Breed).
