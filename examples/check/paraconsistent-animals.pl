condition('C1', resolution, ok, 11).
condition('C2', well_founded, ok, 13).
condition('C3', justification, ok, 13).
condition('C4', coverage, ok, 13).
condition('C5', re_decision, ok, 0).
obligation(absent, theory_scoped, \+(flies(falco, false))).
obligation(absent, theory_scoped, \+(flies(opus, true))).
steps(13).
verified(11).
recomputed(0).
composed(0).
trusted(2).
claims(3).
verdict(checked_with_obligations).
