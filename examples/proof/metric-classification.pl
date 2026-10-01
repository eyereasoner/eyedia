summary(sample, 22.72, middle).

clause(1, measurement(sample, 72.0, 178.0), true).
clause(2, normalized(var('Id'), var('Weight'), var('Height')), ','(measurement(var('Id'), var('Weight'), var('Centimeters')), is(var('Height'), /(var('Centimeters'), 100.0)))).
clause(3, index(var('Id'), var('Value')), ','(normalized(var('Id'), var('Weight'), var('Height')), is(var('Value'), /(var('Weight'), *(var('Height'), var('Height')))))).
clause(5, band(var('Id'), middle), ','(index(var('Id'), var('Value')), ','(>=(var('Value'), 18.5), <(var('Value'), 25.0)))).
clause(7, summary(var('Id'), var('Rounded'), var('Band')), ','(index(var('Id'), var('Value')), ','(is(var('Rounded'), /(round(*(var('Value'), 100.0)), 100.0)), band(var('Id'), var('Band'))))).

step(summary(sample, 22.72, middle), rule(7), '.'(=('Id', sample), '.'(=('Rounded', 22.72), '.'(=('Band', middle), '.'(=('Value', 22.724403484408533), [])))), '.'(index(sample, 22.724403484408533), '.'(is(22.72, /(round(*(22.724403484408533, 100.0)), 100.0)), '.'(band(sample, middle), [])))).
step(index(sample, 22.724403484408533), rule(3), '.'(=('Id', sample), '.'(=('Value', 22.724403484408533), '.'(=('Weight', 72.0), '.'(=('Height', 1.78), [])))), '.'(normalized(sample, 72.0, 1.78), '.'(is(22.724403484408533, /(72.0, *(1.78, 1.78))), []))).
step(normalized(sample, 72.0, 1.78), rule(2), '.'(=('Id', sample), '.'(=('Weight', 72.0), '.'(=('Height', 1.78), '.'(=('Centimeters', 178.0), [])))), '.'(measurement(sample, 72.0, 178.0), '.'(is(1.78, /(178.0, 100.0)), []))).
step(measurement(sample, 72.0, 178.0), fact(1), [], []).
step(is(1.78, /(178.0, 100.0)), builtin, [], []).
step(is(22.724403484408533, /(72.0, *(1.78, 1.78))), builtin, [], []).
step(is(22.72, /(round(*(22.724403484408533, 100.0)), 100.0)), builtin, [], []).
step(band(sample, middle), rule(5), '.'(=('Id', sample), '.'(=('Value', 22.724403484408533), [])), '.'(index(sample, 22.724403484408533), '.'(>=(22.724403484408533, 18.5), '.'(<(22.724403484408533, 25.0), [])))).
step(>=(22.724403484408533, 18.5), builtin, [], []).
step(<(22.724403484408533, 25.0), builtin, [], []).
