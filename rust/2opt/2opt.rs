//Kshitij Delvadiya
//Rellermeyer CS345 Fall 2016

use std::env;
use std::io::Error;
use std::io::prelude::*;
use std::fs::File;
use std::process::exit;
use std::f32;

#[derive(Clone)]
struct Node {
	id : i32,
	x : i32,
	y : i32,
}


fn main() {
	//Rust's type system is pretty good.
	//There are so many compile time checks!

	//If a process can error, like file reading, then you can set the return type
	//	of the function in which it is called to Result<T, E>
	//	where T is the result of success and E is the error.
	//See get_test_file() for more details.

	//Get the text in the test file.
	//The only way to get a value out of an enum is pattern matching.
	let all_text : String = match get_test_file() {
		Ok(text) => text,
		Err(error) => file_read_error(error),
	};


	//Parse the text in the input file. See function for more details.
	//Type declaration here is optional, it will be inferred from return type of parse()
	let path : Vec<Node> = parse(all_text);

	//Save the original distance for comparision later.
	let original_distance = total_distance(&path);

	//Get solution. See function for more details.
	//Notice there is no type declaration here. Just demonstrating.
	let solution_path = two_opt(path);

	print_solution(&solution_path);

	//Print original and solution distances for comparision. 
	let totes_distance = total_distance(&solution_path);
	println!("\nOriginal Distance: {}", original_distance);
	println!("Solution Distance: {}", totes_distance);

	//If starting from a280, then solution distance will be:	2756.788
	//If the starting node i is set to 1 instead of 0, then
	//	the solution distance will be:							2727.229
}

fn two_opt(mut path : Vec<Node>) -> Vec<Node> {
	//yeezy 		is index i
	//slim_shady 	is index j
	//For a280.tsp, starting at 1 instead of 0 gives a better solution.
	//	That is, set yeezy = 1 to get a better solution for a280.tsp
	let mut yeezy : usize = 0;
	let mut slim_shady : usize = yeezy;
	//Used to hold the tour length of the current solution
	let mut current_distance = total_distance(&path);
	//Used to indicate that a swap has occured and the loop must start from the beginning
	let mut flag_reset_loop : bool = false;
	//Used to break from the loop if either index variable has increased out of bounds
	let path_length = path.len();
	//Used to teporarily hold the solution path for copying. 
	let mut new_path : Vec<Node> = Vec::new();

	//Attemp each possible swap. For each edge, attempt swap with every other edge.
	//Edges are tracked by the index of the node they start from.
	//There is no need to attempt swapping with edges that come before the current edge because
	//	that combination has already been attempted. Therefore yeezy <= slim_shady
	
	//For loops in Rust work only on iterators, kinda like python.
	//Hence, an infinite loop with break conditions has to be used. 
	//Index variables are modified manually.
	'outer: loop {
		//Break condition. All swaps attepted. Current solution is final solution.
		if yeezy >= path_length {
			break 'outer;
		}

		'inner: loop {
			//Break condition. All edges j for edge i have been attempted. Increment i.
			if slim_shady >= path_length {
				//i will be incremented upon breaking from this loop, but j has to incremented right here
				slim_shady = yeezy+1;
				break 'inner;
			}

			//Test the cuurent swap
			let new_distance = test_distance(yeezy, slim_shady, &path, current_distance);

			if new_distance < current_distance {
				//make the swap
				//Copy the solution to new_path
				new_path.clear();
				new_path.extend_from_slice(swap(yeezy, slim_shady, & mut path));
				//Erase the old path and copy the solution to it.
				path.clear();
				path.extend_from_slice(&new_path);
				//update current_distance
				current_distance = total_distance(&path);
				//restart from very beginning
				flag_reset_loop = true;
				break 'inner;
			}
			//This swap was not an improvement.
			//Increment j
			slim_shady += 1;
		}
		//break 'inner will arrive here.
		if flag_reset_loop {
			//Increment i, set j=i, reset the reset flag, and continue
			yeezy = 1;
			slim_shady = yeezy;
			flag_reset_loop = false;
			continue 'outer;
		}
		//All swaps with this edge i have been attempted, increment i. 
		yeezy += 1;
	}

	path
}

//return the distance between two nodes, indicated by index.
//No error checking. This method is only called by other methods that have error checking
fn distance(yeezy: usize, slim_shady : usize, billboard: &[Node]) -> f32{

	let x_distance = (billboard[yeezy].x - billboard[slim_shady].x) as f32;
	let y_distance = (billboard[yeezy].y - billboard[slim_shady].y) as f32;
	let distance = f32::sqrt(x_distance.powi(2) + y_distance.powi(2));
	distance
}


//Return the total distance of the tour (cyclical tour, so max->0 is included)
fn total_distance(billboard : &[Node]) -> f32{

	let mut distance_accumulator : f32 = 0.0;
	let max_index = billboard.len() - 1;

	//Compute sum of all distances except from last to first.
	//In Rust for loops, the upper bound is excluded. Therefore:
	//	max(index) will be billboard.len()-1-1 = 280-2 = 278
	//So the for loop will compute the sum till index 279
	for index in 0..max_index {
		distance_accumulator += distance(index as usize, index+1 as usize, billboard);
	}
	//Add 279 to 0
	distance_accumulator += distance(max_index as usize, 0 as usize, billboard);

	distance_accumulator
}

//Swap edges
//The vector containing the path is passed as a mutable slice, and the modified slice is returned. 
fn swap(mut yeezy: usize, mut slim_shady : usize, billboard: & mut[Node]) -> & mut [Node]{

	//If the requested swap is the first and last node, then simply swap them.
	if yeezy == 0 && slim_shady == billboard.len()-1 {
		billboard.swap(yeezy, slim_shady);
		billboard
	}
	//If the requested swap is anything else, then reverse all the nodes between the specified nodes inclusive.
	//1 2 3 4 5 6 7 8 9 10 and we want to swap edges between (3,4) and (8,9)
	//Then 3 will be followed by 8, and 4 will be followed by 9.
	//1 2 3 8 7 6 5 4 9 10
	else {
		while yeezy < slim_shady {
			billboard.swap(yeezy, slim_shady);
			yeezy += 1;
			slim_shady -= 1;
		}
		billboard
	}
}

//Virtually swap two nodes and return new distance.
//No swapping actually occurs. The Vector containing the path is passed as an unmuatble slice.
fn test_distance(yeezy: usize, slim_shady : usize, billboard: &[Node], current_distance: f32) -> f32{

	let mut new_distance = current_distance;

	//Swapping with self
	if yeezy == slim_shady {
		return current_distance
	}
	//Edge case handling
	//Swapping the first and last nodes.
	else if yeezy == 0 && slim_shady == billboard.len()-1 {
		new_distance -= distance(0, 1, billboard);
		new_distance -= distance(billboard.len()-2, billboard.len()-1, billboard);
		//Add new edges
		new_distance += distance(billboard.len()-1, 1, billboard);
		new_distance += distance(billboard.len()-2, 0, billboard);

		return new_distance
	}
	//Swapping the first node with some other node except the last
	else if yeezy == 0 && slim_shady != billboard.len()-1{
		new_distance -= distance(billboard.len()-1, yeezy, billboard);
		new_distance -= distance(slim_shady, slim_shady+1, billboard);
		//Add new edges
		new_distance += distance(billboard.len()-1, slim_shady, billboard);
		new_distance += distance(yeezy, slim_shady+1, billboard);

		return new_distance
	}
	//Swapping the last node with some other node except the first.
	else if yeezy != 0 && slim_shady == billboard.len()-1 {
		new_distance -= distance(yeezy-1, yeezy, billboard);
		new_distance -= distance(slim_shady, 0, billboard);

		new_distance += distance(yeezy-1, slim_shady, billboard);
		new_distance += distance(yeezy, 0, billboard);

		return new_distance
	}
	//Swapping a central node with another central node. 
	else {
		new_distance -= distance(yeezy-1, yeezy, billboard);
		new_distance -= distance(slim_shady, slim_shady+1, billboard);
		//Add new edges
		new_distance += distance(yeezy-1, slim_shady, billboard);
		new_distance += distance(yeezy, slim_shady+1, billboard);

		new_distance
	}
}

//Attempt to get the test file.
//This showcases some of Rust's safety measures.
fn get_test_file() -> Result<String, Error> {

	//Get test_file path. Does not need to be in main(). WOW.
	let mut args_iterator = env::args();
	let args_index;
	if args_iterator.nth(1).is_some() {
		//Path has been supplied. Reset iterator so it can be grabbed.
		args_iterator = env::args();
		let possible_run_flag = args_iterator.nth(1).unwrap();
		if possible_run_flag == "-printarray" {
			//test file path shoudl be at index 2 of args
			args_index = 2;
		}
		else{
			//test file path should be at index 1 of args
			args_index = 1;
		}
	}
	else {
		println!("ERROR: No input file specified.");
		exit(0);
	}

	//We know args_iterator.nth(1).is_some() == true so we can "safely" unwrap it.
	//The unwrap function will get the result of success. 
	//If the open errors, then the try! macro will return early
	args_iterator = env::args();
	let mut test_file = try!(File::open(args_iterator.nth(args_index).unwrap()));
	let mut all_text = String::new();
	//If the file is empty or corrupted, then read_to_string will return an error.
	//So it is wrapped in a try! macro, which will early return an error
	try!(test_file.read_to_string(&mut all_text));
	//Phew, all of that worked. all_text now contains the text in the file.
	//Return an Ok()
	Ok(all_text)
}

//To satisfy types, this returns a string. But it will just exit.
fn file_read_error(error: Error) -> String {
	println!("ERROR: File cannot be opened/read.");
	println!("{:?}", error);
	exit(0);
}

//Parse the input file into a Vec<Node>
fn parse(all_text : String) -> Vec<Node> {

	//Find the relevant section. We want the data after "NODE_COORD_SECTION"
	let mut split_point = all_text.find("NODE_COORD_SECTION");

	//Relevant section does not exist.
	if split_point == None {
		println!("ERROR: Input file has invalid syntax. No NODE_COORD_SECTION.");
		exit(0);
	}

	//Dump the data before "NODE_COORD_SECTION". Our data is in all_text
	let (trash, all_text) = all_text.split_at(split_point.unwrap());
	drop(trash);

	//"NODE_COORD_SECTION" is included in all_text so split at the first \n
	split_point = all_text.find("\n");

	//No data
	if split_point == None {
		println!("ERROR: Input file has invalid syntax. No data after NODE_COORD_SECTION");
		exit(0);
	}

	//Dump "NODE_COORD_SECTION\n"
	let (trash, all_text) = all_text.split_at(split_point.unwrap()+1);
	drop(trash);

	//.tsp files contain a literal "EOF"
	split_point = all_text.find("EOF");

	//"EOF" not found
	if split_point == None {
		println!("ERROR: Input file has invalid syntax. No explicit (literal) EOF.");
		exit(0);
	}

	//Dump all the data after "EOF"
	let (all_text, trash) = all_text.split_at(split_point.unwrap()-1);
	drop(trash);


	//Now have list of nodes, in the format "[id] [x] [y]" with one node per line.


	let nodes_iterator = all_text.lines();
	//An array of Nodes
	let mut path : Vec<Node> = Vec::new();

	//Parsing has no error handling. If the data is in an invalid format, the function will fail.
	//Iterate over each line in all_text, and parse the data into Node objects
	for each_node in nodes_iterator {
		//An iterator split by whitespace
		let mut coords_iterator = each_node.split_whitespace();
		//First num will be id
		let id = coords_iterator.next().unwrap().parse::<i32>().unwrap();
		//Second num will be x coordinate
		let x = coords_iterator.next().unwrap().parse::<i32>().unwrap();
		//Third num will be y coordinate
		let y = coords_iterator.next().unwrap().parse::<i32>().unwrap();
		//That should be the end of this line.

		let new_node = Node {id:id, x:x, y:y};
		path.push(new_node);
	}

	path
}

//Print solution path in array format
fn print_array(path : &[Node]){
	print!("[");
	let path_length = path.len();
	let mut counter = 0;
	for each_node in path.iter() {
		print!("{}", each_node.id);
		if counter < path_length-1 {
			print!(", ");
		}
		counter += 1;
	}
	print!("]");
}

//Print solution path in list format (one node ID on each line)
fn print_list(path : &[Node]){
	for each_node in path.iter() {
		println!("{:?}", each_node.id);
	}
}

//Print the solution path as per the flag specified when called
//Defaults to list format (one node ID on each line)
fn print_solution(solution_path : &[Node]){

	//Check if flag -printarray was specified after testfile
	let mut args_iterator = env::args();
	if args_iterator.nth(1).is_some() {
		//Flag has been specified. Reset iterator so it can be grabbed.
		args_iterator = env::args();
		let run_flag = args_iterator.nth(1).unwrap();
		if run_flag == "-printarray" {
			print_array(solution_path);
		}
		else{
			print_list(solution_path);
		}
	}
	else {
		print_list(solution_path);
	}
}