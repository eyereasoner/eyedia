% The Digital Omnibus: the same facts under two rulebooks. On 19 November 2025
% the European Commission proposed the Digital Omnibus (procedure
% 2025/0360(COD)), which would amend the GDPR among other laws. It is a
% proposal under negotiation, not law. This program takes two areas it would
% change, decides a set of cases under the rules in force and under the
% proposal, cites the provision behind every outcome, and lists what the
% proposal would change.
%
% Device access, such as cookies. In force: the ePrivacy Directive, Art. 5(3),
% asks for consent unless the access is for transmitting a communication or
% strictly necessary for a service the user explicitly requested. Proposed:
% a new Art. 88a GDPR adds exceptions, among them aggregated audience
% measurement by a controller solely for its own use (88a(3)(c)); forbids
% asking again for six months after a refusal (88a(4)(c), taken here as 183
% days); and Art. 88b makes automated browser signals binding, except for
% media service providers (88b(3)).
%
% Data breaches. In force: Art. 33 GDPR has the supervisory authority told
% within 72 hours unless a breach is unlikely to result in a risk. Proposed:
% only a breach likely to result in a high risk is notified, within 96 hours,
% through a single entry point. Telling the people affected (Art. 34) is
% unchanged. The risk level of a breach is the controller's own assessment,
% given here as input.

regime(in_force).
regime(omnibus_proposal).

% The sites, and the device accesses they make on a visit.
site(shop, media_service(no)).
site(news, media_service(yes)).
access(cart, purpose(requested_service), aggregated(no), own_use(yes)).
access(stats, purpose(audience_measurement), aggregated(yes), own_use(yes)).
access(vendor_stats, purpose(audience_measurement), aggregated(yes), own_use(no)).
access(ads, purpose(advertising), aggregated(no), own_use(no)).

% Each visit: the site, the access it wants, and what the visitor did before.
visit(v1, shop, cart, first_visit).
visit(v2, shop, stats, first_visit).
visit(v3, shop, vendor_stats, first_visit).
visit(v4, shop, ads, browser_signal(refuse)).
visit(v5, news, ads, browser_signal(refuse)).
visit(v6, shop, ads, refused(days_ago(60))).
visit(v7, shop, ads, refused(days_ago(200))).

% Each breach and the controller's assessment of its risk.
breach(b1, 'encrypted laptop lost, key safe', risk(unlikely)).
breach(b2, 'customer e-mail addresses exposed', risk(some)).
breach(b3, 'patient records exposed', risk(high)).

% What kind of access it is. Measurement only counts as the controller's own
% when the information is aggregated and kept for its own use.
kind(A, requested_service) :- access(A, purpose(requested_service), _, _).
kind(A, own_audience_measurement) :- access(A, purpose(audience_measurement), aggregated(yes), own_use(yes)).
kind(A, shared_measurement) :- access(A, purpose(audience_measurement), _, own_use(no)).
kind(A, advertising) :- access(A, purpose(advertising), _, _).

% Whether a kind of access needs consent, and on which provision.
consent(in_force, requested_service, not_needed, 'ePrivacy Art. 5(3)').
consent(in_force, own_audience_measurement, needed, 'ePrivacy Art. 5(3)').
consent(in_force, shared_measurement, needed, 'ePrivacy Art. 5(3)').
consent(in_force, advertising, needed, 'ePrivacy Art. 5(3)').
consent(omnibus_proposal, requested_service, not_needed, 'GDPR Art. 88a(3)(b)').
consent(omnibus_proposal, own_audience_measurement, not_needed, 'GDPR Art. 88a(3)(c)').
consent(omnibus_proposal, shared_measurement, needed, 'GDPR Art. 88a(1)').
consent(omnibus_proposal, advertising, needed, 'GDPR Art. 88a(1)').

% Where consent is needed: may the site ask, given what the visitor did?
ask(in_force, _, _, ask_for_consent, 'ePrivacy Art. 5(3)').
ask(omnibus_proposal, _, first_visit, ask_for_consent, 'GDPR Art. 88a(1)').
ask(omnibus_proposal, media_service(no), browser_signal(refuse), refused_by_signal, 'GDPR Art. 88b(1)-(2)').
ask(omnibus_proposal, media_service(yes), browser_signal(refuse), ask_for_consent, 'GDPR Art. 88b(3)').
ask(omnibus_proposal, _, refused(days_ago(D)), do_not_ask_again, 'GDPR Art. 88a(4)(c)') :- D < 183.
ask(omnibus_proposal, _, refused(days_ago(D)), ask_for_consent, 'GDPR Art. 88a(4)(c)') :- D >= 183.

% Who must be told of a breach, and on which provisions.
authority(in_force, risk(unlikely), none, 'GDPR Art. 33(1)').
authority(in_force, risk(some), within_hours(72), 'GDPR Art. 33(1)').
authority(in_force, risk(high), within_hours(72), 'GDPR Art. 33(1)').
authority(omnibus_proposal, risk(unlikely), none, 'GDPR Art. 33(1) as amended').
authority(omnibus_proposal, risk(some), none, 'GDPR Art. 33(1) as amended').
authority(omnibus_proposal, risk(high), within_hours_via_single_entry_point(96), 'GDPR Art. 33(1) as amended').
people(_, risk(unlikely), none, 'GDPR Art. 34(1)').
people(_, risk(some), none, 'GDPR Art. 34(1)').
people(_, risk(high), without_undue_delay, 'GDPR Art. 34(1)').

% The outcome of each visit and each breach under each regime, with its basis.
outcome(R, V, no_consent_needed, [P]) :-
    visit(V, _, A, _), kind(A, K), consent(R, K, not_needed, P).
outcome(R, V, Decision, Basis) :-
    visit(V, Site, A, Before), site(Site, Media), kind(A, K),
    consent(R, K, needed, P), ask(R, Media, Before, Decision, Q), cite(P, Q, Basis).
outcome(R, B, notify(authority(When), people(How)), [P, Q]) :-
    breach(B, _, Risk), authority(R, Risk, When, P), people(R, Risk, How, Q).

% A provision both steps rest on is cited once.
cite(P, P, [P]).
cite(P, Q, [P, Q]) :- P \== Q.

decision(R, Case, Outcome, basis(Provisions)) :+ regime(R), outcome(R, Case, Outcome, Provisions).
% What the proposal would change, case by case.
changed(Case, from(Old), to(New), because(Basis)) :+
    decision(in_force, Case, Old, _), decision(omnibus_proposal, Case, New, basis(Basis)), Old \== New.
