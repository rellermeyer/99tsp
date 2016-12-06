# tspsa (Traveling Salesman Problem: Simulated Annealing)

## Description
Implementation of the Traveling Salesman Problem (TSP) using the Simulated Annealing (SA) Algorithm written in GO.

## Contributors
- Spencer Bull (bullapse) [sgb695]

## Usage
The following will return a path of Nodes in the shortest distance as a splice of Nodes ([]Node) containing *x* and *y* corridinates
- `RunSARandom(itterations (int), temperature (float64), Mintemp (float64), coolrate (float64), max x cordinate (int), max y cordinate (int), number of locations (int), verbose (bool))`
- TODO: `RunSAFromFile(itterations (int), temperature (float64), Mintemp (float64), coolrate (float64), filename (string))`

## Testing
- `go build; go test` will run a few tests in the `tspsa_test.go` file 
 
 #### Citation
 - http://katrinaeg.com/simulated-annealing.html
