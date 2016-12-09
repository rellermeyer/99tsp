# tspsa (Traveling Salesman Problem: Simulated Annealing)

## Description
Implementation of the Traveling Salesman Problem (TSP) using the Simulated Annealing (SA) Algorithm written in GO. The implementation creates a tspsa package that can be redistributed to run the SA algorithm. I created a random testing framework to create random nodes in an x,y map. This will also run any .tsp formatted file, but will not work, currently, with any other filetype. To force test a solution without creating a TSP file, you can create Nodes and add them to the map programaticly.  

## Contributors
- Spencer Bull (bullapse) [sgb695]

## Usage
The following will return a path of Nodes in the shortest distance as a splice of Nodes ([]Node) containing *x* and *y* coordinates
- `RunSARandom(itterations (int), temperature (float64), Mintemp (float64), coolrate (float64), max x cordinate (int), max y coordinate (int), number of locations (int), verbose (bool))`
- `RunSAFromFile(itterations (int), temperature (float64), Mintemp (float64), cool rate (float64), filename (string))`

## Testing
- Running via make `make` in the sa directory will run a simple test on the a280.tsp test.
- `go build; go test` will run a few tests in the `tspsa_test.go` file including random nodes on a map.
 
 #### Citation
 - Simulated Annealing Algorithm is based off of the following as guidance to implement the algorithm.
 - http://katrinaeg.com/simulated-annealing.html
