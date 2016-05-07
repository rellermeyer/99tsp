% gets prolog to work from command line

:- initialization main. 


%Pass the File location you want to read in,
%the temperature you want to start with,
%the temperature you want to reach,
%and the constant by which the temperature is increasing

%i.e temp start is 1, temp reach is 1000000, constant is 4

main:-

b_setval('Temp', 1),
b_setval('Temp_min' , 1000000),
b_setval('A', 1.9),
b_setval('mincost', 1000000),
b_setval('currentcost', 0),
%read in command lines
  current_prolog_flag(argv, AllArgs),
  append(_, [-- | File1], AllArgs),
nth0(0, File1, File2),

atom_string(File, File2),

%open the file and disregard extra input, im too lazy to
open(File,read,ID),
read_line_to_codes(ID,_),
read_line_to_codes(ID,_),
read_line_to_codes(ID,_),
read_line_to_codes(ID,Y ),
split_string(Y, " ", "", [_, B]),
b_setval('Dim', B),
read_line_to_codes(ID,_),
read_line_to_codes(ID,_),
reads(ID,_),

%Get the list, and generate a completely random list
b_getval('List1', List1),
generate_random_sol(List1,List2),
%store the cost of the list for time

calculate_Cost(List2, Cost1),
b_setval('List', List2),
b_setval('currentcost', Cost1),

%find the optimal node pairings
find_Optimal(Solution),
 open('results.txt',write,X),

 % Output the optimal answer
 b_getval('List',List3),
 G is Solution / 10,
 write(X,'The current distance is :'),
 write(X, G),
 nl(X),
 write(X,'The current node set is : '),
  nl(X),
 printlist(List3,X),

 %close input and output streams
 close(X),
 close(ID),
 halt.



printlist([], _).

printlist([H|T], X):-
write(X,H),
nl(X),
printlist(T,X).

% Get all of the Node pairings from the input, and store them globally 
% and inside of a giant list with all of the Node names
reads(ID,List):-
read_line_to_codes(ID, X),
split_string(X, " ", "", L),
delete(L,"", [A,B,C]),
A\="end_of_line",
B\="end_of_line",
C\="end_of_line",
atom_number(A, A1),
atom_number(B, B1),
atom_number(C, C1),
term_to_atom(A, A2),
b_setval(A2, (B1,C1)),
append(List, [A1], List1 ),
b_setval('List1',List1),
reads(ID,List1).

reads(_, _):-

!.



% Will return a value above 0 based on Temperature, and the cost of the two
acceptance_Probability(Cost1, Cost2, _, Result) :-
Cost1-Cost2 > 100,
Result is 0.
acceptance_Probability(Cost1, Cost2, T, Result) :-
Result is e^((Cost1-Cost2)/T).

% attempts to find the best node pairings by looping through the pairings
% and randomly finding a neighbor that might be better than the current solution
find_Optimal(K) :-

	b_getval('Temp', X),
	b_getval('Temp_min',Y),

    X=<Y,
     solve(1),
    b_getval('A', A1),

    G is X * A1, 
    b_setval('Temp', G),
    b_getval('List',Max),
    generate_random_neighbor(Max, A ),
    b_setval('List',A),

    find_Optimal(K).
  

% In this case, the loop is done so we find the final cost and store it

find_Optimal(Solution) :-

	b_getval('Temp', X),
	b_getval('Temp_min',Y),
	X>Y,
	b_getval('List', Z),
    calculate_Cost(Z, Solution).





% This loops through starting at a random permutation pairings
% and attempts to find the best pairings set


solve(I):-

I<300,
b_getval('List', L1),
b_getval('currentcost',Cost1),
generate_random_neighbor(L1,L2),
calculate_Cost(L2, Cost2),
!,
b_getval('mincost', Cost3),
checkcost(Cost1,Cost3),
checkcost(Cost2,Cost3),
b_getval('Temp', T),
acceptance_Probability(Cost1, Cost2, T, Result),
random(A2),
J is I + 1,

% see if we want to pick the neighboring set instead
(  Result > A2
    -> b_setval('List', L2),
    	b_setval('currentcost', Cost2),
    !,
    solve(J)
    ; !,
    solve(J)
 ).

solve(X):-
X>=100.



% Check to see if the cost is minimial 
checkcost(C1,C3):-
C1 < C3,
b_setval('mincost',C1).

checkcost(_,_).


% calculating cost of traveling along the selected path

calculate_Cost([H|[H1|T]], Cost) :-
 
 distance(H,H1, A),
  !,
 calculate_Cost([H1|T],Rest),
 Cost is A + Rest.

calculate_Cost([_], Cost) :-

Cost is 0.

%get distance between two nodes 

distance(A,B, Dist) :-

term_string(A, A1),
term_string(B, B1),
term_to_atom(A1, A2),
term_to_atom(B1, B2),
b_getval(A2,(X1,Y1)),
b_getval(B2, (X2,Y2)),
K is X2- X1,
K1 is Y2-Y1,
K2 is K * K,
K3 is K1 * K1,
K4 is K2 + K3,
K5 is sqrt(K4),
Dist is K5.


%generate a random solution of the biggining

generate_random_sol(A,X) :-
random_permutation(A, X).


%generate a random neighbor of the list,
%neighbor being two elements in the list swapped

generate_random_neighbor(A,X) :-

b_getval('Dim',Max1), 
number_string(Max2, Max1),
Max is Max2-1,
random(2, Max, G),
random(2, Max, H),
list_swap(A, G,H, Y),
random(2, Max, G1),
random(2, Max, H1),
list_swap(Y, G1,H1, X).



%swap two elements in the list randomly,
%making sure the lists remain

list_swap(Before,_,_,After) :-

   same_length(Before,After),
   append(B1,[A1|A11],Before),
   append(B1,[A2|A11],Swap),
   append(B2,[A2|A22],Swap),
   append(B2,[A1|A22],After).
