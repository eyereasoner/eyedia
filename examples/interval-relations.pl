% Half-open intervals [Start, End), measured in integer minutes.
interval(a, 600, 720).
interval(b, 780, 900).
interval(c, 720, 840).
interval(d, 660, 780).
interval(e, 600, 720).
interval(f, 600, 660).
interval(g, 660, 720).
interval(h, 540, 960).
start_duration(i, 960, 120).
end_duration(j, 960, 60).
interval(I, S, E) :+ start_duration(I, S, D), D > 0, E is S+D.
interval(I, S, E) :+ end_duration(I, E, D), D > 0, S is E-D.
valid_interval(I, S, E) :- interval(I, S, E), S < E.
pair(I, J, SI, EI, SJ, EJ) :- valid_interval(I, SI, EI), valid_interval(J, SJ, EJ).
relation(I, before, J) :+ pair(I, J, SI, EI, SJ, EJ), EI < SJ.
relation(I, meets, J) :+ pair(I, J, SI, EI, SJ, EJ), EI =:= SJ.
relation(I, overlaps, J) :+ pair(I, J, SI, EI, SJ, EJ), SI < SJ, SJ < EI, EI < EJ.
relation(I, starts, J) :+ pair(I, J, SI, EI, SJ, EJ), SI =:= SJ, EI < EJ.
relation(I, during, J) :+ pair(I, J, SI, EI, SJ, EJ), SJ < SI, EI < EJ.
relation(I, finishes, J) :+ pair(I, J, SI, EI, SJ, EJ), SJ < SI, EI =:= EJ.
relation(I, equals, J) :+ pair(I, J, SI, EI, SJ, EJ), SI =:= SJ, EI =:= EJ.
relation(J, after, I) :+ relation(I, before, J).
relation(J, met_by, I) :+ relation(I, meets, J).
relation(J, overlapped_by, I) :+ relation(I, overlaps, J).
relation(J, started_by, I) :+ relation(I, starts, J).
relation(J, contains, I) :+ relation(I, during, J).
relation(J, finished_by, I) :+ relation(I, finishes, J).
true :+ relation(I, Relation, J).
