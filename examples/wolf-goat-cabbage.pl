% A farmer must ferry a wolf, a goat and a cabbage across a river in a boat
% that holds him and one passenger. Left alone, the wolf eats the goat and the
% goat eats the cabbage. A state lists which bank (w or e) the farmer, wolf,
% goat and cabbage are on. The program shows a safe plan with seven crossings
% exists, and that no plan with fewer does.
solution([e, e, e, e], []).
solution(State, [Move|Rest]) :- move(State, Move, Next), safe(Next), solution(Next, Rest).

move([X, X, Goat, Cabbage], wolf, [Y, Y, Goat, Cabbage]) :- change(X, Y).
move([X, Wolf, X, Cabbage], goat, [Y, Wolf, Y, Cabbage]) :- change(X, Y).
move([X, Wolf, Goat, X], cabbage, [Y, Wolf, Goat, Y]) :- change(X, Y).
move([X, Wolf, Goat, Cabbage], nothing, [Y, Wolf, Goat, Cabbage]) :- change(X, Y).

change(e, w).
change(w, e).

% Safe when the goat is with the farmer, or with neither the wolf nor the cabbage.
safe([Farmer, Wolf, Goat, Cabbage]) :- one_eq(Farmer, Goat, Wolf), one_eq(Farmer, Goat, Cabbage).
one_eq(X, X, _).
one_eq(X, _, X).

% A plan of a given length is a list of that many moves still to be chosen.
moves(0, []).
moves(N, [_|Rest]) :- N > 0, M is N-1, moves(M, Rest).
in_range(Low, High, Low) :- Low =< High.
in_range(Low, High, N) :- Low < High, Next is Low+1, in_range(Next, High, N).

shorter_solution :- in_range(0, 6, N), moves(N, Plan), solution([w, w, w, w], Plan).

wolf_goat_cabbage_verified(7) :- \+ shorter_solution, moves(7, Plan), once(solution([w, w, w, w], Plan)).
shortest_crossing(Plan) :- \+ shorter_solution, moves(7, Plan), solution([w, w, w, w], Plan).

true :+ wolf_goat_cabbage_verified(7).
true :+ shortest_crossing(_).
