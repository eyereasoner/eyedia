% Normalize metric measurements, compute an index, then classify its range.
measurement(sample, 72.0, 178.0).
normalized(Id, Weight, Height) :+ measurement(Id, Weight, Centimeters), Height is Centimeters/100.0.
index(Id, Value) :+ normalized(Id, Weight, Height), Value is Weight/(Height*Height).
band(Id, low) :+ index(Id, Value), Value < 18.5.
band(Id, middle) :+ index(Id, Value), Value >= 18.5, Value < 25.0.
band(Id, high) :+ index(Id, Value), Value >= 25.0.
summary(Id, Rounded, Band) :+ index(Id, Value), Rounded is round(Value*100.0)/100.0, band(Id, Band).
true :+ summary(Id, Rounded, Band).
