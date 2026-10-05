% Expected outcomes for package-holiday.pl, taken from the sources rather than
% from the program: the operator's terms, Directive (EU) 2015/2302 and the
% European Parliament's summary of the 2026 revision. In practice a domain
% expert writes these, without reading the program; the program then has to
% reproduce them. Run with the program:
%   eyedia examples/package-holiday.pl examples/cases/package-holiday.pl
% Each case_check/3 is pass, or fail with what was expected and what came out.

% Terms: 90 days ahead the fee is 25 %; Art. 12(1) and (4): the rest within 14 days.
expected(directive_2015, c1, pay_fee(percent(25), fee(600), refund(1800), within_days(14)), 'terms; PTD Art. 12(1), 12(4)').
expected(revised_2026, c1, pay_fee(percent(25), fee(600), refund(1800), within_days(14)), 'terms; PTD Art. 12(1), 12(4)').
% Art. 12(2): circumstances at the destination make cancelling free; 12(4): full refund in 14 days.
expected(directive_2015, c3, refund(1500, within_days(14)), 'PTD Art. 12(2), 12(4)').
expected(revised_2026, c3, refund(1500, within_days(14)), 'revised PTD: destination; Art. 12(4)').
% 2015: only the destination counts, so the terms' fee applies, 100 % at 5 days.
expected(directive_2015, c4, pay_fee(percent(100), fee(2100), refund(0), within_days(14)), 'PTD Art. 12(2): destination only; terms').
% Revision: circumstances at the point of departure count too.
expected(revised_2026, c4, refund(2100, within_days(14)), 'EP 12 March 2026: point of departure').
% Revision: a traveller may refuse a voucher and be refunded instead.
expected(revised_2026, c5, refund(1200, within_days(14)), 'EP 12 March 2026: right to refuse a voucher').
% Revision: vouchers are valid for at most 12 months, unused value refunded.
expected(revised_2026, c6, voucher(value(1600), valid_months(12), unused_value_refunded), 'EP 12 March 2026: vouchers').
% Terms: only the lead traveller may cancel, and only before departure.
expected(directive_2015, c7, refused_by_terms([unmet('ex:beforeDeparture', 'ex:daysBeforeDeparture', -2, 'odrl:gt', 0)]), 'terms: before departure').
expected(revised_2026, c8, refused_by_terms([unmet('ex:byLeadTraveller', 'ex:requesterRole', 'ex:otherPerson', 'odrl:eq', 'ex:leadTraveller')]), 'terms: lead traveller').
% Revision: complaints acknowledged within 7 days, answered within 60.
expected_complaint(revised_2026, k1, deadlines(acknowledge(within_days(7)), reasoned_reply(within_days(60))), 'EP 12 March 2026: complaints').

case_check(R, C, pass) :+ expected(R, C, Outcome, _), assessment(R, C, Outcome, _).
case_check(R, C, fail(expected(Outcome), got(Actual))) :+
    expected(R, C, Outcome, _), assessment(R, C, Actual, _), Actual \== Outcome.
case_check(R, C, fail(expected(Outcome), got(nothing))) :+
    expected(R, C, Outcome, _), findall(A, assessment(R, C, A, _), []).
case_check(R, K, pass) :+ expected_complaint(R, K, Plan, _), complaint_plan(R, K, Plan, _).
case_check(R, K, fail(expected(Plan), got(Actual))) :+
    expected_complaint(R, K, Plan, _), complaint_plan(R, K, Actual, _), Actual \== Plan.
true :+ case_check(R, Case, Result).
