% A forward body invokes
% a backward definition that tests an arithmetic primitive.
more_interesting(X, Y) :- X > Y.
indeed_more_interesting(5, 3) :+ more_interesting(5, 3).
