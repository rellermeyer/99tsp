// INCOMPLETE

// example of input data format: 
// var data = [[10,300], [40,200], [20,300], [30, 500]]; 

// Implements two-opt swap on route, with given nodes q & r
// Returns the modified route

function twoopt(route, q, r){
	var output = [];

	for(var i = 0; i <= q-1; i++){
		output[i] = route[i];
	}

	var temp = r; 
	
	for(var i = q; i <= r; i++){
		output[i] = route[temp];
		temp--; 
	}

	for(var i = r+1; i < route.length; i++){
		output[i] = route[i];
	}

	return output; 

}

// generates all possible combinations of routes to call twoopt on
// total is a list of all the possible routes

function combinations(data){
	var list = [];
	var total = []; 

	for(var i = 0; i < data.length; i++){
		list[i] = i; 
	}

	for(var x= 0; x < list.length - 1; x++){
		for(var y= x+1; y < list.length; y++){
			total[x] = twoopt(data,x,y);
		}
	}

	return total; 
}


function compareRoutes(allRoutes){

	// The purpose of this function is to compare the routes to one another to determine which one is the shortest. The shortest route is the solution. 
}
