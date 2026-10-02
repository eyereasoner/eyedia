% The monkey and bananas: a monkey, a box and some bananas hanging out of reach
% are in a room with three locations. Find every plan of up to five moves that
% ends with the monkey holding the bananas. A state is
% [Bananas, Monkey, Box, OnBox, HasBananas].
% See https://www.cs.toronto.edu/~hector/PublicTCSlides.pdf
reaches_goal(Moves) :- initial_state(I), goal_state(G), reachable(I, Moves, G).

reachable(S, [], S).
reachable(S1, [M|Rest], S3) :- legal_move(S1, M, S2), reachable(S2, Rest, S3).

initial_state([loc1, loc2, loc3, n, n]).
goal_state([_, _, _, _, y]).

legal_move([B, M, M, n, H], climb_on, [B, M, M, y, H]).
legal_move([B, M, M, y, H], climb_off, [B, M, M, n, H]).
legal_move([B, B, B, y, n], grab, [B, B, B, y, y]).
legal_move([B, M, M, n, H], push(X), [B, X, X, n, H]) :- location(X), X \= M.
legal_move([B, M, L, n, H], go(X), [B, X, L, n, H]) :- location(X), X \= M.

location(loc1).
location(loc2).
location(loc3).

% Plans are tried shortest first: a plan of a given length is a list of that
% many moves still to be chosen.
moves(0, []).
moves(N, [_|Rest]) :- N > 0, M is N-1, moves(M, Rest).
in_range(Low, High, Low) :- Low =< High.
in_range(Low, High, N) :- Low < High, Next is Low+1, in_range(Next, High, N).

plan(Moves) :+ in_range(1, 5, N), moves(N, Moves), reaches_goal(Moves).
