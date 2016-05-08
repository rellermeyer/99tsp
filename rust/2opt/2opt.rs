#![allow(warnings)]
use std::env;
use std::io::prelude::*;
use std::fs::File;
use std::process::exit;
use std::collections::linked_list::LinkedList;


struct Node {
	index : i32,
	id : i32,
	x : i32,
	y : i32,
}

fn main() {
	println!("\n\n--\nTesting\n--\n\n");

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

	let mut path : LinkedList<Node> = LinkedList::new();
	// let mut nodes_flag : bool = false;
	let mut temp_id : i32 = 0;
	let mut temp_x : i32 = 0;
	let mut temp_y : i32 = 0;
	let mut counter : i32 = 1;


	for each_node in nodes_iterator {
		
		let mut coords_iterator = each_node.split_whitespace();
		//First num will be id
		temp_id = coords_iterator.next().unwrap().parse::<i32>().unwrap();
		//Second num will be x coordinate
		temp_x = coords_iterator.next().unwrap().parse::<i32>().unwrap();
		//Third num will be y coordinate
		temp_y = coords_iterator.next().unwrap().parse::<i32>().unwrap();
		//That should be the end of this line.

		let mut new_node = Node {index:counter, id:temp_id, x:temp_x, y:temp_y};
		// println!("Adding Node ({}, {}, {}, {})", new_node.index, new_node.id, new_node.x, new_node.y);
		path.push_back(new_node);

		counter += 1;
	}

	// let mut path_iterator = path.iter();
	// println!("{:?}", path_iterator.nth(26).unwrap().y);

	println!("\n\n--\nEND\n--\n\n");
}