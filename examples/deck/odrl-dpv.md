# ODRL and DPV

*A hospital's data-sharing policy, applied to six requests, with reasons.*

[odrl-dpv.pl](https://github.com/eyereasoner/eyedia/blob/main/examples/odrl-dpv.pl) · [output](https://github.com/eyereasoner/eyedia/blob/main/examples/output/odrl-dpv.pl) · [proof](https://github.com/eyereasoner/eyedia/blob/main/examples/proof/odrl-dpv.pl) · [check](https://github.com/eyereasoner/eyedia/blob/main/examples/check/odrl-dpv.pl) · [try it in the playground](https://eyereasoner.github.io/eyedia/playground/#example=odrl-dpv)

---

## The question

A hospital shares lab results with a research consortium. Lab results are
sensitive health data, so the rules are strict.

Policies like this are increasingly written in machine-readable form:

- **ODRL** (Open Digital Rights Language, a W3C standard) says *who may or
  may not do what with which data, under which conditions, with which duties*.
- **DPV** (Data Privacy Vocabulary) gives shared names for the privacy side:
  purposes like *academic research*, legal bases like *consent*, safeguards
  like *pseudonymisation* (replacing names with codes).

**For each request: allowed or not, and why?**

---

## The policy, in plain words

- **Permission**: consortium members may *use* the lab results, if:
  - the purpose is research and development,
  - the legal basis is consent, and consent was given,
  - the data is pseudonymised,
  - the request is before 1 January 2027.
- **Duty** that comes with it: delete the data within 90 days.
- **Prohibition 1**: no *sharing* for marketing.
- **Prohibition 2**: the US partner may not use the data at all.
- **Conflict rule** (`odrl:prohibit`): if a permission and a prohibition both
  apply, the prohibition wins.

---

## What we tell Eyedia

The policy is written as **triples**, small subject–predicate–object
statements, as ODRL does on the web:

```prolog
t('ex:research', 'odrl:assignee', 'ex:consortium').
t('ex:research', 'odrl:action', 'odrl:use').
t('ex:research', 'odrl:constraint', 'ex:forResearch').
t('ex:research', 'odrl:duty', 'ex:deletion').
t('ex:deletion', 'ex:withinDays', 90).
constraint('ex:forResearch', 'odrl:purpose', 'odrl:isA', 'dpv:ResearchAndDevelopment').
constraint('ex:before2027', 'odrl:dateTime', 'odrl:lt', 20270101).
t('dpv:AcademicResearch', 'skos:broader', 'dpv:ResearchAndDevelopment').
t('dpv:Advertising', 'skos:broader', 'dpv:Marketing').
% …
```

The last two lines are a slice of DPV's purpose hierarchy: academic research
*is a kind of* research and development; advertising *is a kind of* marketing.

---

## The six requests

Each request is a DPV description of a planned data use:

```prolog
process('ex:r1', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
```

| Request | Who | Does what | For | Notable |
| --- | --- | --- | --- | --- |
| r1 | Belgian partner | use | academic research | everything in order |
| r2 | Belgian partner | use | personalised advertising | |
| r3 | Belgian partner | share | advertising | |
| r4 | Belgian partner | use | commercial research | consent withdrawn |
| r5 | Belgian partner | use | academic research | encrypted, not pseudonymised; March 2027 |
| r6 | US partner | use | academic research | |

---

## What Eyedia concludes

```prolog
decision('ex:r1', permit('ex:research')).
duty('ex:r1', 'odrl:delete', within_days(90)).
decision('ex:r2', deny(not_permitted([unmet('ex:forResearch', 'odrl:purpose',
    'dpv:PersonalisedAdvertising', 'odrl:isA', 'dpv:ResearchAndDevelopment')]))).
decision('ex:r3', deny(prohibited_by('ex:noMarketing'))).
decision('ex:r4', deny(not_permitted([unmet('ex:consentGiven', 'ex:consentStatus',
    'dpv:ConsentWithdrawn', 'odrl:eq', 'dpv:ConsentGiven')]))).
decision('ex:r5', deny(not_permitted([unmet('ex:pseudonymised', …),
    unmet('ex:before2027', 'odrl:dateTime', 20270301, 'odrl:lt', 20270101)]))).
decision('ex:r6', deny(prohibited_by('ex:noTransferUS'))).
conflict('ex:r6', resolved_by('odrl:prohibit', 'ex:noTransferUS', overrides('ex:research'))).
```

(Lines reordered and wrapped for reading; the r5 line is shortened.)

---

## Reading the decisions

- **r1 permitted**, with the duty to delete within 90 days.
- **r2 refused**: personalised advertising is not research. The reason names
  the exact condition and the value that failed it.
- **r3 refused** by the marketing prohibition: sharing is distribution, and
  advertising is a kind of marketing.
- **r4 refused**: consent was withdrawn.
- **r5 refused**, listing *both* failures: encryption instead of
  pseudonymisation, and a date after the deadline.
- **r6** is both permitted and prohibited; the conflict rule lets the
  prohibition win, and Eyedia says so explicitly.

---

## Why: the proof in plain words

Take r1:

1. r1 is a request, made by the Belgian partner — *from its description*.
2. The research permission **addresses** r1: the partner is part of the
   consortium, "use" in DPV is "use" in ODRL, and the data is the lab results.
3. The list of unmet conditions for r1 is **empty**, so the permission
   **applies**.
4. The list of prohibitions that apply to r1 is **empty**.
5. So r1 is permitted, and the deletion duty attaches to it.

Steps 3 and 4 are "gather all of them, and there are none" — which brings us
to the next card.

---

## Checked, with obligations

- **78 steps** for 8 answers: 64 verified against the program lines they
  cite.
- **14 steps are taken on trust**, all **`collected`** obligations. Each comes
  from gathering *all* answers to a question (`findall`), such as "every
  unmet condition for r1" (none) or "every unmet condition for r5" (two).
  That such a list is *complete* is recorded as an obligation rather than
  proved.
- The checker tries to refute these lists against the evidence in the proof
  and finds nothing that contradicts them.

Verdict: **checked_with_obligations** — valid, provided those 14 gathered
lists are complete. `--strict-proof` would reject it.

---

## Try it

```sh
node bin/eyedia.js examples/odrl-dpv.pl            # the decisions
node bin/eyedia.js --proof examples/odrl-dpv.pl    # with their proofs
```

Or open it in the [playground](https://eyereasoner.github.io/eyedia/playground/#example=odrl-dpv).
In request r4, change `'dpv:ConsentWithdrawn'` to `'dpv:ConsentGiven'` and run
again: r4 becomes `permit('ex:research')`, with its own 90-day deletion duty.
Commercial research counts as research and development too.

---

## Takeaway

A policy decision you can explain matters as much as the decision itself.
Here every "no" says which rule or which condition caused it, and every
"yes" carries its duties — all backed by a checked proof.
