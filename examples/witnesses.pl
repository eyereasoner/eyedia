% A structured witness identifies the rule and the binding that created it.
person(alice).
person(bob).
(has_record(Name, record(person_rule, Name)), record_owner(record(person_rule, Name), Name)) :+ person(Name).
