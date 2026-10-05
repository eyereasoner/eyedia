# The Digital Omnibus

*One set of facts, two rulebooks: what an EU law proposal would change, case by case, with every answer traced to an article.*

[digital-omnibus.pl](../digital-omnibus.pl) · [output](../output/digital-omnibus.pl) · [proof](../proof/digital-omnibus.pl) · [check](../check/digital-omnibus.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=digital-omnibus)

---

## The question

In November 2025 the European Commission proposed the **Digital Omnibus**
(procedure 2025/0360(COD)): a package that would simplify and amend Europe's
digital laws, the GDPR among them. It is a **proposal under negotiation, not
law**.

A website owner, a regulator or a researcher wants to know: **for my
situation, what would actually change?** And they need to see *which
article* each answer rests on.

---

## Two areas the proposal changes

**Device access, such as cookies.** Today, the ePrivacy Directive (Art. 5(3))
asks for consent unless the access is strictly needed for a service the user
asked for. The proposal moves this into a new **Art. 88a GDPR**: audience
statistics kept by a site *for its own use* no longer need consent; after a
refusal, the site may not ask again for six months; and under **Art. 88b**
a browser's automatic "no" must be respected, except by news and other media.

**Data breaches.** Today the regulator must be told within **72 hours**
unless a breach is unlikely to put people at risk. The proposal: only
**high-risk** breaches, within **96 hours**, through a **single entry point**.
Telling the affected people (Art. 34) stays the same.

---

## What we tell Eyedia

The facts are the cases; the law is a table, one row per rule and regime:

```prolog
visit(v2, shop, stats, first_visit).
access(stats, purpose(audience_measurement), aggregated(yes), own_use(yes)).
breach(b2, 'customer e-mail addresses exposed', risk(some)).

consent(in_force, own_audience_measurement, needed, 'ePrivacy Art. 5(3)').
consent(omnibus_proposal, own_audience_measurement, not_needed, 'GDPR Art. 88a(3)(c)').
authority(in_force, risk(some), within_hours(72), 'GDPR Art. 33(1)').
authority(omnibus_proposal, risk(some), none, 'GDPR Art. 33(1) as amended').
```

Seven website visits and three breaches, decided under both rulebooks.

---

## What Eyedia concludes

Twenty decisions, one per case and regime, each with its legal basis.
Then the part that matters most, **what would change**:

```prolog
changed(v2, from(ask_for_consent), to(no_consent_needed), because(['GDPR Art. 88a(3)(c)'])).
changed(v4, from(ask_for_consent), to(refused_by_signal), because(['GDPR Art. 88a(1)', 'GDPR Art. 88b(1)-(2)'])).
changed(v6, from(ask_for_consent), to(do_not_ask_again), because(['GDPR Art. 88a(1)', 'GDPR Art. 88a(4)(c)'])).
changed(b2, from(notify(authority(within_hours(72)), people(none))), to(notify(authority(none), people(none))), because(...)).
changed(b3, from(notify(authority(within_hours(72)), people(without_undue_delay))), to(notify(authority(within_hours_via_single_entry_point(96)), people(without_undue_delay))), because(...)).
```

The last two lines are shortened here; the full output names the articles.

---

## Reading the changes

- **v2**: the shop's own, aggregated visitor statistics stop needing consent.
- **v4**: the visitor's browser says "no", and the shop must simply respect it.
- **v6**: the visitor refused 60 days ago, so the shop may not ask again yet.
- **b2**: exposed e-mail addresses (some risk) no longer go to the regulator.
- **b3**: exposed patient records (high risk) still do, but within 96 hours,
  through the single entry point; patients are told as before.

Just as telling is what does **not** change: shared statistics (v3) still
need consent, a news site (v5) is exempt from browser signals, and after
200 days (v7) the shop may ask again.

---

## Why: the proof in plain words

Take v2. The proof records each step:

1. Visit v2 is the shop wanting the `stats` access, on a first visit.
2. `stats` measures the audience, is aggregated, and is for the shop's own
   use, so it counts as the shop's *own* audience measurement.
3. Under the rules in force, that kind needs consent: ePrivacy Art. 5(3).
4. Under the proposal, it does not: GDPR Art. 88a(3)(c).
5. The two outcomes differ, so v2 is listed as changed.

Every step names the line of the program it used. Nothing is hidden in code.

---

## Checked, not just claimed

A separate checker read all **112 steps** against the program. Verdict:
**checked**, with **nothing taken on trust**.

That matters here. A compliance answer is only as good as its reasons. This
one comes with a certificate that every conclusion is an instance of a rule
in the table, that no reasoning goes in circles, and that every citation
shown is the one actually used.

---

## Try it

```sh
node bin/eyedia.js examples/digital-omnibus.pl
node bin/eyedia.js --proof examples/digital-omnibus.pl
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=digital-omnibus).

Negotiators may well change the proposal. Model an amendment by editing one
row: change the 183 in the six-month rule to 365, and v7 (refused 200 days
ago) joins the changes as `do_not_ask_again`.

---

## Takeaway

When the rules change, Eyedia can show *exactly* what changes, for whom, and
why, with every answer tied to an article and checked by a machine. That is
what a law in flux needs: comparisons you can verify, not just trust.
