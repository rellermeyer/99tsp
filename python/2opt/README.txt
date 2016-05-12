2opt algorithm for approximating a solution to TSP, written in Python.
Takes about 1 minute to run for a280.tsp input with a distance of 2741.804.

Resulting tour will differ depending on the order of edges evaluted and switched or in this case, which node starts the list of nodes represented an input tour.

To run with default input:
	make run

To run with default input and randomized start node of the node list:
	make run_random

Input file is set to a280.tsp by default.
To change this, change TEST_FILE in Makefile to desired input file.
Input files must have '.tsp' extension.
