%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Travelling Salesman Problem
% [1] Generate TSP map ( parse the file ) :: parse_to_map
% [2] generte all possible trips between two pairings of cities
% [3] calculate distances amongst all of those cities, using hypotheneuse
% [4] generate equality constraints
% [5] generate binary variables; their lower and upper bounds {0,1}
% respectively
% [6] Solve for the first optimal solution
% [7] Solve for optimal solution; eliminating subtours in the process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [solvedResult] = TSP_solver_functional(filename)

    fprintf('Currently processing TSP data file %s. \n',filename);
	[citiesLat,citiesLon,nCities] = parse_to_map(filename);
	trips = nchoosek(1:nCities,2); 
	tripDistances = hypot(citiesLat(trips(:,1)) - citiesLat(trips(:,2)), citiesLon(trips(:,1)) - citiesLon(trips(:,2)));
	numTrips = length(tripDistances);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% minimization function is ( based on tour length ) %%
	% | tripDistancess ' * x_tsp |
	% | x_tsp | = binary solution vector ( of binary vars ) = tour distance ( we want to minimize ) 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% And a set of equality consraints the suffice ( 2 of them )
	% [1] nCities total trips
	% [2] each stop must have two trips attached to it ( 1 in-degree ~= 1 out
	% degree )
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Constraint #1
	%     |Aeq*x_tsp = beq|
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	aeq = spones(1:length(trips));  
	beq = nCities;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Constriant #2
	%     ensure two trips attached @ each stop ONLY
	%     extend Aeq to include sparse matrix
	%     that captures notion of cities*(cities-1) max # stops only, in a
	%     matrix that captures nCities * all possible trips !
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	twoNodesPerCityConstraint = spalloc(nCities, length(trips), nCities*(nCities-1));
	for i = 1:1:nCities
		tripsIncludingCity_i = (trips == i); % find all trips , that include the city 'i'
		indicesofTripsIncludingCity_i = sparse(sum(tripsIncludingCity_i,2)); % sum over each col ... get col vector
		twoNodesPerCityConstraint(i,:) = indicesofTripsIncludingCity_i';
	end
	numStopsConstraint = 2*ones(nCities,1);
	Aeq = [aeq;twoNodesPerCityConstraint];
	Beq = [beq;numStopsConstraint];

	%%%%%%%% setting bounds for binary variables { 0,1} %%%%%%%%%%%%%%%%%%%%%
	intcon = 1:numTrips; %x(intcon) are integers
	lb = zeros(numTrips,1);
	ub = ones(numTrips,1);
	f = tripDistances;

	%%%%%%%%%%%%%%% now, solve the linear programming model %%%%%%%%%%%%%%%%
	%%%% set up a solver, using optimization options ( from optimoptions
	%%%% toolbox)
	%%% pass constraints + minimization eq to "intlinprog" too solve for 
	% opts = optimoptions(); ... tbh, this does not really seem to be needed!
	%%% note :: do I even need all of these outputs?? 

	% note :: [],[] are passed, as we do not have a set of inequalities
	%    of form A * x <= b
	%     as we have only an Aeq *x = Beq ( equality ) constraints!
	% reference :: see http://www.mathworks.com/help/optim/ug/intlinprog.html
	[x_tsp,fval,exitflag,output] = intlinprog(f,intcon,[],[], Aeq,Beq, lb, ub);
	optimal_cost = fval;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% more constraints, to prevent subtours %%%%
	%%% need to bvreak up subrings/tours TO form a main ring ( of only one tour
	%%% ) 
	%%% add a constraint iteratively 
	%%% matlab provides a nice "detectSubtours" function !
	% we will introduce inequalities to ELIMINIATE subtour constraints
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	subTours = detectSubtours(x_tsp, trips); % pass trip information ( all possible pairs ) to matlab's subtour detection algo
	curNumSubTours = length(subTours);
	fprintf('Currently have # subtours = %d\n', curNumSubTours);

	%%% now to solve the subtour case 
	A = spalloc(0,numTrips,0); 
	B = [];
	while curNumSubTours > 1

		% add subtour constraints ( these are inequality constraints {A,b} ) 
		% go every subtour; update data for inequalituy constraints {A,b}
		B = [B;zeros(curNumSubTours,1)];  
		A = [A;spalloc(curNumSubTours,numTrips,nCities)];
		for i = 1:1:curNumSubTours   
			rowIdx = size(A,1) + 1; % counter for indexing ( into matrix A ) 
			subTourTrips = subTours{i}; 
			newTrips = nchoosek(1:length(subTourTrips),2);
			for j = 1:1:length(newTrips)
				whichVar = (sum(trips == subTourTrips(newTrips(j,1)),2)) & ... 
							(sum(trips == subTourTrips(newTrips(j,2)),2));
				A(rowIdx,whichVar) = 1;
			end      
			B(rowIdx) = length(subTourTrips) - 1; % impose :: one less trip than # trips in subtour
		end
		
		% retry integer-programming optimization approach again
		[x_tsp,fval,exitflag,output] = intlinprog(f,intcon,A,B, Aeq,Beq, lb, ub);
		
		% couint cur number subtours
		subTours = detectSubtours(x_tsp, trips);
		curNumSubTours = length(subTours);
		fprintf('Currently have # subtours = %d\n', curNumSubTours);
		
	end

    indices_in_trips = find(x_tsp); % get indices, of all nonzero ( 1) elmenets.
    actual_paths = trips(indices_in_trips,:);
    %%% should be correct up till here !

    % GET (lat,lon) data that corresponds to indices of solution
    actual_long = citiesLat(actual_paths(:,1));
    actual_lat = citiesLat(actual_paths(:,2));
    segments = [actual_long; actual_lat];
    segments = segments';
    dlmwrite('solution.txt',segments,'delimiter','\t');
    solvedResult = segments;
end
