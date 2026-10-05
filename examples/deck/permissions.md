# Permissions

*Who may read and write, and why a suspended editor may not.*

[permissions.pl](../permissions.pl) · [output](../output/permissions.pl) · [proof](../proof/permissions.pl) · [check](../check/permissions.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=permissions)

---

## The question

Many systems give people *roles*: editors may read and write, viewers may
only read. On top of that, someone can be *suspended*, and then they may do
nothing.

Alice and Carol are editors, Bob is a viewer, and Carol is suspended.
**Who is allowed to do what?**

---

## What we tell Eyedia

```prolog
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
```

First work out what each role *would* allow, then remove anyone suspended.
`\+` means "it is not the case that".

---

## What Eyedia concludes

```prolog
allowed(alice, read).
allowed(alice, write).
allowed(bob, read).
```

Carol is a candidate for reading and writing, but she is suspended, so she
gets nothing.

---

## Why: the proof in plain words

For Alice writing:

1. Alice is an editor — *fact 1*.
2. Editors may write — *fact 5*.
3. So Alice is a candidate to write — *rule 8*.
4. Alice is not suspended — *searched, nothing found*.
5. So Alice is allowed to write — *rule 9*.

Step 4 is different in kind: it is not a fact we gave, but the *absence*
of one.

---

## "Not suspended": a claim about absence

Eyedia works under a *closed world*: if the program does not say Alice is
suspended, it takes her to be not suspended. That is what we want here — but
it is a claim about what is *missing* from the data, and a proof cannot point
at something missing.

So the checker does not pretend to prove it. It records it as an
**obligation**.

---

## Checked, not just claimed

- **11** steps are confirmed as instances of the program lines they cite.
- **2** steps are taken on trust as *absent* obligations: "Alice is not
  suspended" and "Bob is not suspended". Eyedia searched everything it knows
  and found nothing.
- The checker looked for evidence against both (a `suspended(alice)` fact,
  say) and found none.

Verdict: **checked_with_obligations**. 13 steps, 2 on trust.

---

## Try it

```sh
node bin/eyedia.js examples/permissions.pl
node bin/eyedia.js --check-proof examples/proof/permissions.pl examples/permissions.pl
```

Delete the line `suspended(carol).` and run again: Carol is now allowed to
read and write, like Alice.

---

## Takeaway

"Allowed unless excluded" decisions rest on what is *not* in the data.
Eyedia makes those absences visible, so you know exactly what you are
trusting when you grant access.
