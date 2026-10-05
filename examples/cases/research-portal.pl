% Expected outcomes for research-portal.pl, taken from the sources rather than
% from the program: the hospital's ODRL policy, the ePrivacy Directive, the
% GDPR and the Commission's Digital Omnibus proposal, COM(2025) 837. In
% practice a domain expert writes these, without reading the program; the
% program then has to reproduce them. Run with the program:
%   eyedia examples/research-portal.pl examples/cases/research-portal.pl
% Each case_check/3 is pass, or fail with what was expected and what came out.

% ePrivacy Art. 5(3): the portal's own statistics need device consent today.
expected(in_force, 'ex:r1', await_device_consent('ex:research'), 'ePrivacy Art. 5(3)').
% Proposal Art. 88a(3)(c): aggregated audience measurement for own use needs none.
expected(omnibus_proposal, 'ex:r1', permit('ex:research'), 'GDPR Art. 88a(3)(c) as proposed').
% Policy: research requires given consent, whatever the device rules say.
expected(omnibus_proposal, 'ex:r4', deny_policy(not_permitted([unmet('ex:consentGiven', 'ex:consentStatus', 'dpv:ConsentWithdrawn', 'odrl:eq', 'dpv:ConsentGiven')])), 'policy: consent given').
% Policy: no use by the US partner; the prohibition wins.
expected(in_force, 'ex:r6', deny_policy(prohibited_by('ex:noTransferUS')), 'policy: odrl:prohibit').
% Policy: no passing on for marketing.
expected(in_force, 'ex:r3', deny_policy(prohibited_by('ex:noMarketing')), 'policy: no marketing').
% Policy: sharing for research is not marketing, but nothing permits it.
expected(in_force, 'ex:r11', deny_policy(no_matching_permission), 'policy: permissions and prohibitions').
% Proposal Art. 88b: a browser's automated refusal must be respected.
expected(omnibus_proposal, 'ex:r7', deny_device(refused_by_signal), 'GDPR Art. 88b as proposed').
% Proposal Art. 88a(4)(c): no new request within six months of a refusal ...
expected(omnibus_proposal, 'ex:r8', deny_device(do_not_ask_again), 'GDPR Art. 88a(4)(c) as proposed').
% ... and after six months the portal may ask again.
expected(omnibus_proposal, 'ex:r9', await_device_consent('ex:research'), 'GDPR Art. 88a(4)(c) as proposed').
% GDPR Art. 33(1): a breach with some risk goes to the authority within 72 hours.
expected_breach(in_force, b2, notify(authority(within_hours(72)), people(none)), 'GDPR Art. 33(1)').
% Proposal: only high-risk breaches, within 96 hours, via the single entry point.
expected_breach(omnibus_proposal, b2, notify(authority(none), people(none)), 'GDPR Art. 33(1) as proposed').
expected_breach(omnibus_proposal, b3, notify(authority(within_hours_via_single_entry_point(96)), people(without_undue_delay)), 'GDPR Arts. 33(1) as proposed, 34(1)').

case_check(R, P, pass) :+ expected(R, P, Outcome, _), assessment(R, P, Outcome, _).
case_check(R, P, fail(expected(Outcome), got(Actual))) :+
    expected(R, P, Outcome, _), assessment(R, P, Actual, _), Actual \== Outcome.
case_check(R, P, fail(expected(Outcome), got(nothing))) :+
    expected(R, P, Outcome, _), findall(A, assessment(R, P, A, _), []).
case_check(R, B, pass) :+ expected_breach(R, B, Plan, _), breach_plan(R, B, Plan, _, _).
case_check(R, B, fail(expected(Plan), got(Actual))) :+
    expected_breach(R, B, Plan, _), breach_plan(R, B, Actual, _, _), Actual \== Plan.
true :+ case_check(R, Case, Result).
