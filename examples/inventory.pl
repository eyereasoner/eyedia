% Collection runs after line totals have been materialized.
item(apple, 3, 2).
item(pear, 4, 3).
item(plum, 2, 5).
line_total(Name, Total) :+ item(Name, Quantity, Price), Total is Quantity*Price.
sum([], 0).
sum([X|Xs], Total) :- sum(Xs, Rest), Total is X+Rest.
invoice(Total) :+ findall(Amount, line_total(_, Amount), Amounts), sum(Amounts, Total).
true :+ invoice(Total).
