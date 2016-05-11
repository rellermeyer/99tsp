//TSP Simulate Annealing implementation
//Author: David Talamas
//CS345 assignment 6
//May 10, 2016

#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <stdlib.h>
#include <math.h>
#include <time.h>

using namespace std;

//Graph represented as a vector of points (x,y)
class Graph{
public: 
  vector<pair<int, int> > nodes;
};

//Get euclidian distance between two points
double dist(pair<int, int> a, pair<int, int> b){
  double xd = a.first - b.first;
  double yd = a.second - b.second;
  return sqrt(xd * xd + yd * yd);
}

double pathCost(vector<pair<int, int> > &nodes, vector<int> &path){
  double cost = 0;
  for (int i = 0; i < nodes.size() - 2; i++){
    cost += dist(nodes[path[i]], nodes[path[i+1]]);
  }
  cost += dist(nodes[path[nodes.size()-2]], nodes[path[0]]);
  return cost;    
}

//Prints tour
void printTour(vector<int> &tour){
  cout<<"Tour:\n";
  for (vector<int>::iterator it = tour.begin(); it != tour.end(); ++it){
    cout<<*it<<"\n";
  }
  return;
}

//Gets randomly a neighboring state
vector<int> nextState(vector<int> s){
  vector<int> newState = s;
  int a,b;
  a = rand() % s.size();
  b = rand() % s.size();
  int temp = newState[a];
  newState[a] = newState[b];
  newState[b] = temp;
  return newState;
}

//returns true with probability P = exp(-(cost2-cost1)/T);
bool flipCoin(double cost1, double cost2, double T){
  double p = exp(-(cost2-cost1)/T);
  double u = ((double) rand() / (RAND_MAX));
  if (u < p){
    return true;
  }
  else {
    return false;
  }
}

int main(int argc, char* argv[]){
  srand(time(NULL));
  if (argc != 2){
    cout<<"Wrong args";
    return 0;
  }
  //Get the data from the given file
  char *path = argv[1];
  ifstream f; 
  f.open(path, ios::in);
  Graph g;
  int size = 0;
  if (f.is_open()){
    string line;
    while (getline(f, line)){
      if (line.length()> 9 && line.substr(0,9).compare("DIMENSION")==0){
	size = atoi(line.substr(11,line.length()-11).c_str());
	break;
      }
    }
    g.nodes.resize(size + 1);
    while (getline(f, line)){
      if (line.length()>3 && line[2]<= '9' && line[2]>= '0'){
	int index = atoi(line.substr(0,3).c_str());
	int x = atoi(line.substr(4,3).c_str());
	int y = atoi(line.substr(8,3).c_str());
	g.nodes[index].first = x;
	g.nodes[index].second = y;
      }
    }
  }
  f.close();

  //Choose initial tour randomly
  vector<int> tour(size, 0);
  int nums[280] = {0};
  for (int i = 1; i <= size; i++){    
    //tour[i-1] = i;
    while(1){
      int r = rand() % size;
      if (nums[r] == 0){
	tour[i-1] = r;
	nums[r] = 1;
	break;
      }
    }
  }

  
  double min = pathCost(g.nodes, tour);
  vector<int> minTour = tour;
  double T = 100; 
  
  //Simulated annealing
  while (T > .0001){
    //Iterate 100 times for each temperature
    for (int q = 0; q <100; q++){
      vector<int> s_ = nextState(tour);
      double prevCost = pathCost(g.nodes, tour);
      double newCost = pathCost(g.nodes, s_);
      if (newCost < prevCost){
	tour = s_;
	if (newCost < min){
	  min = newCost;
	  minTour = tour;
	}
      } 
      else if (flipCoin(prevCost, newCost, T)) {
	tour = s_;
      }
    }
    T *= .9999;
  }

  //Print results
  cout<<"Cost: "<<pathCost(g.nodes, minTour)<<" \n";
  printTour(tour);
  return 0;
  

}
