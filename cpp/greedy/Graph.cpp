//Graph implementation
//Author: Ginevra Gaudioso
//CS345 assignment 6
//May 5, 2016


#include "Graph.h"

#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>
#include <math.h>
#include <cfloat>


#define X 0     //x coord position
#define Y 1     //y coord position
#define VIS 2   //visited flag position

using namespace std;

//constructor of Graph
Graph::Graph(char* path) throw() {

	//1. open input file, which is assumed to be in the format of a280.tsp
	ifstream graphFile; //create input stream
	graphFile.open(path,ios::in); //use stream to read the file

	if (graphFile.is_open()) {
		string line;

		//2. get number of nodes in the graph
		int size=0; //initialize size
		while (getline(graphFile, line)) {
			if (line.length()>9 && (line.substr(0,9)).compare("DIMENSION")==0) {
				//save size = number of nodes in the graph, as integer, and leave
				size = atoi(line.substr(11,line.length()-11).c_str());
				break;
			}
		}
		if (size==0) { //size was not set, thus file format must be wrong
			cout << "no dimension specified in file" << endl;
			throw;
		}

		//3. allocate array to store nodes and visited, and save size
		array_of_nodes = new int*[size+1]; //+1 to correct 0 base to 1 base
		num_nodes = size;

		//4. fill in array with coordinates
		while (getline(graphFile, line)) {
			if (line.length()>3 && line[2]<='9' && line[2]>='0') {
				int index = atoi(line.substr(0,3).c_str()); //index is node number, which will go from 1 to size
				int x = atoi(line.substr(4,3).c_str()); //get x coordinate
				int y = atoi(line.substr(8,3).c_str()); //get y coordinate
				array_of_nodes[index] = new int[3]; //3 = x coord, y coord, visited flag
				array_of_nodes[index][X] = x; //save x coordinate
				array_of_nodes[index][Y] = y; //save y coordinate
				array_of_nodes[index][VIS] = 0; //not visited
			}
		}
	}
	else { //file cannot be read
		cout << "cannot read file" << endl;
		throw;
	}
	//5. done with file
	graphFile.close();

	//Graph is stored as array <node number> <xcoord> <ycoord> <visited>
}

//returns size of graph as number of nodes
int Graph::getsize() {
	return num_nodes;
}

//returns start node of graph
int Graph::getstart() {
//here I decided to have an arbitrary start, instead of checking which starting point would provide the best greedy solution
//It is possible to add a for loop into main "for i from getstart to getsize" and then pick the least cost route, but that adds an order to the complexity
	return 1;
}


//finds the distance between node a and b
double Graph::getdistance(int a, int b) {
	if (a<1 || a>num_nodes || b<1 || b>num_nodes) //not a valid node for this graph
		return -1;
	else {
		int xdist = array_of_nodes[a][X]-array_of_nodes[b][X];
		int ydist = array_of_nodes[a][Y]-array_of_nodes[b][Y];
		return sqrt(pow(xdist,2)+pow(ydist,2));
	}
}

//gets closest non visited node from a
int Graph::getclosest(int a) {
	if (a<1 || a>num_nodes) //not a valid node for this graph
			return -1;
	array_of_nodes[a][VIS] = 1; //starting point is visited
	double mindist = DBL_MAX; //initialize minimum
	int minnode = -1; //initialize to negative as flag
	for (int i=1; i<=num_nodes;i++){
		if (array_of_nodes[i][VIS]==0) { //not visited
			double dist = getdistance(a,i); //get distance from a to i
			if (dist <= mindist)  {
				mindist = dist; //update min dist
				minnode = i; //save closest node
			}
		}
	}
	if (minnode != -1) array_of_nodes[minnode][VIS] = 1; //set end point to visited
	return minnode;
}


//get cost of tour
double Graph::getcost(vector<int> tour) {
	if (tour.empty()) //invalid input
		return -1;
	vector<int>::iterator it = tour.begin(); //iterator on tour vector
	int start = *it; //save starting point
	int a = start;
	int b = -1;
	double cost = 0; //returned cost
	it++;
	for (;it!=tour.end();++it){
		b = *it;
		cost += getdistance(a,b); //add up
		a = b;
	}
	cost += getdistance(b,start); //add up last edge
	return cost;
}


//destructor of Graph, called with delete
Graph::~Graph() {
	//need to release memory of array
	for (int i=1;i<=num_nodes;i++)
		delete[] array_of_nodes[i]; //free each row
	delete[] array_of_nodes; //free array
}

