% Quantum teleportation using discrete quantum computing
%
% See https://arxiv.org/pdf/1101.3764.pdf and https://arxiv.org/pdf/1010.2929.pdf
%
% Discrete quantum theory replaces the complex numbers of quantum mechanics by
% a finite field, here the field with two elements, and keeps superposition,
% interference and entanglement. A state is the set of basis values with
% amplitude 1, an operation is a relation between basis values, and amplitudes
% are path counts modulo 2: alternatives that reach the same answer an even
% number of times cancel out.
%
% Alice holds a qubit in some state and one half of the entangled pair |R).
% She measures her two qubits in the basis Bob decodes with in superdense
% coding, and sends him the outcome: two classical bits. Bob applies the
% inverse of that basis relation to his half of the pair and holds Alice's
% state, though neither of them ever learned it.

% The three nonzero one-qubit states: |0), |1) and |0) + |1)
state(zero, false).
state(one, true).
state(plus, false).
state(plus, true).

name(zero).
name(one).
name(plus).

qubit(false).
qubit(true).

% |R) = |0, 0) + |1, 1)
r(false, false).
r(true, true).

% ID |0) = |0)
id(false, false).
% ID |1) = |1)
id(true, true).

% G |0) = |1)
g(false, true).
% G |1) = |0)
g(true, false).

% K |0) = |0)
k(false, false).
% K |1) = |0) + |1)
k(true, false).
k(true, true).

% KG
kg(X, Y) :-
    g(X, Z),
    k(Z, Y).

% GK
gk(X, Y) :-
    k(X, Z),
    g(Z, Y).

% Alice's measurement: outcome M projects her qubit A and her half X of the
% pair onto one of four two-qubit states.
alice(0, [A, X]) :-
    gk(A, X).
alice(1, [A, X]) :-
    k(A, X).
alice(2, [A, X]) :-
    g(A, X).
alice(3, [A, X]) :-
    id(A, X).

% Bob's correction for outcome M undoes Alice's basis relation.
bob(0, Y, Z) :-
    kg(Y, Z).
bob(1, Y, Z) :-
    k(Y, Z).
bob(2, Y, Z) :-
    g(Y, Z).
bob(3, Y, Z) :-
    id(Y, Z).

outcome(0).
outcome(1).
outcome(2).
outcome(3).

% One way for Alice's state S to end as Bob's basis value Z after outcome M.
path(S, M, Z, [A, X, Y]) :-
    state(S, A),
    r(X, Y),
    alice(M, [A, X]),
    bob(M, Y, Z).

odd([_]).
odd([_, _|T]) :- odd(T).

% Bob's qubit has amplitude 1 on Z when an odd number of ways lead there.
received(S, M, Z) :-
    qubit(Z),
    findall(Path, path(S, M, Z, Path), Paths),
    odd(Paths).

% What Bob holds after each outcome, for each state Alice could send.
teleported(S, M, Received) :+
    name(S),
    outcome(M),
    findall(Z, received(S, M, Z), Received).

% Bob must hold exactly the state Alice sent, whatever the outcome.
sent(S, Sent) :-
    findall(A, state(S, A), Sent).
false :+
    teleported(S, _, Received),
    sent(S, Sent),
    Received \== Sent.

% query
true :+ teleported(_, _, _).
