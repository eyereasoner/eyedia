% Colour the map of the European Union with four colours so that no two
% neighbouring countries share one. Each country is coloured after the ones
% listed below it, choosing the first colour none of its already-coloured
% neighbours uses. The four colour theorem says this always succeeds.
% See https://en.wikipedia.org/wiki/Four_color_theorem
colors(_Map, Places) :-
    findall([Place, _], neighbours(Place, _), Places),
    once(places(Places)).

places([]).
places([[Place, Color]|Tail]) :-
    places(Tail),
    neighbours(Place, Neighbours),
    member(Color, [red, green, blue, yellow]),
    \+ conflict(Color, Tail, Neighbours).

% A colour conflicts when an already-coloured neighbour has it.
conflict(Color, Coloured, Neighbours) :- member([Neighbour, Color], Coloured), member(Neighbour, Neighbours).

member(X, [X|_]).
member(X, [_|Rest]) :- member(X, Rest).

% The map of the European Union.
neighbours('Belgium', ['France', 'Netherlands', 'Luxemburg', 'Germany']).
neighbours('Netherlands', ['Belgium', 'Germany']).
neighbours('Luxemburg', ['Belgium', 'France', 'Germany']).
neighbours('France', ['Spain', 'Belgium', 'Luxemburg', 'Germany', 'Italy']).
neighbours('Germany', ['Netherlands', 'Belgium', 'Luxemburg', 'Denmark', 'France', 'Austria', 'Poland', 'Czech Republic']).
neighbours('Italy', ['France', 'Austria', 'Slovenia']).
neighbours('Denmark', ['Germany']).
neighbours('Ireland', []).
neighbours('Greece', ['Bulgaria']).
neighbours('Spain', ['France', 'Portugal']).
neighbours('Portugal', ['Spain']).
neighbours('Austria', ['Czech Republic', 'Germany', 'Hungary', 'Italy', 'Slovenia', 'Slovakia']).
neighbours('Sweden', ['Finland']).
neighbours('Finland', ['Sweden']).
neighbours('Cyprus', []).
neighbours('Malta', []).
neighbours('Poland', ['Germany', 'Czech Republic', 'Slovakia', 'Lithuania']).
neighbours('Hungary', ['Austria', 'Slovakia', 'Romania', 'Croatia', 'Slovenia']).
neighbours('Czech Republic', ['Germany', 'Poland', 'Slovakia', 'Austria']).
neighbours('Slovakia', ['Czech Republic', 'Poland', 'Hungary', 'Austria']).
neighbours('Slovenia', ['Austria', 'Italy', 'Hungary', 'Croatia']).
neighbours('Estonia', ['Latvia']).
neighbours('Latvia', ['Estonia', 'Lithuania']).
neighbours('Lithuania', ['Latvia', 'Poland']).
neighbours('Bulgaria', ['Romania', 'Greece']).
neighbours('Romania', ['Hungary', 'Bulgaria']).
neighbours('Croatia', ['Slovenia', 'Hungary']).

true :+ colors(mapEU, _).
