% A negative balance triggers the integrity fuse; the CLI exits with code 65.
account(alice, 30).
account(bob, -5).
false :+ account(Owner, Balance), Balance < 0.
