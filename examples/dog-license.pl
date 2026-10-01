% Count owned dogs before applying a licensing threshold.
owns(alice, dog1).
owns(alice, dog2).
owns(alice, dog3).
owns(alice, dog4).
owns(alice, dog5).
owns(bob, dog6).
owns(bob, dog7).
owner(alice).
owner(bob).
length([], 0).
length([_|Xs], N) :- length(Xs, Before), N is Before+1.
dog_count(Owner, N) :+ owner(Owner), findall(Dog, owns(Owner, Dog), Dogs), length(Dogs, N).
requires(Owner, dog_license) :+ dog_count(Owner, N), N > 4.
