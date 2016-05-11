//Graph implementation
//Author: Ginevra Gaudioso
//CS345 assignment 6
//May 5, 2016


#ifndef GRAPH_H_
#define GRAPH_H_

#include <iostream>
#include <vector>

using namespace std;

class Graph {
public:
	Graph(char* path) throw();  //constructor
	int getsize(); //gets size of graph, as number of nodes
	int getstart(); //gets starting node
	int getclosest(int a); //gets closest non visited node from a
	double getcost(vector<int> tour); //gets cost of path starting from a
	virtual ~Graph();  //destructor

private:
	int num_nodes; //1+ the number of nodes (ie size of below)
	int** array_of_nodes; //array representing graph (as noodes coordinates)
	double getdistance(int a, int b);
};

#endif /* GRAPH_H_ */
