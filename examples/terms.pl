% IRIs, datatypes, language tags, lists, formulas and triple terms need
% representations, not additional language syntax or engine state.
quoted(graph([triple(iri('https://example.org/s'), iri('https://example.org/p'), literal('hello', lang(en)))] )).
member_of(X, [X|_]).
member_of(X, [_|Xs]) :- member_of(X, Xs).
includes(graph(Triples), Triple) :- member_of(Triple, Triples).
found(T) :+ quoted(G), includes(G, T).
witness(X, W) :+ quoted(X).
