% Match a structured description without treating "good" as a global property.
description(joe, [good, cobbler]).
description(jane, [good, carpenter]).
description(sam, [novice, cobbler]).
good_at(Person, Trade) :+ description(Person, [good, Trade]).
classified_as(Person, Trade) :+ description(Person, [good, Trade]).
true :+ good_at(Person, Trade).
true :+ classified_as(Person, Trade).
