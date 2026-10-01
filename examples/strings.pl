% Atoms can be constructed and inspected without text-specific rule syntax.
label(Name, Label) :- atom_concat('hello_', Name, Label).
characters(Text, Chars, Length) :- atom_chars(Text, Chars), atom_length(Text, Length).
unicode_codes(Text, Codes) :- atom_codes(Text, Codes).
?- label(alice, Label).
?- characters('café', Chars, Length).
?- unicode_codes('😀', Codes).
