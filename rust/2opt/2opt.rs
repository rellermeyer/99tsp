#![allow(warnings)]
use std::env;
use std::io::prelude::*;
use std::fs::File;
use std::process::exit;
use std::collections::linked_list::LinkedList;
use std::f32;
use std::clone;

#[derive(Clone)]
struct Node {
	id : i32,
	x : i32,
	y : i32,
}


fn main() {
	// println!("\n\n--\nTesting\n--\n\n");

	//Get test_file path
	let mut args_iterator = env::args();
	let mut path_string = String::new();
	if args_iterator.nth(1).is_some() {
		args_iterator = env::args();
		path_string = args_iterator.nth(1).unwrap();
		// println!("TestFile Path: {}\n", path_string);
	}
	else {
		println!("ERROR: No input file specified.");
		exit(0);
	}


	let mut test_file = File::open(path_string).unwrap();
	let mut all_text = String::new();
	test_file.read_to_string(&mut all_text);
	// println!("\nFile contents:\n{}\nEND File contents\n", all_text);

	let mut split_point = all_text.find("NODE_COORD_SECTION");

	if split_point == None {
		println!("ERROR: Input file has invalid syntax. No NODE_COORD_SECTION.");
		exit(0);
	}

	let (trash, nodes_text) = all_text.split_at(split_point.unwrap());
	drop(trash);
	
	split_point = nodes_text.find("\n");

	if split_point == None {
		println!("ERROR: Input file has invalid syntax. No data after NODE_COORD_SECTION");
		exit(0);
	}

	let (trash, nodes_text) = nodes_text.split_at(split_point.unwrap()+1);
	drop(trash);

	split_point = nodes_text.find("EOF");

	if split_point == None {
		println!("ERROR: Input file has invalid syntax. No explicit (literal) EOF.");
		exit(0);
	}

	let (nodes_text, trash) = nodes_text.split_at(split_point.unwrap()-1);
	drop(trash);

	// println!("\nnodes_text:\n{}", nodes_text);
	// println!("-\nEND nodes_text\n");


	let nodes_iterator = nodes_text.lines();

	let mut path : Vec<Node> = Vec::new();
	let mut temp_id : i32 = 0;
	let mut temp_x : i32 = 0;
	let mut temp_y : i32 = 0;


	for each_node in nodes_iterator {
		
		let mut coords_iterator = each_node.split_whitespace();
		//First num will be id
		temp_id = coords_iterator.next().unwrap().parse::<i32>().unwrap();
		//Second num will be x coordinate
		temp_x = coords_iterator.next().unwrap().parse::<i32>().unwrap();
		//Third num will be y coordinate
		temp_y = coords_iterator.next().unwrap().parse::<i32>().unwrap();
		//That should be the end of this line.

		let mut new_node = Node {id:temp_id, x:temp_x, y:temp_y};
		// println!("Adding Node ({}, {}, {}, {})", new_node.index, new_node.id, new_node.x, new_node.y);
		path.push(new_node);
	}

	// println!("{}, {}, {}, {}", path[26].index, path[26].id, path[26].x, path[26].y);
	let mut yeezy : usize = 1;
	let mut slim_shady : usize = yeezy;
	let mut new_distance : f32 = 0.0;
	let mut current_distance = total_distance(&path);
	let mut flag_reset_loop : bool = false;
	let path_length = path.len();
	let mut counter : u64 = 0;
	let mut new_path : Vec<Node> = Vec::new();

	//Attemp each possible swap
	'outer: loop {
		if yeezy >= path_length {
			break 'outer;
		}
		// if counter >= 500 {
		// 	break 'outer;
		// }
		'inner: loop {
			if slim_shady >= path_length {
				slim_shady = yeezy+1;
				break 'inner;
			}
			// println!("Testing {}[{}]\t{}[{}]", yeezy, path[yeezy].id, slim_shady, path[slim_shady].id);
			// let current_distance = distance(yeezy, slim_shady, &path);
			new_distance = test_distance(yeezy, slim_shady, &path, current_distance);
			if new_distance < current_distance {
				// println!("FOUND BETTER PATH by swapping {} and {}\t\t{}", yeezy, slim_shady, counter);
				// println!("{:?}", current_distance);
				// println!("{:?}", new_distance);
				
				//make the swap
				new_path.clear();
				new_path.extend_from_slice(swap(yeezy, slim_shady, & mut path));
				// v.extend(s.iter().cloned());
				path.clear();
				path.extend_from_slice(&new_path);
				//update current_distance
				current_distance = total_distance(&path);
				//restart from very beginning
				flag_reset_loop = true;
				counter += 1;
				break 'inner;
			}
			// println!("Distance from {} to {} = {}", yeezy, slim_shady, current_distance);
			slim_shady += 1;
		}
		if flag_reset_loop {
			yeezy = 1;
			slim_shady = yeezy;
			flag_reset_loop = false;
			continue 'outer;
		}
		yeezy += 1;
	}
	// println!("current_distance:\t{}", current_distance);
	// new_distance = test_distance(1, 3, &path, current_distance);

	// println!("new_distance:\t{}", new_distance);

	// path.swap(1, 3);

	

	//Print IDs for verification
	for eachNode in path.iter() {
		println!("{:?}", eachNode.id);
	}

	let totes_distance = total_distance(&path);
	println!("TOTAL DISTANCE: {}", totes_distance);

	// println!("\n\n--\nEND\n--\n\n");
}

//return the distance between two nodes
fn distance(yeezy: usize, slim_shady : usize, billboard: &[Node]) -> f32{
	let mut distance : f32 = 0.0;
	let mut x_distance: f32 = 0.0;
	let mut y_distance: f32 = 0.0;
	x_distance = (billboard[yeezy].x - billboard[slim_shady].x) as f32;
	y_distance = (billboard[yeezy].y - billboard[slim_shady].y) as f32;
	distance = x_distance.powi(2) + y_distance.powi(2);
	distance = distance.sqrt();

	distance

}

//Return the total distance of the tour (index 0 to max)
fn total_distance(billboard : &[Node]) -> f32{
	let mut distance_accumulator : f32 = 0.0;
	let max_index = billboard.len() - 1 - 1;

	//Compute sum of all distances except from last to first.
	for index in 0..max_index {
		distance_accumulator += distance(index as usize, index+1 as usize, billboard);
	}

	distance_accumulator += distance(max_index+1 as usize, 0 as usize, billboard);

	distance_accumulator
}

//Swap edges
fn swap(mut yeezy: usize, mut slim_shady : usize, billboard: & mut[Node]) -> & mut [Node]{
	while yeezy < slim_shady {
		billboard.swap(yeezy, slim_shady);
		yeezy += 1;
		slim_shady -= 1;
	}
	billboard
}

//Virtually swap two nodes and return new distance.
//No swapping actually occurs. Vector is unmuatable.
fn test_distance(yeezy: usize, slim_shady : usize, billboard: &[Node], current_distance: f32) -> f32{

	let mut new_distance = current_distance;

	if yeezy == slim_shady {
		return current_distance
	}

	//Edge case handling.
	// if yeezy == billboard.len()-1 {
	// 	new_distance -= distance(yeezy, 0, billboard);
	// 	new_distance -= distance(slim_shady, slim_shady+1, billboard);

	// 	new_distance += distance(yeezy, slim_shady, billboard);
	// 	new_distance += distance(0, slim_shady+1, billboard);

	// 	return new_distance
	// }

	if slim_shady == billboard.len()-1 {
		new_distance -= distance(yeezy-1, yeezy, billboard);
		new_distance -= distance(slim_shady, 0, billboard);

		new_distance += distance(yeezy-1, slim_shady, billboard);
		new_distance += distance(yeezy, 0, billboard);

		return new_distance
	}

	
	//Remove yeezy->yeezy+1 and slim_shady->slim_shady+1 
	//Remove old edges
	new_distance -= distance(yeezy-1, yeezy, billboard);
	new_distance -= distance(slim_shady, slim_shady+1, billboard);
	//Add new edges
	new_distance += distance(yeezy-1, slim_shady, billboard);
	new_distance += distance(yeezy, slim_shady+1, billboard);

	new_distance

}