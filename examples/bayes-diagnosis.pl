% Illustrative naive Bayes diagnosis of a printer: jam and offline observations.
% Weights are whole percentages; products stay exact until normalization.
fault(paper_jam, 20, 90, 10).
fault(network_loss, 30, 5, 95).
fault(power_loss, 50, 1, 99).
weight(Fault, Weight) :+ fault(Fault, Prior, Jam, Offline), Weight is Prior*Jam*Offline.
sum_weights([], 0).
sum_weights([W|Ws], Sum) :- sum_weights(Ws, Rest), Sum is W+Rest.
total(Total) :+ findall(W, weight(Fault, W), Weights), sum_weights(Weights, Total).
posterior(Fault, Numerator, Denominator, Probability) :+
    weight(Fault, Numerator), total(Denominator), Denominator > 0,
    Probability is Numerator/Denominator.
true :+ posterior(Fault, Numerator, Denominator, Probability).
