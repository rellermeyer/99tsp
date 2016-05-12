"""
Alissa Hall
CS 345
May 11, 2016

TSP 2-opt algorithm for Python given a pre-existing tour.

Input files must have '.tsp' extension.

"""

from sys import argv
from math import hypot
from timeit import default_timer
from random import randrange

class Node:
	"""
	represents a node in a TSP tour
	"""
	def __init__(self, coords):
		self.num = coords[0] # start position in a route's order
		self.x = coords[1]   # x coordinate
		self.y = coords[2]   # y coordinate

	def __str__(self):
		"""
		returns the string representation of a Node
		"""
		return str(self.num)

	def __eq__(self, other):
		return self.__dict__ == other.__dict__

	def euclidean_dist(self, other):
		"""
		returns the Euclidean distance between this Node and other Node
		other - other node
		"""
		dx = self.x - other.x
		dy = self.y - other.y
		return hypot(dx, dy)

def parse_input_route(filename):
	"""
	returns initial route as read from input file, None if parsing errors occur
	filename - name of the input file with '.tsp' extension
	"""
	f = open(filename, 'r')
	route = []
	dimension = -1 
	dimension_found = False
	node_section_found = False

	# Parse header
	for line in f:
		if "DIMENSION" in line:
			tokens = line.split()
			dimension = int(tokens[-1])
			dimension_found = True
		if "NODE_COORD_SECTION" in line:
			node_section_found = True
			break

	# Check for parsing errors in header
	if not dimension_found:
		print("99 TSP - Parsing error: DIMENSION not found")
		f.close()
		return None
	elif not node_section_found:
		print("99 TSP - Parsing error: NODE_COORD_SECTION header not found")
		f.close()
		return None

	# Parse nodes
	for line in f:
		if "EOF" in line:
			break
		coords = get_coords(line)
		if not coords:
			print("99 TSP - Parsing error: Invalid node data found")
			f.close()
			return None
		route.append(Node(coords))
	f.close()

	# Check for parsing error with nodes
	if len(route) != dimension:
		print("99 TSP - Parsing error: number of nodes found does not match dimension")
		return None

	return route

def get_coords(line):
	"""
	returns the line data as numerals, None if line contains more than 
		3 items or non-numerics in the line
	line - string containing the data
	"""
	data = line.split()
	if len(data) == 3:
		try:
			coords = (int(data[0]), float(data[1]), float(data[2]))
			return coords
		except ValueError:
			pass
	return None

def route_distance(route):
	"""
	returns the distance traveled for a given tour
	route - sequence of nodes traveled, does not include
	        start node at the end of the route
	"""
	dist = 0
	prev = route[-1]
	for node in route:
		dist += node.euclidean_dist(prev)
		prev = node
	return dist

def swap_2opt(route, i, k):
	"""
	swaps the endpoints of two edges by reversing a section of nodes, 
		ideally to eliminate crossovers
	returns the new route created with a the 2-opt swap
	route - route to apply 2-opt
	i - start index of the portion of the route to be reversed
	k - index of last node in portion of route to be reversed
	pre: 0 <= i < (len(route) - 1) and i < k < len(route)
	post: length of the new route must match length of the given route 
	"""
	assert i >= 0 and i < (len(route) - 1)
	assert k > i and k < len(route)
	new_route = route[0:i]
	new_route.extend(reversed(route[i:k + 1]))
	new_route.extend(route[k+1:])
	assert len(new_route) == len(route)
	return new_route

def run_2opt(route):
	"""
	improves an existing route using the 2-opt swap until no improved route is found
	best path found will differ depending of the start node of the list of nodes
		representing the input tour
	returns the best path found
	route - route to improve
	"""
	improvement = True
	best_route = route
	best_distance = route_distance(route)
	while improvement: 
		improvement = False
		for i in range(len(best_route) - 1):
			for k in range(i+1, len(best_route)):
				new_route = swap_2opt(best_route, i, k)
				new_distance = route_distance(new_route)
				if new_distance < best_distance:
					best_distance = new_distance
					best_route = new_route
					improvement = True
					break #improvement found, return to the top of the while loop
			if improvement:
				break
	assert len(best_route) == len(route)
	return best_route

def print_results(route, filename, time, startnode):
	"""
	prints the nodes in the final route and route information
	route - route to print
	filename - name of the original input filename
	time - time to run 2opt
	startnode - start node of original tour if randomized
	"""
	for node in route:
		print(node)
	print(-1)
	print("Original input file : " + filename)
	print("Dimension : " + str(len(route)))
	if startnode:
		print("Randomized start node : " + str(startnode))
	print("Total Distance : " + str(route_distance(route)))
	print("Time to run 2opt : %.2f seconds" % time)


def main():
	# Check to make sure input file is given
	if len(argv) == 1:
		print("99 TSP - No input file")
		return
	# Check to make sure input file is correct type	
	elif ".tsp" != argv[1][-4:]:
		print("99 TSP - Input file must contain \'.tsp\' extension")
		return

	# Terminate early if parsing errors are found
	route = parse_input_route(argv[1])
	if not route:
		return

	# Option to randomize 'start' of route
	r = None
	if len(argv) == 3 and argv[2] == "-r":
		r = randrange(0, len(route))
		new_route = route[r:] + route[0:r]
		assert len(new_route) == len(route)
		route = new_route
		r = route[0]

	# Run 2opt
	start = default_timer() #start time of running 2opt
	route = run_2opt(route)
	end = default_timer()   #end time of running 2opt
	print_results(route, argv[1], (end - start), r)

if __name__ == "__main__":
	main()
