append([], "ab", "ab").
append("a", "b", "ab").
append("ab", [], "ab").
matching_pair(pair(same, same)).
head_tail("abc", a, "bc").

clause(1, append([], var('Ys'), var('Ys')), true).
clause(2, append('.'(var('X'), var('Xs')), var('Ys'), '.'(var('X'), var('Zs'))), append(var('Xs'), var('Ys'), var('Zs'))).
clause(3, matching_pair(pair(var('X'), var('X'))), true).
clause(4, head_tail('.'(var('Head'), var('Tail')), var('Head'), var('Tail')), true).

step(append([], "ab", "ab"), fact(1), '.'(=('Ys', "ab"), []), []).
step(append("a", "b", "ab"), rule(2), '.'(=('X', a), '.'(=('Xs', []), '.'(=('Ys', "b"), '.'(=('Zs', "b"), [])))), '.'(append([], "b", "b"), [])).
step(append([], "b", "b"), fact(1), '.'(=('Ys', "b"), []), []).
step(append("ab", [], "ab"), rule(2), '.'(=('X', a), '.'(=('Xs', "b"), '.'(=('Ys', []), '.'(=('Zs', "b"), [])))), '.'(append("b", [], "b"), [])).
step(append("b", [], "b"), rule(2), '.'(=('X', b), '.'(=('Xs', []), '.'(=('Ys', []), '.'(=('Zs', []), [])))), '.'(append([], [], []), [])).
step(append([], [], []), fact(1), '.'(=('Ys', []), []), []).
step(matching_pair(pair(same, same)), fact(3), '.'(=('X', same), []), []).
step(head_tail("abc", a, "bc"), fact(4), '.'(=('Head', a), '.'(=('Tail', "bc"), [])), []).
