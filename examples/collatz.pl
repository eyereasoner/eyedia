% A trajectory ends at 1; parity chooses the next recursive step.
trajectory(1, [1]).
trajectory(N, [N|Rest]) :- N > 1, 0 =:= N mod 2, Next is N//2, trajectory(Next, Rest).
trajectory(N, [N|Rest]) :- N > 1, 1 =:= N mod 2, Next is 3*N+1, trajectory(Next, Rest).
% A range of starting values, enumerated by ordinary clauses.
in_range(Low, High, Low) :- Low =< High.
in_range(Low, High, N) :- Low < High, Next is Low+1, in_range(Next, High, N).
?- in_range(1, 20, N), trajectory(N, Values).
