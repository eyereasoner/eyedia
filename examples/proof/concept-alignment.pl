rolls_up_to(reference_car, reference_car).
rolls_up_to(sensor_car, reference_car).
rolls_up_to(sensor_heavy_vehicle, reference_car).
rolls_up_to(vehicle_with_plate, reference_car).
rolls_up_to(passenger_car, reference_car).

clause(1, concept(reference_car), true).
clause(6, broad_match(sensor_car, reference_car), true).
clause(7, broad_match(sensor_heavy_vehicle, reference_car), true).
clause(8, broad_match(vehicle_with_plate, reference_car), true).
clause(9, broader(passenger_car, vehicle_with_plate), true).
clause(10, broader(var('A'), var('B')), broad_match(var('A'), var('B'))).
clause(11, broader_transitive(var('A'), var('B')), broader(var('A'), var('B'))).
clause(12, broader_transitive(var('A'), var('C')), ','(broader_transitive(var('A'), var('B')), broader_transitive(var('B'), var('C')))).
clause(14, narrower_or_equal(var('A'), var('A')), concept(var('A'))).
clause(15, narrower_or_equal(var('A'), var('B')), broader_transitive(var('A'), var('B'))).
clause(16, rolls_up_to(var('Concept'), reference_car), narrower_or_equal(var('Concept'), reference_car)).

step(rolls_up_to(reference_car, reference_car), rule(16), '.'(=('Concept', reference_car), []), '.'(narrower_or_equal(reference_car, reference_car), [])).
step(narrower_or_equal(reference_car, reference_car), rule(14), '.'(=('A', reference_car), []), '.'(concept(reference_car), [])).
step(concept(reference_car), fact(1), [], []).
step(rolls_up_to(sensor_car, reference_car), rule(16), '.'(=('Concept', sensor_car), []), '.'(narrower_or_equal(sensor_car, reference_car), [])).
step(narrower_or_equal(sensor_car, reference_car), rule(15), '.'(=('A', sensor_car), '.'(=('B', reference_car), [])), '.'(broader_transitive(sensor_car, reference_car), [])).
step(broader_transitive(sensor_car, reference_car), rule(11), '.'(=('A', sensor_car), '.'(=('B', reference_car), [])), '.'(broader(sensor_car, reference_car), [])).
step(broader(sensor_car, reference_car), rule(10), '.'(=('A', sensor_car), '.'(=('B', reference_car), [])), '.'(broad_match(sensor_car, reference_car), [])).
step(broad_match(sensor_car, reference_car), fact(6), [], []).
step(rolls_up_to(sensor_heavy_vehicle, reference_car), rule(16), '.'(=('Concept', sensor_heavy_vehicle), []), '.'(narrower_or_equal(sensor_heavy_vehicle, reference_car), [])).
step(narrower_or_equal(sensor_heavy_vehicle, reference_car), rule(15), '.'(=('A', sensor_heavy_vehicle), '.'(=('B', reference_car), [])), '.'(broader_transitive(sensor_heavy_vehicle, reference_car), [])).
step(broader_transitive(sensor_heavy_vehicle, reference_car), rule(11), '.'(=('A', sensor_heavy_vehicle), '.'(=('B', reference_car), [])), '.'(broader(sensor_heavy_vehicle, reference_car), [])).
step(broader(sensor_heavy_vehicle, reference_car), rule(10), '.'(=('A', sensor_heavy_vehicle), '.'(=('B', reference_car), [])), '.'(broad_match(sensor_heavy_vehicle, reference_car), [])).
step(broad_match(sensor_heavy_vehicle, reference_car), fact(7), [], []).
step(rolls_up_to(vehicle_with_plate, reference_car), rule(16), '.'(=('Concept', vehicle_with_plate), []), '.'(narrower_or_equal(vehicle_with_plate, reference_car), [])).
step(narrower_or_equal(vehicle_with_plate, reference_car), rule(15), '.'(=('A', vehicle_with_plate), '.'(=('B', reference_car), [])), '.'(broader_transitive(vehicle_with_plate, reference_car), [])).
step(broader_transitive(vehicle_with_plate, reference_car), rule(11), '.'(=('A', vehicle_with_plate), '.'(=('B', reference_car), [])), '.'(broader(vehicle_with_plate, reference_car), [])).
step(broader(vehicle_with_plate, reference_car), rule(10), '.'(=('A', vehicle_with_plate), '.'(=('B', reference_car), [])), '.'(broad_match(vehicle_with_plate, reference_car), [])).
step(broad_match(vehicle_with_plate, reference_car), fact(8), [], []).
step(rolls_up_to(passenger_car, reference_car), rule(16), '.'(=('Concept', passenger_car), []), '.'(narrower_or_equal(passenger_car, reference_car), [])).
step(narrower_or_equal(passenger_car, reference_car), rule(15), '.'(=('A', passenger_car), '.'(=('B', reference_car), [])), '.'(broader_transitive(passenger_car, reference_car), [])).
step(broader_transitive(passenger_car, reference_car), rule(12), '.'(=('A', passenger_car), '.'(=('C', reference_car), '.'(=('B', vehicle_with_plate), []))), '.'(broader_transitive(passenger_car, vehicle_with_plate), '.'(broader_transitive(vehicle_with_plate, reference_car), []))).
step(broader_transitive(passenger_car, vehicle_with_plate), rule(11), '.'(=('A', passenger_car), '.'(=('B', vehicle_with_plate), [])), '.'(broader(passenger_car, vehicle_with_plate), [])).
step(broader(passenger_car, vehicle_with_plate), fact(9), [], []).
