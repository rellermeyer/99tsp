% THE TRAVELING SALESMAN

% All of the paths from city to city
path(austin, houston, 238; houston, dallas, 163; dallas, austin, 212).

%Paths are bidirectional
path(City1, City2) :- path(City2, City1).

% A list of all of the cities
place(austin; houston; dallas).

% number of cities on tour
#const t=3.

%start location
location(austin, 0).

% The salesman must end in his home city
:- not location(City, t), location(City, 0).







% choose where to travel at each timestep
% there are exactly as many cities as there are timesteps
{ travel(City, Time) : place(City) } 1 :- Time = 0..t-1.

%if the salesman travels TO somewhere, he's already been there
%this way, we can travel to our start city at the end
visited(City, Time) :- travel(City, Time).

%we can't travel to a city we've been to before
:- travel(City, Time1), visited(City, Time2), Time1 > Time2.

%you can't go anywhere there is not a path to
:- travel(City_end, Time), location(City_start, Time), not path(City_start, City_end, _).

%if you travel from somewhere too somewhere, distance happens
distance(D) :- travel(City_end, Time), location(City_start, Time), path(City_start, City_end, D).


%can't travel to where you already are
:- travel(City, Time), location(City, Time).  

%Traveling gets you places
location(City, Time + 1) :-  travel(City, Time).


%uniqueness of location
-location(City2, T) :- location(City1, T), place(City2), City1 != City2.

%commonsense intertia
location(City, T + 1) :- location(City, T), not -location(City, T + 1), place(City), T = 0..t-1.


% every city must be visited by the end
:- place(City), not visited(City, _).

% tell clingo to keep trying until it fins a solution with optimal distance.
total(N) :- N = #sum{L : distance(L)}.
#minimize{N : total(N)}.

#show total/1.
#show travel/2.