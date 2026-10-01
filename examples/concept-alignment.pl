% Roll up different source vocabularies to a common reporting concept.
concept(reference_car).
concept(sensor_car).
concept(sensor_heavy_vehicle).
concept(vehicle_with_plate).
concept(passenger_car).
broad_match(sensor_car, reference_car).
broad_match(sensor_heavy_vehicle, reference_car).
broad_match(vehicle_with_plate, reference_car).
broader(passenger_car, vehicle_with_plate).
broader(A, B) :+ broad_match(A, B).
broader_transitive(A, B) :+ broader(A, B).
broader_transitive(A, C) :+ broader_transitive(A, B), broader_transitive(B, C).
narrower_transitive(B, A) :+ broader_transitive(A, B).
narrower_or_equal(A, A) :- concept(A).
narrower_or_equal(A, B) :- broader_transitive(A, B).
rolls_up_to(Concept, reference_car) :+ narrower_or_equal(Concept, reference_car).
true :+ rolls_up_to(Concept, reference_car).
