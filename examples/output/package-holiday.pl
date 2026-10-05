assessment(directive_2015, c7, refused_by_terms([unmet(days_before_departure(-2))]), basis(['ex:terms'])).
assessment(directive_2015, c8, refused_by_terms([unmet(requested_by(hugo), lead_traveller(ivy))]), basis(['ex:terms'])).
assessment(revised_2026, c7, refused_by_terms([unmet(days_before_departure(-2))]), basis(['ex:terms'])).
assessment(revised_2026, c8, refused_by_terms([unmet(requested_by(hugo), lead_traveller(ivy))]), basis(['ex:terms'])).
assessment(directive_2015, c1, pay_fee(percent(25), fee(600), refund(1800), within_days(14)), basis(['ex:terms', 'PTD Art. 12(1)', 'PTD Art. 12(4)'])).
assessment(directive_2015, c2, pay_fee(percent(100), fee(1800), refund(0), within_days(14)), basis(['ex:terms', 'PTD Art. 12(1)', 'PTD Art. 12(4)'])).
assessment(directive_2015, c3, refund(1500, within_days(14)), basis(['ex:terms', 'PTD Art. 12(2)', 'PTD Art. 12(4)'])).
assessment(directive_2015, c4, pay_fee(percent(100), fee(2100), refund(0), within_days(14)), basis(['ex:terms', 'PTD Art. 12(1)', 'PTD Art. 12(4)'])).
assessment(directive_2015, c5, refund(1200, within_days(14)), basis(['ex:terms', 'PTD Art. 12(2)', 'PTD Art. 12(4)'])).
assessment(directive_2015, c6, voucher(value(1600), terms(as_agreed)), basis(['ex:terms', 'PTD Art. 12(2)', 'PTD 2015: no voucher rules'])).
assessment(revised_2026, c1, pay_fee(percent(25), fee(600), refund(1800), within_days(14)), basis(['ex:terms', 'PTD Art. 12(1)', 'PTD Art. 12(4)'])).
assessment(revised_2026, c2, pay_fee(percent(100), fee(1800), refund(0), within_days(14)), basis(['ex:terms', 'PTD Art. 12(1)', 'PTD Art. 12(4)'])).
assessment(revised_2026, c3, refund(1500, within_days(14)), basis(['ex:terms', 'revised PTD: destination', 'PTD Art. 12(4)'])).
assessment(revised_2026, c4, refund(2100, within_days(14)), basis(['ex:terms', 'revised PTD: point of departure', 'PTD Art. 12(4)'])).
assessment(revised_2026, c5, refund(1200, within_days(14)), basis(['ex:terms', 'revised PTD: destination', 'revised PTD: vouchers'])).
assessment(revised_2026, c6, voucher(value(1600), valid_months(12), unused_value_refunded), basis(['ex:terms', 'revised PTD: destination', 'revised PTD: vouchers'])).
complaint_plan(directive_2015, k1, deadlines(set_by_national_law), basis(['PTD 2015: no complaint deadlines'])).
complaint_plan(directive_2015, k2, deadlines(set_by_national_law), basis(['PTD 2015: no complaint deadlines'])).
complaint_plan(revised_2026, k1, deadlines(acknowledge(within_days(7)), reasoned_reply(within_days(60))), basis(['revised PTD: complaints'])).
complaint_plan(revised_2026, k2, deadlines(acknowledge(within_days(7)), reasoned_reply(within_days(60))), basis(['revised PTD: complaints'])).
changed(cancellation(c4), from(pay_fee(percent(100), fee(2100), refund(0), within_days(14))), to(refund(2100, within_days(14)))).
changed(cancellation(c6), from(voucher(value(1600), terms(as_agreed))), to(voucher(value(1600), valid_months(12), unused_value_refunded))).
changed(complaint(k1), from(deadlines(set_by_national_law)), to(deadlines(acknowledge(within_days(7)), reasoned_reply(within_days(60))))).
changed(complaint(k2), from(deadlines(set_by_national_law)), to(deadlines(acknowledge(within_days(7)), reasoned_reply(within_days(60))))).
