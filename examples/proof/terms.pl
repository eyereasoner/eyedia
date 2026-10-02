found(triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))).
witness(graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))]), sk_0).

clause(1, quoted(graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))])), true).
clause(2, member_of(var('X'), [var('X')|var('__anon0')]), true).
clause(4, includes(graph(var('Triples')), var('Triple')), member_of(var('Triple'), var('Triples'))).
clause(5, found(var('T')), ','(quoted(var('G')), includes(var('G'), var('T')))).
clause(6, witness(var('X'), var('W')), quoted(var('X'))).

step(found(triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))), rule(5), [=('T', triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))), =('G', graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))]))], [quoted(graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))])), includes(graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))]), triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en))))]).
step(quoted(graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))])), fact(1), [], []).
step(includes(graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))]), triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))), rule(4), [=('Triples', [triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))]), =('Triple', triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en))))], [member_of(triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en))), [triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))])]).
step(member_of(triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en))), [triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))]), fact(2), [=('X', triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))), =('__anon0', [])], []).
step(witness(graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))]), sk_0), rule(6), [=('X', graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))])), =('W', sk_0)], [quoted(graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal(hello, lang(en)))]))]).
