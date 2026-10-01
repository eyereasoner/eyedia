% Solve a small 4x4 Sudoku using only finite choices and structural constraints.
digit(1).
digit(2).
digit(3).
digit(4).
distinct(A,B,C,D) :- A \= B, A \= C, A \= D, B \= C, B \= D, C \= D.
row(A,B,C,D) :- digit(A), digit(B), A \= B, digit(C), A \= C, B \= C, digit(D), A \= D, B \= D, C \= D.
grid([A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P]) :- row(A,B,C,D), row(E,F,G,H), distinct(A,B,E,F), distinct(C,D,G,H), row(I,J,K,L), row(M,N,O,P), distinct(I,J,M,N), distinct(K,L,O,P), distinct(A,E,I,M), distinct(B,F,J,N), distinct(C,G,K,O), distinct(D,H,L,P).
?- grid([1,B,C,4,E,4,1,H,2,J,4,L,M,3,O,1]).
