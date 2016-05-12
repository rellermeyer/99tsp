2-opt algorithm for approximating a solution to TSP, written in Python.
Takes about 1 minute to run for a280.tsp.

To run:
	make run

The resulting tour will differ depending on which node starts the list of nodes representing the input tour.

To run with randomized start node:
	make run_random

Set TEST_FILE in Makefile to change the input file (currently a280.tsp).
Input files must have '.tsp' extension.
