age_above(pat_h, years(80)).

clause(1, birth_date(pat_h, date(1944, 8, 21)), true).
clause(2, as_of(date(2026, 10, 1)), true).
clause(3, age_above(var('Person'), var('Duration')), ','(as_of(var('Date')), age_above(var('Person'), var('Duration'), var('Date')))).
clause(4, age_above(var('Person'), years(var('Years')), var('Date')), ','(integer(var('Years')), ','(>=(var('Years'), 0), ','(birth_date(var('Person'), var('Birth')), ','(date_day(var('Birth'), var('Born')), ','(date_day(var('Date'), var('Today')), ','(>=(var('Today'), var('Born')), ','(anniversary(var('Birth'), var('Years'), var('Anniversary')), ','(date_day(var('Anniversary'), var('Threshold')), >(var('Today'), var('Threshold'))))))))))).
clause(7, anniversary(date(var('Y'), var('M'), var('D')), var('Years'), date(var('Year'), var('M'), var('Day'))), ','(is(var('Year'), +(var('Y'), var('Years'))), ','(month_days(var('Year'), var('M'), var('Maximum')), is(var('Day'), min(var('D'), var('Maximum')))))).
clause(8, date_day(date(var('Y'), var('M'), var('D')), var('Ordinal')), ','(integer(var('Y')), ','(integer(var('M')), ','(integer(var('D')), ','(>=(var('Y'), 1), ','(month_days(var('Y'), var('M'), var('Maximum')), ','(>=(var('D'), 1), ','(=<(var('D'), var('Maximum')), ','(month_offset(var('M'), var('Offset')), ','(leap_extra(var('Y'), var('M'), var('Extra')), ','(is(var('Previous'), -(var('Y'), 1)), is(var('Ordinal'), +(+(+(+(-(+(*(365, var('Previous')), //(var('Previous'), 4)), //(var('Previous'), 100)), //(var('Previous'), 400)), var('Offset')), var('Extra')), var('D')))))))))))))).
clause(11, month_days(var('__anon0'), var('M'), var('Days')), ordinary_month(var('M'), var('Days'))).
clause(18, ordinary_month(8, 31), true).
clause(20, ordinary_month(10, 31), true).
clause(24, leap_year(var('Y')), ','('=:='(0, mod(var('Y'), 4)), =\=(0, mod(var('Y'), 100)))).
clause(25, common_year(var('Y')), =\=(0, mod(var('Y'), 4))).
clause(28, leap_extra(var('Y'), var('M'), 1), ','(>(var('M'), 2), leap_year(var('Y')))).
clause(29, leap_extra(var('Y'), var('M'), 0), ','(>(var('M'), 2), common_year(var('Y')))).
clause(37, month_offset(8, 212), true).
clause(39, month_offset(10, 273), true).

step(age_above(pat_h, years(80)), rule(3), '.'(=('Person', pat_h), '.'(=('Duration', years(80)), '.'(=('Date', date(2026, 10, 1)), []))), '.'(as_of(date(2026, 10, 1)), '.'(age_above(pat_h, years(80), date(2026, 10, 1)), []))).
step(as_of(date(2026, 10, 1)), fact(2), [], []).
step(age_above(pat_h, years(80), date(2026, 10, 1)), rule(4), '.'(=('Person', pat_h), '.'(=('Years', 80), '.'(=('Date', date(2026, 10, 1)), '.'(=('Birth', date(1944, 8, 21)), '.'(=('Born', 709899), '.'(=('Today', 739890), '.'(=('Anniversary', date(2024, 8, 21)), '.'(=('Threshold', 739119), [])))))))), '.'(integer(80), '.'(>=(80, 0), '.'(birth_date(pat_h, date(1944, 8, 21)), '.'(date_day(date(1944, 8, 21), 709899), '.'(date_day(date(2026, 10, 1), 739890), '.'(>=(739890, 709899), '.'(anniversary(date(1944, 8, 21), 80, date(2024, 8, 21)), '.'(date_day(date(2024, 8, 21), 739119), '.'(>(739890, 739119), [])))))))))).
step(integer(80), builtin, [], []).
step(>=(80, 0), builtin, [], []).
step(birth_date(pat_h, date(1944, 8, 21)), fact(1), [], []).
step(date_day(date(1944, 8, 21), 709899), rule(8), '.'(=('Y', 1944), '.'(=('M', 8), '.'(=('D', 21), '.'(=('Ordinal', 709899), '.'(=('Maximum', 31), '.'(=('Offset', 212), '.'(=('Extra', 1), '.'(=('Previous', 1943), [])))))))), '.'(integer(1944), '.'(integer(8), '.'(integer(21), '.'(>=(1944, 1), '.'(month_days(1944, 8, 31), '.'(>=(21, 1), '.'(=<(21, 31), '.'(month_offset(8, 212), '.'(leap_extra(1944, 8, 1), '.'(is(1943, -(1944, 1)), '.'(is(709899, +(+(+(+(-(+(*(365, 1943), //(1943, 4)), //(1943, 100)), //(1943, 400)), 212), 1), 21)), [])))))))))))).
step(integer(1944), builtin, [], []).
step(integer(8), builtin, [], []).
step(integer(21), builtin, [], []).
step(>=(1944, 1), builtin, [], []).
step(month_days(1944, 8, 31), rule(11), '.'(=('__anon0', 1944), '.'(=('M', 8), '.'(=('Days', 31), []))), '.'(ordinary_month(8, 31), [])).
step(ordinary_month(8, 31), fact(18), [], []).
step(>=(21, 1), builtin, [], []).
step(=<(21, 31), builtin, [], []).
step(month_offset(8, 212), fact(37), [], []).
step(leap_extra(1944, 8, 1), rule(28), '.'(=('Y', 1944), '.'(=('M', 8), [])), '.'(>(8, 2), '.'(leap_year(1944), []))).
step(>(8, 2), builtin, [], []).
step(leap_year(1944), rule(24), '.'(=('Y', 1944), []), '.'('=:='(0, mod(1944, 4)), '.'(=\=(0, mod(1944, 100)), []))).
step('=:='(0, mod(1944, 4)), builtin, [], []).
step(=\=(0, mod(1944, 100)), builtin, [], []).
step(is(1943, -(1944, 1)), builtin, [], []).
step(is(709899, +(+(+(+(-(+(*(365, 1943), //(1943, 4)), //(1943, 100)), //(1943, 400)), 212), 1), 21)), builtin, [], []).
step(date_day(date(2026, 10, 1), 739890), rule(8), '.'(=('Y', 2026), '.'(=('M', 10), '.'(=('D', 1), '.'(=('Ordinal', 739890), '.'(=('Maximum', 31), '.'(=('Offset', 273), '.'(=('Extra', 0), '.'(=('Previous', 2025), [])))))))), '.'(integer(2026), '.'(integer(10), '.'(integer(1), '.'(>=(2026, 1), '.'(month_days(2026, 10, 31), '.'(>=(1, 1), '.'(=<(1, 31), '.'(month_offset(10, 273), '.'(leap_extra(2026, 10, 0), '.'(is(2025, -(2026, 1)), '.'(is(739890, +(+(+(+(-(+(*(365, 2025), //(2025, 4)), //(2025, 100)), //(2025, 400)), 273), 0), 1)), [])))))))))))).
step(integer(2026), builtin, [], []).
step(integer(10), builtin, [], []).
step(integer(1), builtin, [], []).
step(>=(2026, 1), builtin, [], []).
step(month_days(2026, 10, 31), rule(11), '.'(=('__anon0', 2026), '.'(=('M', 10), '.'(=('Days', 31), []))), '.'(ordinary_month(10, 31), [])).
step(ordinary_month(10, 31), fact(20), [], []).
step(>=(1, 1), builtin, [], []).
step(=<(1, 31), builtin, [], []).
step(month_offset(10, 273), fact(39), [], []).
step(leap_extra(2026, 10, 0), rule(29), '.'(=('Y', 2026), '.'(=('M', 10), [])), '.'(>(10, 2), '.'(common_year(2026), []))).
step(>(10, 2), builtin, [], []).
step(common_year(2026), rule(25), '.'(=('Y', 2026), []), '.'(=\=(0, mod(2026, 4)), [])).
step(=\=(0, mod(2026, 4)), builtin, [], []).
step(is(2025, -(2026, 1)), builtin, [], []).
step(is(739890, +(+(+(+(-(+(*(365, 2025), //(2025, 4)), //(2025, 100)), //(2025, 400)), 273), 0), 1)), builtin, [], []).
step(>=(739890, 709899), builtin, [], []).
step(anniversary(date(1944, 8, 21), 80, date(2024, 8, 21)), rule(7), '.'(=('Y', 1944), '.'(=('M', 8), '.'(=('D', 21), '.'(=('Years', 80), '.'(=('Year', 2024), '.'(=('Day', 21), '.'(=('Maximum', 31), []))))))), '.'(is(2024, +(1944, 80)), '.'(month_days(2024, 8, 31), '.'(is(21, min(21, 31)), [])))).
step(is(2024, +(1944, 80)), builtin, [], []).
step(month_days(2024, 8, 31), rule(11), '.'(=('__anon0', 2024), '.'(=('M', 8), '.'(=('Days', 31), []))), '.'(ordinary_month(8, 31), [])).
step(is(21, min(21, 31)), builtin, [], []).
step(date_day(date(2024, 8, 21), 739119), rule(8), '.'(=('Y', 2024), '.'(=('M', 8), '.'(=('D', 21), '.'(=('Ordinal', 739119), '.'(=('Maximum', 31), '.'(=('Offset', 212), '.'(=('Extra', 1), '.'(=('Previous', 2023), [])))))))), '.'(integer(2024), '.'(integer(8), '.'(integer(21), '.'(>=(2024, 1), '.'(month_days(2024, 8, 31), '.'(>=(21, 1), '.'(=<(21, 31), '.'(month_offset(8, 212), '.'(leap_extra(2024, 8, 1), '.'(is(2023, -(2024, 1)), '.'(is(739119, +(+(+(+(-(+(*(365, 2023), //(2023, 4)), //(2023, 100)), //(2023, 400)), 212), 1), 21)), [])))))))))))).
step(integer(2024), builtin, [], []).
step(>=(2024, 1), builtin, [], []).
step(leap_extra(2024, 8, 1), rule(28), '.'(=('Y', 2024), '.'(=('M', 8), [])), '.'(>(8, 2), '.'(leap_year(2024), []))).
step(leap_year(2024), rule(24), '.'(=('Y', 2024), []), '.'('=:='(0, mod(2024, 4)), '.'(=\=(0, mod(2024, 100)), []))).
step('=:='(0, mod(2024, 4)), builtin, [], []).
step(=\=(0, mod(2024, 100)), builtin, [], []).
step(is(2023, -(2024, 1)), builtin, [], []).
step(is(739119, +(+(+(+(-(+(*(365, 2023), //(2023, 4)), //(2023, 100)), //(2023, 400)), 212), 1), 21)), builtin, [], []).
step(>(739890, 739119), builtin, [], []).
