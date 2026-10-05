% An ODRL policy evaluated against DPV process descriptions. A hospital offers
% lab results, special-category personal data, to a research consortium:
% members may use them for research and development under given consent, with
% pseudonymisation, until the end of 2026, and must delete them within 90 days.
% Sharing for marketing is prohibited, and so is any use by one member. Each
% access request is a DPV process; the program decides each request, gives
% the duties of a permitted one, and says why a refused one is refused. The
% policy resolves a conflict between a permission and a prohibition with the
% ODRL strategy odrl:prohibit. Data is written as triples t(Subject,
% Predicate, Object) with prefixed names; dates are integers YYYYMMDD.

% A small excerpt of the DPV purpose taxonomy.
t('dpv:AcademicResearch', 'skos:broader', 'dpv:ResearchAndDevelopment').
t('dpv:CommercialResearch', 'skos:broader', 'dpv:ResearchAndDevelopment').
t('dpv:Advertising', 'skos:broader', 'dpv:Marketing').
t('dpv:PersonalisedAdvertising', 'skos:broader', 'dpv:Advertising').

% Parties and data.
t('ex:partnerBE', 'odrl:partOf', 'ex:consortium').
t('ex:partnerUS', 'odrl:partOf', 'ex:consortium').
t('ex:labResults', 'rdf:type', 'dpv:SpecialCategoryPersonalData').

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
process('ex:r1', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r2', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:PersonalisedAdvertising', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r3', 'ex:partnerBE', 'dpv:Share', 'ex:labResults', 'dpv:Advertising', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
process('ex:r4', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:CommercialResearch', 'dpv:ConsentWithdrawn', 'dpv:Pseudonymisation', 20261115).
process('ex:r5', 'ex:partnerBE', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:ConsentGiven', 'dpv:Encryption', 20270301).
process('ex:r6', 'ex:partnerUS', 'dpv:Use', 'ex:labResults', 'dpv:AcademicResearch', 'dpv:ConsentGiven', 'dpv:Pseudonymisation', 20261115).
t(P, 'rdf:type', 'dpv:Process') :- process(P, _, _, _, _, _, _, _).
t(P, 'ex:requestedBy', Who) :- process(P, Who, _, _, _, _, _, _).
t(P, 'dpv:hasProcessing', X) :- process(P, _, X, _, _, _, _, _).
t(P, 'dpv:hasPersonalData', X) :- process(P, _, _, X, _, _, _, _).
t(P, 'dpv:hasPurpose', X) :- process(P, _, _, _, X, _, _, _).
t(P, 'dpv:hasLegalBasis', 'dpv:Consent') :- process(P, _, _, _, _, _, _, _).
t(P, 'dpv:hasConsentStatus', X) :- process(P, _, _, _, _, X, _, _).
t(P, 'dpv:hasTechnicalMeasure', X) :- process(P, _, _, _, _, _, X, _).
t(P, 'ex:requestDate', X) :- process(P, _, _, _, _, _, _, X).

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
holds('odrl:lt', V, Limit) :- V < Limit.
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
applies(P, Rule) :- addresses(P, Rule), findall(Why, unmet(P, Rule, Why), []).
permitted(P, Rule) :- t('ex:policy', 'odrl:permission', Rule), applies(P, Rule).
prohibited(P, Rule) :- t('ex:policy', 'odrl:prohibition', Rule), applies(P, Rule).

% With odrl:prohibit, an applying prohibition wins over an applying permission.
decision(P, permit(Rule)) :+
    t(P, 'rdf:type', 'dpv:Process'), permitted(P, Rule), findall(R, prohibited(P, R), []).
decision(P, deny(prohibited_by(Rule))) :+
    t(P, 'rdf:type', 'dpv:Process'), prohibited(P, Rule).
decision(P, deny(not_permitted(Reasons))) :+
    t(P, 'rdf:type', 'dpv:Process'), findall(R, permitted(P, R), []), findall(R, prohibited(P, R), []),
    findall(Why, (t('ex:policy', 'odrl:permission', Rule), unmet(P, Rule, Why)), Reasons).
conflict(P, resolved_by('odrl:prohibit', Prohibition, overrides(Permission))) :+
    t('ex:policy', 'odrl:conflict', 'odrl:prohibit'), t(P, 'rdf:type', 'dpv:Process'),
    permitted(P, Permission), prohibited(P, Prohibition).
duty(P, Action, within_days(Days)) :+
    decision(P, permit(Rule)), t(Rule, 'odrl:duty', Duty), t(Duty, 'odrl:action', Action), t(Duty, 'ex:withinDays', Days).
