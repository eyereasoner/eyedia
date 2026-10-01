report(1, c1, 100, high, no_removal_safeguards, add_notice_and_inform).
report(3, c2, 85, high, short_notice(3, 14), increase_notice(14)).
report(4, c4, 70, moderate, export_prohibited, permit_export).
report(2, c3, 97, high, sharing_without_consent, require_consent).

clause(1, permission(c1, remove_account), true).
clause(2, permission(c2, change_terms), true).
clause(3, permission(c3, share_data), true).
clause(4, prohibition(c4, export_data), true).
clause(5, notice_days(c2, 3), true).
clause(10, importance(retention, 20), true).
clause(11, importance(prior_notice, 15), true).
clause(12, importance(consent, 12), true).
clause(13, importance(portability, 10), true).
clause(14, required_notice(14), true).
clause(16, finding(var('Clause'), var('Raw'), no_removal_safeguards, add_notice_and_inform), ','(permission(var('Clause'), remove_account), ','(importance(retention, var('Weight')), ','(\+(has_notice(var('Clause'))), ','(\+(safeguard(var('Clause'), inform)), is(var('Raw'), +(90, var('Weight')))))))).
clause(17, finding(var('Clause'), var('Raw'), short_notice(var('Days'), var('Required')), increase_notice(var('Required'))), ','(permission(var('Clause'), change_terms), ','(notice_days(var('Clause'), var('Days')), ','(required_notice(var('Required')), ','(<(var('Days'), var('Required')), ','(importance(prior_notice, var('Weight')), is(var('Raw'), +(70, var('Weight'))))))))).
clause(18, finding(var('Clause'), var('Raw'), sharing_without_consent, require_consent), ','(permission(var('Clause'), share_data), ','(\+(safeguard(var('Clause'), consent)), ','(importance(consent, var('Weight')), is(var('Raw'), +(85, var('Weight'))))))).
clause(19, finding(var('Clause'), var('Raw'), export_prohibited, permit_export), ','(prohibition(var('Clause'), export_data), ','(importance(portability, var('Weight')), is(var('Raw'), +(60, var('Weight')))))).
clause(20, score(var('Clause'), 100), ','(finding(var('Clause'), var('Raw'), var('Why'), var('Fix')), >(var('Raw'), 100))).
clause(21, score(var('Clause'), var('Raw')), ','(finding(var('Clause'), var('Raw'), var('Why'), var('Fix')), =<(var('Raw'), 100))).
clause(22, severity(var('Score'), high), >=(var('Score'), 80)).
clause(23, severity(var('Score'), moderate), ','(>=(var('Score'), 50), <(var('Score'), 80))).
clause(26, count([], 0), true).
clause(27, count('.'(var('__anon0'), var('Rest')), var('N')), ','(count(var('Rest'), var('Before')), is(var('N'), +(var('Before'), 1)))).
clause(28, report(var('Rank'), var('Clause'), var('Score'), var('Severity'), var('Why'), var('Fix')), ','(score(var('Clause'), var('Score')), ','(finding(var('Clause'), var('Raw'), var('Why'), var('Fix')), ','(severity(var('Score'), var('Severity')), ','(findall(var('Other'), higher(var('Score'), var('Other')), var('Higher')), ','(count(var('Higher'), var('Count')), is(var('Rank'), +(var('Count'), 1)))))))).

step(report(1, c1, 100, high, no_removal_safeguards, add_notice_and_inform), rule(28), '.'(=('Rank', 1), '.'(=('Clause', c1), '.'(=('Score', 100), '.'(=('Severity', high), '.'(=('Why', no_removal_safeguards), '.'(=('Fix', add_notice_and_inform), '.'(=('Raw', 110), '.'(=('Other', EYE_4f_74_68_65_72_23_34_35), '.'(=('Higher', []), '.'(=('Count', 0), [])))))))))), '.'(score(c1, 100), '.'(finding(c1, 110, no_removal_safeguards, add_notice_and_inform), '.'(severity(100, high), '.'(findall(EYE_4f_74_68_65_72_23_34_35, higher(100, EYE_4f_74_68_65_72_23_34_35), []), '.'(count([], 0), '.'(is(1, +(0, 1)), []))))))).
step(score(c1, 100), rule(20), '.'(=('Clause', c1), '.'(=('Raw', 110), '.'(=('Why', no_removal_safeguards), '.'(=('Fix', add_notice_and_inform), [])))), '.'(finding(c1, 110, no_removal_safeguards, add_notice_and_inform), '.'(>(110, 100), []))).
step(finding(c1, 110, no_removal_safeguards, add_notice_and_inform), rule(16), '.'(=('Clause', c1), '.'(=('Raw', 110), '.'(=('Weight', 20), []))), '.'(permission(c1, remove_account), '.'(importance(retention, 20), '.'(\+(has_notice(c1)), '.'(\+(safeguard(c1, inform)), '.'(is(110, +(90, 20)), [])))))).
step(permission(c1, remove_account), fact(1), [], []).
step(importance(retention, 20), fact(10), [], []).
step(\+(has_notice(c1)), absent, [], []).
step(\+(safeguard(c1, inform)), absent, [], []).
step(is(110, +(90, 20)), builtin, [], []).
step(>(110, 100), builtin, [], []).
step(severity(100, high), rule(22), '.'(=('Score', 100), []), '.'(>=(100, 80), [])).
step(>=(100, 80), builtin, [], []).
step(findall(EYE_4f_74_68_65_72_23_34_35, higher(100, EYE_4f_74_68_65_72_23_34_35), []), collected, [], []).
step(count([], 0), fact(26), [], []).
step(is(1, +(0, 1)), builtin, [], []).
step(report(3, c2, 85, high, short_notice(3, 14), increase_notice(14)), rule(28), '.'(=('Rank', 3), '.'(=('Clause', c2), '.'(=('Score', 85), '.'(=('Severity', high), '.'(=('Why', short_notice(3, 14)), '.'(=('Fix', increase_notice(14)), '.'(=('Raw', 85), '.'(=('Other', EYE_4f_74_68_65_72_23_34_35), '.'(=('Higher', '.'(100, '.'(97, []))), '.'(=('Count', 2), [])))))))))), '.'(score(c2, 85), '.'(finding(c2, 85, short_notice(3, 14), increase_notice(14)), '.'(severity(85, high), '.'(findall(EYE_4f_74_68_65_72_23_34_35, higher(85, EYE_4f_74_68_65_72_23_34_35), '.'(100, '.'(97, []))), '.'(count('.'(100, '.'(97, [])), 2), '.'(is(3, +(2, 1)), []))))))).
step(score(c2, 85), rule(21), '.'(=('Clause', c2), '.'(=('Raw', 85), '.'(=('Why', short_notice(3, 14)), '.'(=('Fix', increase_notice(14)), [])))), '.'(finding(c2, 85, short_notice(3, 14), increase_notice(14)), '.'(=<(85, 100), []))).
step(finding(c2, 85, short_notice(3, 14), increase_notice(14)), rule(17), '.'(=('Clause', c2), '.'(=('Raw', 85), '.'(=('Days', 3), '.'(=('Required', 14), '.'(=('Weight', 15), []))))), '.'(permission(c2, change_terms), '.'(notice_days(c2, 3), '.'(required_notice(14), '.'(<(3, 14), '.'(importance(prior_notice, 15), '.'(is(85, +(70, 15)), []))))))).
step(permission(c2, change_terms), fact(2), [], []).
step(notice_days(c2, 3), fact(5), [], []).
step(required_notice(14), fact(14), [], []).
step(<(3, 14), builtin, [], []).
step(importance(prior_notice, 15), fact(11), [], []).
step(is(85, +(70, 15)), builtin, [], []).
step(=<(85, 100), builtin, [], []).
step(severity(85, high), rule(22), '.'(=('Score', 85), []), '.'(>=(85, 80), [])).
step(>=(85, 80), builtin, [], []).
step(findall(EYE_4f_74_68_65_72_23_34_35, higher(85, EYE_4f_74_68_65_72_23_34_35), '.'(100, '.'(97, []))), collected, [], []).
step(count('.'(100, '.'(97, [])), 2), rule(27), '.'(=('__anon0', 100), '.'(=('Rest', '.'(97, [])), '.'(=('N', 2), '.'(=('Before', 1), [])))), '.'(count('.'(97, []), 1), '.'(is(2, +(1, 1)), []))).
step(count('.'(97, []), 1), rule(27), '.'(=('__anon0', 97), '.'(=('Rest', []), '.'(=('N', 1), '.'(=('Before', 0), [])))), '.'(count([], 0), '.'(is(1, +(0, 1)), []))).
step(is(2, +(1, 1)), builtin, [], []).
step(is(3, +(2, 1)), builtin, [], []).
step(report(4, c4, 70, moderate, export_prohibited, permit_export), rule(28), '.'(=('Rank', 4), '.'(=('Clause', c4), '.'(=('Score', 70), '.'(=('Severity', moderate), '.'(=('Why', export_prohibited), '.'(=('Fix', permit_export), '.'(=('Raw', 70), '.'(=('Other', EYE_4f_74_68_65_72_23_34_35), '.'(=('Higher', '.'(100, '.'(85, '.'(97, [])))), '.'(=('Count', 3), [])))))))))), '.'(score(c4, 70), '.'(finding(c4, 70, export_prohibited, permit_export), '.'(severity(70, moderate), '.'(findall(EYE_4f_74_68_65_72_23_34_35, higher(70, EYE_4f_74_68_65_72_23_34_35), '.'(100, '.'(85, '.'(97, [])))), '.'(count('.'(100, '.'(85, '.'(97, []))), 3), '.'(is(4, +(3, 1)), []))))))).
step(score(c4, 70), rule(21), '.'(=('Clause', c4), '.'(=('Raw', 70), '.'(=('Why', export_prohibited), '.'(=('Fix', permit_export), [])))), '.'(finding(c4, 70, export_prohibited, permit_export), '.'(=<(70, 100), []))).
step(finding(c4, 70, export_prohibited, permit_export), rule(19), '.'(=('Clause', c4), '.'(=('Raw', 70), '.'(=('Weight', 10), []))), '.'(prohibition(c4, export_data), '.'(importance(portability, 10), '.'(is(70, +(60, 10)), [])))).
step(prohibition(c4, export_data), fact(4), [], []).
step(importance(portability, 10), fact(13), [], []).
step(is(70, +(60, 10)), builtin, [], []).
step(=<(70, 100), builtin, [], []).
step(severity(70, moderate), rule(23), '.'(=('Score', 70), []), '.'(>=(70, 50), '.'(<(70, 80), []))).
step(>=(70, 50), builtin, [], []).
step(<(70, 80), builtin, [], []).
step(findall(EYE_4f_74_68_65_72_23_34_35, higher(70, EYE_4f_74_68_65_72_23_34_35), '.'(100, '.'(85, '.'(97, [])))), collected, [], []).
step(count('.'(100, '.'(85, '.'(97, []))), 3), rule(27), '.'(=('__anon0', 100), '.'(=('Rest', '.'(85, '.'(97, []))), '.'(=('N', 3), '.'(=('Before', 2), [])))), '.'(count('.'(85, '.'(97, [])), 2), '.'(is(3, +(2, 1)), []))).
step(count('.'(85, '.'(97, [])), 2), rule(27), '.'(=('__anon0', 85), '.'(=('Rest', '.'(97, [])), '.'(=('N', 2), '.'(=('Before', 1), [])))), '.'(count('.'(97, []), 1), '.'(is(2, +(1, 1)), []))).
step(is(4, +(3, 1)), builtin, [], []).
step(report(2, c3, 97, high, sharing_without_consent, require_consent), rule(28), '.'(=('Rank', 2), '.'(=('Clause', c3), '.'(=('Score', 97), '.'(=('Severity', high), '.'(=('Why', sharing_without_consent), '.'(=('Fix', require_consent), '.'(=('Raw', 97), '.'(=('Other', EYE_4f_74_68_65_72_23_34_35), '.'(=('Higher', '.'(100, [])), '.'(=('Count', 1), [])))))))))), '.'(score(c3, 97), '.'(finding(c3, 97, sharing_without_consent, require_consent), '.'(severity(97, high), '.'(findall(EYE_4f_74_68_65_72_23_34_35, higher(97, EYE_4f_74_68_65_72_23_34_35), '.'(100, [])), '.'(count('.'(100, []), 1), '.'(is(2, +(1, 1)), []))))))).
step(score(c3, 97), rule(21), '.'(=('Clause', c3), '.'(=('Raw', 97), '.'(=('Why', sharing_without_consent), '.'(=('Fix', require_consent), [])))), '.'(finding(c3, 97, sharing_without_consent, require_consent), '.'(=<(97, 100), []))).
step(finding(c3, 97, sharing_without_consent, require_consent), rule(18), '.'(=('Clause', c3), '.'(=('Raw', 97), '.'(=('Weight', 12), []))), '.'(permission(c3, share_data), '.'(\+(safeguard(c3, consent)), '.'(importance(consent, 12), '.'(is(97, +(85, 12)), []))))).
step(permission(c3, share_data), fact(3), [], []).
step(\+(safeguard(c3, consent)), absent, [], []).
step(importance(consent, 12), fact(12), [], []).
step(is(97, +(85, 12)), builtin, [], []).
step(=<(97, 100), builtin, [], []).
step(severity(97, high), rule(22), '.'(=('Score', 97), []), '.'(>=(97, 80), [])).
step(>=(97, 80), builtin, [], []).
step(findall(EYE_4f_74_68_65_72_23_34_35, higher(97, EYE_4f_74_68_65_72_23_34_35), '.'(100, [])), collected, [], []).
step(count('.'(100, []), 1), rule(27), '.'(=('__anon0', 100), '.'(=('Rest', []), '.'(=('N', 1), '.'(=('Before', 0), [])))), '.'(count([], 0), '.'(is(1, +(0, 1)), []))).
