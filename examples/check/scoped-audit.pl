condition('C1', resolution, ok, 9).
condition('C2', well_founded, ok, 10).
condition('C3', justification, ok, 10).
condition('C4', coverage, ok, 10).
condition('C5', re_decision, ok, 0).
obligation(absent, theory_scoped, \+(includes(graph('.'(triple(bob, role, editor), [])), triple(bob, consent, yes)))).
steps(10).
verified(9).
recomputed(0).
composed(0).
trusted(1).
claims(2).
verdict(checked_with_obligations).
