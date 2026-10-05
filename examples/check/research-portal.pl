condition('C1', resolution, ok, 185).
condition('C2', well_founded, ok, 223).
condition('C3', justification, ok, 223).
condition('C4', coverage, ok, 385).
condition('C5', re_decision, ok, 15).
condition('C6', boundary_consistency, ok, 20).
condition('C7', relevance, ok, 258).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_33_5f_32_33_5f_33_39_5f_33_34, t('ex:policy', 'odrl:conflict', EYE_45_59_45_5f_35_33_5f_32_33_5f_33_39_5f_33_34), ['odrl:prohibit'])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_39_5f_33_38_5f_33_30, unmet('ex:r6', 'ex:research', EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_39_5f_33_38_5f_33_30), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_31_5f_33_39_5f_33_33, unmet('ex:r6', 'ex:noTransferUS', EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_31_5f_33_39_5f_33_33), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_34_5f_33_37_5f_33_35_5f_33_31, permitted('ex:r2', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_34_5f_33_37_5f_33_35_5f_33_31), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_34_5f_33_37_5f_33_35_5f_33_31, prohibited('ex:r2', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_34_5f_33_37_5f_33_35_5f_33_31), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_34_5f_33_37_5f_33_35_5f_33_31, ','(t('ex:policy', 'odrl:permission', EYE_45_59_45_5f_35_32_5f_37_35_5f_36_63_5f_36_35_5f_32_33_5f_33_34_5f_33_37_5f_33_35_5f_33_31), unmet('ex:r2', EYE_45_59_45_5f_35_32_5f_37_35_5f_36_63_5f_36_35_5f_32_33_5f_33_34_5f_33_37_5f_33_35_5f_33_31, EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_34_5f_33_37_5f_33_35_5f_33_31)), [unmet('ex:forResearch', 'odrl:purpose', 'dpv:PersonalisedAdvertising', 'odrl:isA', 'dpv:ResearchAndDevelopment')])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_35_5f_33_32_5f_33_37_5f_33_31, unmet('ex:r3', 'ex:noMarketing', EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_35_5f_33_32_5f_33_37_5f_33_31), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_35_5f_33_36_5f_33_36_5f_33_33, permitted('ex:r4', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_35_5f_33_36_5f_33_36_5f_33_33), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_35_5f_33_36_5f_33_36_5f_33_33, prohibited('ex:r4', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_35_5f_33_36_5f_33_36_5f_33_33), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_35_5f_33_36_5f_33_36_5f_33_33, ','(t('ex:policy', 'odrl:permission', EYE_45_59_45_5f_35_32_5f_37_35_5f_36_63_5f_36_35_5f_32_33_5f_33_35_5f_33_36_5f_33_36_5f_33_33), unmet('ex:r4', EYE_45_59_45_5f_35_32_5f_37_35_5f_36_63_5f_36_35_5f_32_33_5f_33_35_5f_33_36_5f_33_36_5f_33_33, EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_35_5f_33_36_5f_33_36_5f_33_33)), [unmet('ex:consentGiven', 'ex:consentStatus', 'dpv:ConsentWithdrawn', 'odrl:eq', 'dpv:ConsentGiven')])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_36_5f_33_31_5f_33_38_5f_33_37, permitted('ex:r5', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_36_5f_33_31_5f_33_38_5f_33_37), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_36_5f_33_31_5f_33_38_5f_33_37, prohibited('ex:r5', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_36_5f_33_31_5f_33_38_5f_33_37), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_36_5f_33_31_5f_33_38_5f_33_37, ','(t('ex:policy', 'odrl:permission', EYE_45_59_45_5f_35_32_5f_37_35_5f_36_63_5f_36_35_5f_32_33_5f_33_36_5f_33_31_5f_33_38_5f_33_37), unmet('ex:r5', EYE_45_59_45_5f_35_32_5f_37_35_5f_36_63_5f_36_35_5f_32_33_5f_33_36_5f_33_31_5f_33_38_5f_33_37, EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_36_5f_33_31_5f_33_38_5f_33_37)), [unmet('ex:pseudonymised', 'ex:technicalMeasure', 'dpv:Encryption', 'odrl:eq', 'dpv:Pseudonymisation'), unmet('ex:before2027', 'odrl:dateTime', 20270301, 'odrl:lt', 20270101)])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_32_5f_33_32_5f_33_37_5f_33_32, unmet('ex:r10', 'ex:research', EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_32_5f_33_32_5f_33_37_5f_33_32), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_32_5f_33_32_5f_33_36_5f_33_36, prohibited('ex:r10', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_32_5f_33_32_5f_33_36_5f_33_36), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_34_5f_33_33_5f_33_39_5f_33_31, unmet('ex:r1', 'ex:research', EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_34_5f_33_33_5f_33_39_5f_33_31), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_34_5f_33_33_5f_33_38_5f_33_35, prohibited('ex:r1', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_34_5f_33_33_5f_33_38_5f_33_35), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_31_5f_33_31, unmet('ex:r7', 'ex:research', EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_31_5f_33_31), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_30_5f_33_35, prohibited('ex:r7', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_30_5f_33_35), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_31_5f_33_31, unmet('ex:r8', 'ex:research', EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_31_5f_33_31), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_30_5f_33_35, prohibited('ex:r8', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_30_5f_33_35), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_31_5f_33_31, unmet('ex:r9', 'ex:research', EYE_45_59_45_5f_35_37_5f_36_38_5f_37_39_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_31_5f_33_31), [])).
obligation(collected, theory_scoped, findall(EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_30_5f_33_35, prohibited('ex:r9', EYE_45_59_45_5f_35_32_5f_32_33_5f_33_31_5f_33_36_5f_33_35_5f_33_30_5f_33_35), [])).
steps(223).
verified(185).
recomputed(15).
composed(0).
trusted(23).
claims(35).
verdict(checked_with_obligations).
