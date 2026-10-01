condition('C1', resolution, ok, 8).
condition('C2', well_founded, ok, 10).
condition('C3', justification, ok, 10).
condition('C4', coverage, ok, 12).
condition('C5', re_decision, ok, 0).
obligation(absent, theory_scoped, \+(t(carol, blocked, true))).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_34_33_5f_32_33_5f_33_31_5f_33_34, t(EYE_45_59_45_5f_34_33_5f_32_33_5f_33_31_5f_33_34, child_of, alice), '.'(bob, '.'(carol, [])))).
steps(10).
verified(8).
recomputed(0).
composed(0).
trusted(2).
claims(4).
verdict(checked_with_obligations).
