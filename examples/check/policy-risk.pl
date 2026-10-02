condition('C1', resolution, ok, 32).
condition('C2', well_founded, ok, 57).
condition('C3', justification, ok, 57).
condition('C4', coverage, ok, 69).
condition('C5', re_decision, ok, 18).
obligation(absent, theory_scoped, \+(has_notice(c1))).
obligation(absent, theory_scoped, \+(safeguard(c1, inform))).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_34_66_5f_37_34_5f_36_38_5f_36_35_5f_37_32_5f_32_33_5f_33_34_5f_33_35, higher(100, EYE_45_59_45_5f_34_66_5f_37_34_5f_36_38_5f_36_35_5f_37_32_5f_32_33_5f_33_34_5f_33_35), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_34_66_5f_37_34_5f_36_38_5f_36_35_5f_37_32_5f_32_33_5f_33_34_5f_33_35, higher(85, EYE_45_59_45_5f_34_66_5f_37_34_5f_36_38_5f_36_35_5f_37_32_5f_32_33_5f_33_34_5f_33_35), [100, 97])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_34_66_5f_37_34_5f_36_38_5f_36_35_5f_37_32_5f_32_33_5f_33_34_5f_33_35, higher(70, EYE_45_59_45_5f_34_66_5f_37_34_5f_36_38_5f_36_35_5f_37_32_5f_32_33_5f_33_34_5f_33_35), [100, 85, 97])).
obligation(absent, theory_scoped, \+(safeguard(c3, consent))).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_34_66_5f_37_34_5f_36_38_5f_36_35_5f_37_32_5f_32_33_5f_33_34_5f_33_35, higher(97, EYE_45_59_45_5f_34_66_5f_37_34_5f_36_38_5f_36_35_5f_37_32_5f_32_33_5f_33_34_5f_33_35), [100])).
steps(57).
verified(32).
recomputed(18).
composed(0).
trusted(7).
claims(4).
verdict(checked_with_obligations).
