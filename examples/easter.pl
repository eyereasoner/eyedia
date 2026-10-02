% The date of Easter Sunday, by the anonymous Gregorian algorithm (Meeus/Jones/
% Butcher). Every step is integer arithmetic on the year; the result is a
% [Month, Day] pair.
computus(Year, [Month, Day]) :-
    A is Year rem 19,
    B is Year//100,
    C is Year rem 100,
    D is (19*A+B-B//4-((B-(B+8)//25+1)//3)+15) rem 30,
    E is (32+2*(B rem 4)+2*(C//4)-D-(C rem 4)) rem 7,
    F is D+E-7*((A+11*D+22*E)//451)+114,
    Month is F//31,
    Day is F rem 31+1.

in_range(Low, High, Low) :- Low =< High.
in_range(Low, High, N) :- Low < High, Next is Low+1, in_range(Next, High, N).

easter(Year, Date) :+ in_range(2021, 2050, Year), computus(Year, Date).
