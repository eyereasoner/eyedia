% Rank clause findings by score, retaining reasons and suggested mitigations.
% This is a small illustrative policy model; scores are model parameters.
permission(c1, remove_account).
permission(c2, change_terms).
permission(c3, share_data).
prohibition(c4, export_data).
notice_days(c2, 3).
permission(c5, share_data).
safeguard(c5, consent).
permission(c6, change_terms).
notice_days(c6, 14).
importance(retention, 20).
importance(prior_notice, 15).
importance(consent, 12).
importance(portability, 10).
required_notice(14).
has_notice(Clause) :- notice_days(Clause, Days), Days >= 0.
finding(Clause, Raw, no_removal_safeguards, add_notice_and_inform) :+
    permission(Clause, remove_account), importance(retention, Weight),
    \+ has_notice(Clause), \+ safeguard(Clause, inform), Raw is 90+Weight.
finding(Clause, Raw, short_notice(Days, Required), increase_notice(Required)) :+
    permission(Clause, change_terms), notice_days(Clause, Days),
    required_notice(Required), Days < Required,
    importance(prior_notice, Weight), Raw is 70+Weight.
finding(Clause, Raw, sharing_without_consent, require_consent) :+
    permission(Clause, share_data), \+ safeguard(Clause, consent),
    importance(consent, Weight), Raw is 85+Weight.
finding(Clause, Raw, export_prohibited, permit_export) :+
    prohibition(Clause, export_data), importance(portability, Weight), Raw is 60+Weight.
score(Clause, 100) :+ finding(Clause, Raw, Why, Fix), Raw > 100.
score(Clause, Raw) :+ finding(Clause, Raw, Why, Fix), Raw =< 100.
severity(Score, high) :- Score >= 80.
severity(Score, moderate) :- Score >= 50, Score < 80.
severity(Score, low) :- Score < 50.
higher(Score, Other) :- score(Clause, Other), Other > Score.
count([], 0).
count([_|Rest], N) :- count(Rest, Before), N is Before+1.
report(Rank, Clause, Score, Severity, Why, Fix) :+
    score(Clause, Score), finding(Clause, Raw, Why, Fix), severity(Score, Severity),
    findall(Other, higher(Score, Other), Higher), count(Higher, Count), Rank is Count+1.
true :+ report(Rank, Clause, Score, Severity, Why, Fix).
