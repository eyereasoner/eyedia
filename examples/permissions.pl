% Establish candidate permissions, then apply closed-world exclusions.
role(alice, editor).
role(bob, viewer).
role(carol, editor).
permits(editor, read).
permits(editor, write).
permits(viewer, read).
suspended(carol).
candidate(User, Action) :+ role(User, Role), permits(Role, Action).
allowed(User, Action) :+ candidate(User, Action), \+ suspended(User).
true :+ allowed(User, Action).
