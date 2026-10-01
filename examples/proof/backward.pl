indeed_more_interesting(5, 3).

clause(1, more_interesting(var('X'), var('Y')), >(var('X'), var('Y'))).
clause(2, indeed_more_interesting(5, 3), more_interesting(5, 3)).

step(indeed_more_interesting(5, 3), rule(2), [], '.'(more_interesting(5, 3), [])).
step(more_interesting(5, 3), rule(1), '.'(=('X', 5), '.'(=('Y', 3), [])), '.'(>(5, 3), [])).
step(>(5, 3), builtin, [], []).
