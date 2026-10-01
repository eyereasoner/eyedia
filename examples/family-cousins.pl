% Cousins occupy the same generation in distinct family branches.
parent(adam, bob).
parent(adam, carol).
parent(bob, dave).
parent(bob, eve).
parent(carol, frank).
parent(carol, grace).
parent(dave, heidi).
parent(eve, ivan).
parent(frank, judy).
generation(adam, 0).
branch(dave, b).
branch(eve, b).
branch(frank, c).
branch(grace, c).
generation(Child, Next) :+ parent(Parent, Child), generation(Parent, N), Next is N+1.
branch(Child, Branch) :+ parent(Parent, Child), branch(Parent, Branch).
cousin(X, Y) :+ generation(X, N), generation(Y, N), branch(X, A), branch(Y, B), A \= B.
true :+ cousin(X, Y).
