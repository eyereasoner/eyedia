% Package holidays under two rulebooks. A tour operator's cancellation terms,
% written as an ODRL offer, meet the EU Package Travel Directive in two
% versions: Directive (EU) 2015/2302 as in force, and its revision, approved
% by the European Parliament on 12 March 2026 and then adopted by the Council.
% The revision applies after transposition: Member States have 28 months to
% transpose it and 6 more months to apply it. Each planned cancellation is
% decided under both versions, every outcome cites its basis, and the
% program lists what the revision would change.
%
% In force: a traveller may cancel before departure, paying the organiser's
% termination fee (Art. 12(1)); without a fee when unavoidable and
% extraordinary circumstances at the destination or its immediate vicinity
% significantly affect the package (Art. 12(2)); refunds are due within 14
% days (Art. 12(4)). The 2015 Directive has no rules on vouchers.
% Revision: such circumstances at the point of departure count too; vouchers
% are optional for the traveller, worth at least the refund, valid for at
% most 12 months, and refunded when unused; complaints are acknowledged within
% 7 days and answered with reasons within 60 days.
%
% Sources: https://eur-lex.europa.eu/eli/dir/2015/2302/oj/eng
% https://www.europarl.europa.eu/news/en/press-room/20260306IPR37536/package-travel-parliament-greenlights-new-rules-to-protect-holidaymakers
% https://www.w3.org/TR/odrl-model/
%
% Scope: whether circumstances are unavoidable and extraordinary and
% significantly affect the package is assessed in advance and given as input.
% Whether the operator's fee scale is reasonable and justifiable, as Art. 12(1)
% requires, is not assessed. National rules, the 2015 Directive's other
% articles and the revision's further changes are outside this model.
%
% Reading guide:
%   1. the operator's terms, as triples t(Subject, Predicate, Object);
%   2. the bookings and the cancellation requests;
%   3. gate 1, the terms: policy_result/2 permits a cancellation or refuses
%      it, with every unmet condition;
%   4. gate 2, the directive: free_cancellation/4 and settle/6, one row per
%      version;
%   5. assessment/4 combines both gates per version, with the basis cited;
%   6. complaints are planned per version with complaint_plan/4;
%   7. changed/3 lists every outcome the revision would change.

regime(directive_2015).
regime(revised_2026).

% The operator's terms, as an ODRL offer with a local profile: the action
% ex:cancel, the left operands ex:requestedBy and ex:daysBeforeDeparture,
% and a fee scale for the compensation duty.
t('ex:terms', 'rdf:type', 'odrl:Offer').
t('ex:terms', 'odrl:assigner', 'ex:sunTrips').
t('ex:terms', 'odrl:permission', 'ex:cancellation').
t('ex:cancellation', 'odrl:action', 'ex:cancel').
t('ex:cancellation', 'odrl:duty', 'ex:fee').
t('ex:fee', 'odrl:action', 'odrl:compensate').
conditions('ex:cancellation', ['ex:byLeadTraveller', 'ex:beforeDeparture']).
% The fee, as a share of the price, by the number of days left.
fee_band(60, 999, 25).
fee_band(30, 59, 50).
fee_band(1, 29, 100).

% Bookings: lead traveller and price in euro.
booking(bk1, lead(anna), price(2400)).
booking(bk2, lead(ben), price(1800)).
booking(bk3, lead(chloe), price(1500)).
booking(bk4, lead(david), price(2100)).
booking(bk5, lead(emma), price(1200)).
booking(bk6, lead(farid), price(1600)).
booking(bk7, lead(gina), price(900)).
booking(bk8, lead(ivy), price(1300)).

% Cancellation requests: booking, who asks, days before departure, what
% happened, and whether a voucher is offered and how the traveller answers.
request(c1, bk1, by(anna), days(90), circumstances(none), voucher(not_offered)).
request(c2, bk2, by(ben), days(20), circumstances(none), voucher(not_offered)).
request(c3, bk3, by(chloe), days(10), circumstances(at(destination, hurricane)), voucher(not_offered)).
request(c4, bk4, by(david), days(5), circumstances(at(departure, airport_closed_by_floods)), voucher(not_offered)).
request(c5, bk5, by(emma), days(12), circumstances(at(destination, hurricane)), voucher(offered(refused))).
request(c6, bk6, by(farid), days(12), circumstances(at(destination, hurricane)), voucher(offered(accepted))).
request(c7, bk7, by(gina), days(-2), circumstances(none), voucher(not_offered)).
request(c8, bk8, by(hugo), days(40), circumstances(none), voucher(not_offered)).

% Gate 1: each condition of the terms is met or unmet, with the reason.
check(C, 'ex:byLeadTraveller', met) :- request(C, B, by(X), _, _, _), booking(B, lead(X), _).
check(C, 'ex:byLeadTraveller', unmet(requested_by(X), lead_traveller(L))) :-
    request(C, B, by(X), _, _, _), booking(B, lead(L), _), X \== L.
check(C, 'ex:beforeDeparture', met) :- request(C, _, _, days(D), _, _), D > 0.
check(C, 'ex:beforeDeparture', unmet(days_before_departure(D))) :- request(C, _, _, days(D), _, _), D =< 0.
% The unmet conditions, in the order the terms list them.
unmet(_, [], []).
unmet(C, [K|Ks], Reasons) :- check(C, K, met), unmet(C, Ks, Reasons).
unmet(C, [K|Ks], [Why|Reasons]) :- check(C, K, Why), Why \== met, unmet(C, Ks, Reasons).
policy_result(C, permit) :- request(C, _, _, _, _, _), conditions('ex:cancellation', Ks), unmet(C, Ks, []).
policy_result(C, refuse(Reasons)) :-
    request(C, _, _, _, _, _), conditions('ex:cancellation', Ks), unmet(C, Ks, Reasons), Reasons \== [].

% Gate 2: whether the circumstances make the cancellation free of charge.
free_cancellation(directive_2015, none, no, 'PTD Art. 12(1)').
free_cancellation(directive_2015, at(destination, _), yes, 'PTD Art. 12(2)').
free_cancellation(directive_2015, at(departure, _), no, 'PTD Art. 12(1)').
free_cancellation(revised_2026, none, no, 'PTD Art. 12(1)').
free_cancellation(revised_2026, at(destination, _), yes, 'revised PTD: destination').
free_cancellation(revised_2026, at(departure, _), yes, 'revised PTD: point of departure').

% How the money is settled: the operator's fee, or a refund or voucher.
settle(_, no, P, D, _, pay_fee(percent(Pct), fee(F), refund(Back), within_days(14))) :-
    fee_band(Min, Max, Pct), Min =< D, D =< Max, F is P * Pct // 100, Back is P - F.
settle(_, yes, P, _, not_offered, refund(P, within_days(14))).
settle(_, yes, P, _, offered(refused), refund(P, within_days(14))).
settle(directive_2015, yes, P, _, offered(accepted), voucher(value(P), terms(as_agreed))).
settle(revised_2026, yes, P, _, offered(accepted), voucher(value(P), valid_months(12), unused_value_refunded)).
% The provision behind the way the money is settled.
money_basis(_, no, _, 'PTD Art. 12(4)').
money_basis(_, yes, not_offered, 'PTD Art. 12(4)').
money_basis(directive_2015, yes, offered(refused), 'PTD Art. 12(4)').
money_basis(directive_2015, yes, offered(accepted), 'PTD 2015: no voucher rules').
money_basis(revised_2026, yes, offered(_), 'revised PTD: vouchers').

% A refusal by the terms takes precedence; a permitted cancellation is settled
% under the directive.
assessment(R, C, refused_by_terms(Reasons), basis(['ex:terms'])) :+
    regime(R), policy_result(C, refuse(Reasons)).
assessment(R, C, Outcome, basis(['ex:terms', Free, Money])) :+
    regime(R), policy_result(C, permit),
    request(C, B, _, days(D), circumstances(What), voucher(V)), booking(B, _, price(P)),
    free_cancellation(R, What, F, Free), settle(R, F, P, D, V, Outcome), money_basis(R, F, V, Money).

% Complaints are a separate duty, whatever happens to a booking.
complaint(k1, 'pool closed for the whole stay').
complaint(k2, 'refund not received').
complaint_plan(directive_2015, K, deadlines(set_by_national_law), basis(['PTD 2015: no complaint deadlines'])) :+
    complaint(K, _).
complaint_plan(revised_2026, K, deadlines(acknowledge(within_days(7)), reasoned_reply(within_days(60))), basis(['revised PTD: complaints'])) :+
    complaint(K, _).

% Compare final outcomes, rather than provision labels.
changed(cancellation(C), from(Old), to(New)) :+
    assessment(directive_2015, C, Old, _), assessment(revised_2026, C, New, _), Old \== New.
changed(complaint(K), from(Old), to(New)) :+
    complaint_plan(directive_2015, K, Old, _), complaint_plan(revised_2026, K, New, _), Old \== New.
