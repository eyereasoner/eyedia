% Age checker with an explicit reference date, so proofs remain reproducible.
% Change as_of/1 or query age_above(Person, years(N), date(Y, M, D)).
% Thresholds are strictly exceeded; a leap-day anniversary falls on February
% 28 in a non-leap year. days(N) instead measures exact elapsed whole days.
birth_date(pat_h, date(1944, 8, 21)).
as_of(date(2026, 10, 1)).

age_above(Person, Duration) :- as_of(Date), age_above(Person, Duration, Date).
age_above(Person, years(Years), Date) :-
    integer(Years), Years >= 0, birth_date(Person, Birth),
    date_day(Birth, Born), date_day(Date, Today), Today >= Born,
    anniversary(Birth, Years, Anniversary), date_day(Anniversary, Threshold),
    Today > Threshold.
age_above(Person, days(Days), Date) :-
    integer(Days), Days >= 0, age_days(Person, Date, Age), Age > Days.
age_days(Person, Date, Days) :-
    birth_date(Person, Birth), date_day(Birth, Born), date_day(Date, Today),
    Today >= Born, Days is Today-Born.
anniversary(date(Y, M, D), Years, date(Year, M, Day)) :-
    Year is Y+Years, month_days(Year, M, Maximum), Day is min(D, Maximum).

% Proleptic Gregorian calendar; dates have integer years >= 1.
date_day(date(Y, M, D), Ordinal) :-
    integer(Y), integer(M), integer(D), Y >= 1,
    month_days(Y, M, Maximum), D >= 1, D =< Maximum,
    month_offset(M, Offset), leap_extra(Y, M, Extra), Previous is Y-1,
    Ordinal is 365*Previous+Previous//4-Previous//100+Previous//400+Offset+Extra+D.
month_days(Y, 2, 29) :- leap_year(Y).
month_days(Y, 2, 28) :- common_year(Y).
month_days(_, M, Days) :- ordinary_month(M, Days).
ordinary_month(1, 31).
ordinary_month(3, 31).
ordinary_month(4, 30).
ordinary_month(5, 31).
ordinary_month(6, 30).
ordinary_month(7, 31).
ordinary_month(8, 31).
ordinary_month(9, 30).
ordinary_month(10, 31).
ordinary_month(11, 30).
ordinary_month(12, 31).
leap_year(Y) :- 0 =:= Y mod 400.
leap_year(Y) :- 0 =:= Y mod 4, 0 =\= Y mod 100.
common_year(Y) :- 0 =\= Y mod 4.
common_year(Y) :- 0 =:= Y mod 100, 0 =\= Y mod 400.
leap_extra(_, M, 0) :- M =< 2.
leap_extra(Y, M, 1) :- M > 2, leap_year(Y).
leap_extra(Y, M, 0) :- M > 2, common_year(Y).
month_offset(1, 0).
month_offset(2, 31).
month_offset(3, 59).
month_offset(4, 90).
month_offset(5, 120).
month_offset(6, 151).
month_offset(7, 181).
month_offset(8, 212).
month_offset(9, 243).
month_offset(10, 273).
month_offset(11, 304).
month_offset(12, 334).

?- age_above(Person, years(80)).
