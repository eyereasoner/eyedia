% Research portal: an ODRL/DPV policy meets two digital rulebooks.
% A hospital evaluates each planned research session under the general EU
% baseline and the original Commission Digital Omnibus proposal, COM(2025)
% 837 final (19 November 2025), after the modelled provisions apply.
% Research permission and device consent are independent gates: exempt
% audience measurement never supplies consent to process health records.
% One fixed ODRL/DPV research policy is evaluated alongside each rulebook.
%
% Sources: https://www.w3.org/TR/odrl-model/
% https://www.w3.org/TR/odrl-vocab/
% https://w3id.org/dpv/2.3/dpv/
% https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:52025PC0837
% https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng
% https://eur-lex.europa.eu/eli/dir/2002/58/2009-12-19
%
% Local profile: each process/10 states its data controller and legal basis;
% operands have at most one value, valid YYYYMMDD dates and an acyclic purpose
% taxonomy. Only odrl:prohibit is supported. Device accesses involve personal
% data on a natural person's device; necessity and measurement aggregation/
% own use are assessed inputs. National exceptions and transition dates are
% outside this model. The portal is not a media service provider. Refusals
% concern the same device purpose, with completed calendar months as input.
% Baseline ask_for_consent is a next-step label, never permission to disregard
% a refusal. A deny_device result blocks this planned session with its stated
% tracker; it does not require denying research if that tracker can be removed.
% Deletion is a planned obligation within 90 days of research use; duty
% fulfilment, actual consent collection and legal compliance are not proved.
% Breach risk is supplied, deadlines run from awareness without undue delay
% and where feasible; no Art. 34(3) exception applies to the high-risk case.
% Every breach must be documented, even when notification is not required.
%
% Reading guide. The program runs top to bottom as one decision process:
%   1. the ODRL/DPV research policy, as triples t(Subject, Predicate, Object);
%   2. the planned research uses, as DPV processes;
%   3. gate 1, the policy: policy_result/2 permits a use or refuses it with
%      the reasons;
%   4. gate 2, the device rules: session/3, then the consent/4 and ask/5
%      tables, one row per regime;
%   5. assessment/4 combines both gates per regime, with the basis cited;
%   6. breaches are planned per regime with breach_plan/5;
%   7. changed/3 lists every outcome the proposal would change.

% A small excerpt of the DPV purpose taxonomy.
t('dpv:AcademicResearch', 'skos:broader', 'dpv:ResearchAndDevelopment').
t('dpv:CommercialResearch', 'skos:broader', 'dpv:ResearchAndDevelopment').
t('dpv:Advertising', 'skos:broader', 'dpv:Marketing').
t('dpv:PersonalisedAdvertising', 'skos:broader', 'dpv:Advertising').

% Parties and data.
t('ex:partnerBE', 'odrl:partOf', 'ex:consortium').
t('ex:partnerUS', 'odrl:partOf', 'ex:consortium').
% The lab results are special-category personal data (dpv:SpecialCategoryPersonalData);
% the policy's conditions, not a type triple, carry what that requires here.

% The policy. The left operands ex:legalBasis, ex:consentStatus and
% ex:technicalMeasure belong to a profile that reads them from the process.
t('ex:policy', 'rdf:type', 'odrl:Agreement').
t('ex:policy', 'odrl:assigner', 'ex:hospital').
t('ex:policy', 'odrl:conflict', 'odrl:prohibit').
t('ex:policy', 'odrl:permission', 'ex:research').
t('ex:research', 'odrl:assignee', 'ex:consortium').
t('ex:research', 'odrl:action', 'odrl:use').
t('ex:research', 'odrl:target', 'ex:labResults').
t('ex:research', 'odrl:constraint', 'ex:forResearch').
t('ex:research', 'odrl:constraint', 'ex:underConsent').
t('ex:research', 'odrl:constraint', 'ex:consentGiven').
t('ex:research', 'odrl:constraint', 'ex:pseudonymised').
t('ex:research', 'odrl:constraint', 'ex:before2027').
t('ex:research', 'odrl:duty', 'ex:deletion').
t('ex:deletion', 'odrl:action', 'odrl:delete').
t('ex:deletion', 'ex:withinDays', 90).
t('ex:policy', 'odrl:prohibition', 'ex:noMarketing').
t('ex:noMarketing', 'odrl:assignee', 'ex:consortium').
t('ex:noMarketing', 'odrl:action', 'odrl:distribute').
t('ex:noMarketing', 'odrl:target', 'ex:labResults').
t('ex:noMarketing', 'odrl:constraint', 'ex:forMarketing').
t('ex:policy', 'odrl:prohibition', 'ex:noTransferUS').
t('ex:noTransferUS', 'odrl:assignee', 'ex:partnerUS').
t('ex:noTransferUS', 'odrl:action', 'odrl:use').
t('ex:noTransferUS', 'odrl:target', 'ex:labResults').
constraint('ex:forResearch', 'odrl:purpose', 'odrl:isA', 'dpv:ResearchAndDevelopment').
constraint('ex:underConsent', 'ex:legalBasis', 'odrl:eq', 'dpv:Consent').
constraint('ex:consentGiven', 'ex:consentStatus', 'odrl:eq', 'dpv:ConsentGiven').
constraint('ex:pseudonymised', 'ex:technicalMeasure', 'odrl:eq', 'dpv:Pseudonymisation').
constraint('ex:before2027', 'odrl:dateTime', 'odrl:lt', 20270101).
constraint('ex:forMarketing', 'odrl:purpose', 'odrl:isA', 'dpv:Marketing').

% The requests, as DPV processes.
process('ex:r1', 'ex:hospital', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:Consent', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r2', 'ex:hospital', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:PersonalisedAdvertising', 'dpv:LegitimateInterest', 'dpv:ConsentUnknown', 'dpv:Pseudonymisation', 20261115).
process('ex:r3', 'ex:hospital', 'ex:partnerBE', 'dpv:Share', 'ex:labResults', 'dpv:Advertising', 'dpv:Consent', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r4', 'ex:hospital', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:CommercialResearch', 'dpv:Consent', 'dpv:ConsentWithdrawn', 'dpv:Pseudonymisation', 20261115).
process('ex:r5', 'ex:hospital', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:Consent', 'dpv:ConsentGiven', 'dpv:Encryption', 20270301).
process('ex:r6', 'ex:hospital', 'ex:partnerUS', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:Consent', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r7', 'ex:hospital', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:Consent', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r8', 'ex:hospital', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:Consent', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r9', 'ex:hospital', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:Consent', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r10', 'ex:hospital', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:Consent', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r11', 'ex:hospital', 'ex:partnerBE', 'dpv:Share', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:Consent', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
t(P, 'rdf:type', 'dpv:Process') :- process(P, _, _, _, _, _, _, _, _, _).
t(P, 'dpv:hasDataController', X) :- process(P, X, _, _, _, _, _, _, _, _).
t(P, 'ex:requestedBy', Who) :- process(P, _, Who, _, _, _, _, _, _, _).
t(P, 'dpv:hasProcessing', X) :- process(P, _, _, X, _, _, _, _, _, _).
t(P, 'dpv:hasPersonalData', X) :- process(P, _, _, _, X, _, _, _, _, _).
t(P, 'dpv:hasPurpose', X) :- process(P, _, _, _, _, X, _, _, _, _).
t(P, 'dpv:hasLegalBasis', X) :- process(P, _, _, _, _, _, X, _, _, _).
t(P, 'dpv:hasConsentStatus', X) :- process(P, _, _, _, _, _, _, X, _, _).
t(P, 'dpv:hasTechnicalMeasure', X) :- process(P, _, _, _, _, _, _, _, X, _).
t(P, 'ex:requestDate', X) :- process(P, _, _, _, _, _, _, _, _, X).

% How a DPV processing reads as an ODRL action.
action('dpv:Use', 'odrl:use').
action('dpv:Share', 'odrl:distribute').

% What a left operand is for a given process.
value(P, 'odrl:purpose', V) :- t(P, 'dpv:hasPurpose', V).
value(P, 'ex:legalBasis', V) :- t(P, 'dpv:hasLegalBasis', V).
value(P, 'ex:consentStatus', V) :- t(P, 'dpv:hasConsentStatus', V).
value(P, 'ex:technicalMeasure', V) :- t(P, 'dpv:hasTechnicalMeasure', V).
value(P, 'odrl:dateTime', V) :- t(P, 'ex:requestDate', V).

holds('odrl:isA', V, Class) :- within(V, Class).
holds('odrl:eq', V, V).
holds('odrl:lt', V, Limit) :- integer(V), integer(Limit), V < Limit.
within(Class, Class).
within(Class, Super) :- t(Class, 'skos:broader', Middle), within(Middle, Super).
party(Who, Who).
party(Who, Group) :- t(Who, 'odrl:partOf', Group).

% A rule addresses a process when its assignee, action and target fit; it then
% applies when every one of its constraints is met.
addresses(P, Rule) :-
    t(P, 'ex:requestedBy', Who), t(Rule, 'odrl:assignee', Assignee), party(Who, Assignee),
    t(P, 'dpv:hasProcessing', Processing), action(Processing, Action), t(Rule, 'odrl:action', Action),
    t(P, 'dpv:hasPersonalData', Data), t(Rule, 'odrl:target', Data).
met(P, C) :- constraint(C, Left, Operator, Right), value(P, Left, V), holds(Operator, V, Right).
unmet(P, Rule, unmet(C, Left, V, Operator, Right)) :-
    addresses(P, Rule), t(Rule, 'odrl:constraint', C),
    constraint(C, Left, Operator, Right), value(P, Left, V), \+ met(P, C).
unmet(P, Rule, missing_value(C, Left, Operator, Right)) :-
    addresses(P, Rule), t(Rule, 'odrl:constraint', C),
    constraint(C, Left, Operator, Right), findall(V, value(P, Left, V), []).
unmet(P, Rule, missing_definition(C)) :-
    addresses(P, Rule), t(Rule, 'odrl:constraint', C),
    findall(definition(Left, Operator, Right), constraint(C, Left, Operator, Right), []).
applies(P, Rule) :- addresses(P, Rule), findall(Why, unmet(P, Rule, Why), []).
% A policy governs a process when it is an agreement assigned by the
% process's data controller.
governs(Policy, P) :-
    t(Policy, 'rdf:type', 'odrl:Agreement'), t(Policy, 'odrl:assigner', Controller),
    t(P, 'dpv:hasDataController', Controller).
permitted(P, Rule) :- governs(Policy, P), t(Policy, 'odrl:permission', Rule), applies(P, Rule).
prohibited(P, Rule) :- governs(Policy, P), t(Policy, 'odrl:prohibition', Rule), applies(P, Rule).
candidate(P, Rule) :- governs(Policy, P), t(Policy, 'odrl:permission', Rule), addresses(P, Rule).
policy_ready(P) :- governs(Policy, P), findall(S, t(Policy, 'odrl:conflict', S), ['odrl:prohibit']).

% Policy outcomes are evaluated before considering the device step.
policy_result(P, permit(Rule)) :-
    policy_ready(P), permitted(P, Rule), findall(R, prohibited(P, R), []).
policy_result(P, deny(prohibited_by(Rule))) :- policy_ready(P), prohibited(P, Rule).
policy_result(P, deny(not_permitted(Reasons))) :-
    t(P, 'rdf:type', 'dpv:Process'), policy_ready(P), candidate(P, _),
    findall(R, permitted(P, R), []), findall(R, prohibited(P, R), []),
    findall(Why, (governs(Policy, P), t(Policy, 'odrl:permission', Rule), unmet(P, Rule, Why)), Reasons).
policy_result(P, deny(no_matching_permission)) :-
    t(P, 'rdf:type', 'dpv:Process'), policy_ready(P),
    findall(R, candidate(P, R), []), findall(R, prohibited(P, R), []).
policy_result(P, deny(unsupported_conflict_strategy(Strategies))) :-
    t(P, 'rdf:type', 'dpv:Process'), governs(Policy, P), findall(S, t(Policy, 'odrl:conflict', S), Strategies),
    Strategies \== ['odrl:prohibit'].

% Each research session specifies its device access and the visitor's choice.
session('ex:r1', own_audience_measurement, first_visit).
session('ex:r2', own_audience_measurement, first_visit).
session('ex:r3', advertising, browser_signal(refuse)).
session('ex:r4', own_audience_measurement, first_visit).
session('ex:r5', requested_service, first_visit).
session('ex:r6', own_audience_measurement, first_visit).
session('ex:r7', advertising, browser_signal(refuse)).
session('ex:r8', advertising, refused(completed_months(5))).
session('ex:r9', advertising, refused(completed_months(6))).
session('ex:r10', requested_service, first_visit).
session('ex:r11', requested_service, first_visit).

regime(in_force).
regime(omnibus_proposal).
refusal_pause(months(6)).

% Whether a kind of access needs consent, and on which provision.
consent(in_force, transmission, not_needed, 'ePrivacy Art. 5(3)').
consent(in_force, unaggregated_measurement, needed, 'ePrivacy Art. 5(3)').
consent(in_force, requested_service, not_needed, 'ePrivacy Art. 5(3)').
consent(in_force, own_audience_measurement, needed, 'ePrivacy Art. 5(3)').
consent(in_force, shared_measurement, needed, 'ePrivacy Art. 5(3)').
consent(in_force, advertising, needed, 'ePrivacy Art. 5(3)').
consent(omnibus_proposal, transmission, not_needed, 'GDPR Art. 88a(3)(a)').
consent(omnibus_proposal, unaggregated_measurement, needed, 'GDPR Art. 88a(1)').
consent(omnibus_proposal, requested_service, not_needed, 'GDPR Art. 88a(3)(b)').
consent(omnibus_proposal, own_audience_measurement, not_needed, 'GDPR Art. 88a(3)(c)').
consent(omnibus_proposal, shared_measurement, needed, 'GDPR Art. 88a(1)').
consent(omnibus_proposal, advertising, needed, 'GDPR Art. 88a(1)').

% Where consent is needed: may the site ask, given what the visitor did?
ask(in_force, _, _, ask_for_consent, 'ePrivacy Art. 5(3)').
ask(omnibus_proposal, _, first_visit, ask_for_consent, 'GDPR Art. 88a(1)').
ask(omnibus_proposal, media_service(no), browser_signal(refuse), refused_by_signal, 'GDPR Art. 88b(1)-(2)').
ask(omnibus_proposal, media_service(yes), browser_signal(refuse), ask_for_consent, 'GDPR Art. 88b(3)').
ask(omnibus_proposal, _, refused(completed_months(M)), do_not_ask_again, 'GDPR Art. 88a(4)(c)') :-
    integer(M), M >= 0, refusal_pause(months(Min)), M < Min.
ask(omnibus_proposal, _, refused(completed_months(M)), ask_for_consent, 'GDPR Art. 88a(4)(c)') :-
    integer(M), M >= 0, refusal_pause(months(Min)), M >= Min.

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

% A policy denial takes precedence. A policy permit proceeds to the device gate.
assessment(R, P, deny_policy(Reason), basis(['ex:policy'])) :+
    regime(R), session(P, _, _), policy_result(P, deny(Reason)).
assessment(R, P, permit(Rule), basis(['ex:policy', Provision])) :+
    regime(R), policy_result(P, permit(Rule)), session(P, Kind, _),
    consent(R, Kind, not_needed, Provision).
assessment(R, P, await_device_consent(Rule), basis(Basis)) :+
    regime(R), policy_result(P, permit(Rule)), session(P, Kind, Before),
    consent(R, Kind, needed, Provision), ask(R, media_service(no), Before, ask_for_consent, Next),
    device_basis(Provision, Next, Basis).
assessment(R, P, deny_device(Reason), basis(Basis)) :+
    regime(R), policy_result(P, permit(_)), session(P, Kind, Before),
    consent(R, Kind, needed, Provision), ask(R, media_service(no), Before, Reason, Next),
    Reason \== ask_for_consent, device_basis(Provision, Next, Basis).

device_basis(P, P, ['ex:policy', P]).
device_basis(P, Q, ['ex:policy', P, Q]) :- P \== Q.

policy_conflict(P, resolved_by('odrl:prohibit', Prohibition, overrides(Permission))) :+
    session(P, _, _), policy_ready(P), permitted(P, Permission), prohibited(P, Prohibition).

% Duties attach to final permits, not to requests waiting for device consent.
planned_duty(R, P, Action, within_days(Days)) :+
    assessment(R, P, permit(Rule), _), t(Rule, 'odrl:duty', Duty),
    t(Duty, 'odrl:action', Action), t(Duty, 'ex:withinDays', Days).

% Incidents concern existing portal data, independently of planned requests.
breach(b1, 'encrypted laptop lost, key safe', risk(unlikely)).
breach(b2, 'researcher contact addresses exposed', risk(some)).
breach(b3, 'patient lab records exposed', risk(high)).
breach_plan(R, B, notify(authority(When), people(How)), document_breach, basis([P, Q, 'GDPR Art. 33(5)'])) :+
    regime(R), breach(B, _, Risk), authority(R, Risk, When, P), people(R, Risk, How, Q).

% Compare final session decisions and incident plans, rather than provision labels.
changed(session(P), from(Old), to(New)) :+
    assessment(in_force, P, Old, _), assessment(omnibus_proposal, P, New, _), Old \== New.
changed(breach(B), from(Old), to(New)) :+
    breach_plan(in_force, B, Old, _, _), breach_plan(omnibus_proposal, B, New, _, _), Old \== New.
