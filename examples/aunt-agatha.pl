% Who killed Aunt Agatha? Pelletier's problem 55, puzzle PUZ001 in TPTP:
%   1. Someone who lives in Dreadbury Mansion killed Aunt Agatha.
%   2. Agatha, the butler and Charles live in Dreadbury Mansion, and are the
%      only people who live therein.
%   3. A killer always hates their victim, and is never richer than them.
%   4. Charles hates no one that Aunt Agatha hates.
%   5. Agatha hates everyone except the butler.
%   6. The butler hates everyone not richer than Aunt Agatha.
%   7. The butler hates everyone Aunt Agatha hates.
%   8. No one hates everyone.
%   9. Agatha is not the butler.
% Therefore Agatha killed herself.
%
% The conclusion is entailed, not merely possible: it must hold in every
% situation the premises allow. They leave open who hates whom and who is
% richer than whom, so a model assigns yes or no to each hates(X, Y) and to
% each richer(X, agatha); the rest of richer/2 occurs in no premise. Every
% model is enumerated, and in every one of them the killer is Agatha.
%
% A premise narrows the values it constrains and leaves the others unbound;
% labelling gives each remaining value yes and then no, so every model is
% found exactly once. Premise 9 holds because distinct atoms never unify.

model(Killer, world(Richer, Hates)) :-
    Richer = richer(RA, RB, RC),
    Hates = hates(AA, AB, AC, BA, BB, BC, CA, CB, CC),
    resident(Killer),                                             % 1, 2
    hates(Hates, Killer, agatha, yes), richer(Richer, Killer, no), % 3
    implies_not(AA, CA), implies_not(AB, CB), implies_not(AC, CC), % 4
    AA = yes, AC = yes,                                           % 5
    unless(RA, BA), unless(RB, BB), unless(RC, BC),               % 6
    implies(AA, BA), implies(AB, BB), implies(AC, BC),            % 7
    label([RA, RB, RC, AA, AB, AC, BA, BB, BC, CA, CB, CC]),
    some_no(AA, AB, AC), some_no(BA, BB, BC), some_no(CA, CB, CC). % 8

resident(agatha).
resident(butler).
resident(charles).

% hates(Hates, X, Y, V): V says whether X hates Y.
hates(hates(V, _, _, _, _, _, _, _, _), agatha, agatha, V).
hates(hates(_, V, _, _, _, _, _, _, _), agatha, butler, V).
hates(hates(_, _, V, _, _, _, _, _, _), agatha, charles, V).
hates(hates(_, _, _, V, _, _, _, _, _), butler, agatha, V).
hates(hates(_, _, _, _, V, _, _, _, _), butler, butler, V).
hates(hates(_, _, _, _, _, V, _, _, _), butler, charles, V).
hates(hates(_, _, _, _, _, _, V, _, _), charles, agatha, V).
hates(hates(_, _, _, _, _, _, _, V, _), charles, butler, V).
hates(hates(_, _, _, _, _, _, _, _, V), charles, charles, V).
% richer(Richer, X, V): V says whether X is richer than Agatha.
richer(richer(V, _, _), agatha, V).
richer(richer(_, V, _), butler, V).
richer(richer(_, _, V), charles, V).

truth(yes).
truth(no).
label([]).
label([V|Vs]) :- truth(V), label(Vs).
% Each connective's clauses are mutually exclusive in their first argument,
% so a value that is still unbound splits the search without duplicates.
implies(no, _).          % A -> B
implies(yes, yes).
implies_not(no, _).      % A -> not B
implies_not(yes, no).
unless(yes, _).          % not A -> B
unless(no, yes).
some_no(no, _, _).       % not (A and B and C)
some_no(yes, no, _).
some_no(yes, yes, no).

count([], 0).
count([_|Xs], N) :- count(Xs, M), N is M + 1.

% How many models make each resident the killer.
models(Suspect, N) :+ resident(Suspect), findall(W, model(Suspect, W), Ws), count(Ws, N).
% Entailment: some model exists, and every model has Agatha as the killer.
entailed(killed(agatha, agatha)) :+ models(agatha, N), N > 0, models(butler, 0), models(charles, 0).
% One model in full, with a proof that every premise holds in it.
witness(Killer, W) :+ once(model(Killer, W)).
