label(alice, hello_alice).
characters('café', "café", 4).
unicode_codes('😀', '.'(128512, [])).

clause(1, label(var('Name'), var('Label')), atom_concat(hello_, var('Name'), var('Label'))).
clause(2, characters(var('Text'), var('Chars'), var('Length')), ','(atom_chars(var('Text'), var('Chars')), atom_length(var('Text'), var('Length')))).
clause(3, unicode_codes(var('Text'), var('Codes')), atom_codes(var('Text'), var('Codes'))).

step(label(alice, hello_alice), rule(1), '.'(=('Name', alice), '.'(=('Label', hello_alice), [])), '.'(atom_concat(hello_, alice, hello_alice), [])).
step(atom_concat(hello_, alice, hello_alice), builtin, [], []).
step(characters('café', "café", 4), rule(2), '.'(=('Text', 'café'), '.'(=('Chars', "café"), '.'(=('Length', 4), []))), '.'(atom_chars('café', "café"), '.'(atom_length('café', 4), []))).
step(atom_chars('café', "café"), builtin, [], []).
step(atom_length('café', 4), builtin, [], []).
step(unicode_codes('😀', '.'(128512, [])), rule(3), '.'(=('Text', '😀'), '.'(=('Codes', '.'(128512, [])), [])), '.'(atom_codes('😀', '.'(128512, [])), [])).
step(atom_codes('😀', '.'(128512, [])), builtin, [], []).
