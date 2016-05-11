//TSP greedy algorithm implementation
//Author: Ginevra Gaudioso
//CS345 assignment 6
//May 5, 2016


#include "Graph.h"

#include <iostream>
#include <fstream>
#include <vector>

using namespace std;


//method to approximate TSP with greedy algorithm
//graph = reference to created object Graph
//solution = vector to be filled in with the solution path
//returns the cost of the solution path
double tspgreedy(Graph* graph,vector<int>* solution) {
	int start = graph->getstart(); //get starting node
	solution->push_back(start); //push start
	int next = graph->getclosest(start); //get next
	while (next != -1) { //while we have a next
		//cout << "next " << next << endl;
		solution->push_back(next); //add closest
		next = graph->getclosest(next); //update closest
	}
	return graph->getcost(*solution);
}


int main(int argc,char*argv[]) {

	if (argc!=2) { //maybe need 1, test with make file
		cout << "please include directory of test file in args" << endl;
		return 0;
	}

	char* path = argv[1]; //might need 0, test with make

	Graph* graph = new Graph(path); //create graph
	vector<int> solution; //create vector for solution

	double cost = tspgreedy(graph,&solution); //get approximate solution with greedy algorithm

	delete graph; //done with graph


	cout << "TSPgreedy cpp run" << endl;

	//now save results into file
	ofstream results;
	remove("results.txt");
	results.open("results.txt",ios::out);
	if (!results.is_open()) {
		cout << "cannot open file" << endl;
	}
	else {
		cout << "TSPgreedy cpp results are in cpp/greedy/results.txt file" << endl;
		results << "cost: " << cost << endl;
		results << "tour: " << endl;
		vector<int>::iterator it = solution.begin();
		for (;it!=solution.end();++it)
			results << *it << endl;
		results.close();
	}

	return 0;

}
