% A trajectory ends at 1; parity chooses the next recursive step.
trajectory(1, [1]).
trajectory(N, [N|Rest]) :- N > 1, 0 =:= N mod 2, Next is N//2, trajectory(Next, Rest).
trajectory(N, [N|Rest]) :- N > 1, 1 =:= N mod 2, Next is 3*N+1, trajectory(Next, Rest).
?- trajectory(6, Values).
