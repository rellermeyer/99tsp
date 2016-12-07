from elastic import ElasticNet 
import numpy as np
import optparse
import os 
import sys

def main():
	options, args = parse_arguments()

	# load in parameters
	name, cities = load_instance(args[0])
	n_iters = options.n_iters
	neuron_factor = options.neuron_factor
	alpha = options.alpha
	beta = options.beta
	radius = options.radius

	cities_norm = normalize_cities(cities)
	elastic_net = ElasticNet(n_iters, neuron_factor, alpha, beta, radius)
	elastic_net.fit(cities_norm)

def load_instance(path):
	"""load instance of TSP from file"""
	cities = []
	with open(path, 'r') as f:
		line = f.readline().strip().split()
		name = line[2]
		while line != "NODE_COORD_SECTION":
			line = f.readline().strip()
		for line in f:
			line = line.strip().split()
			if line[0] == "EOF":
				break
			x, y = line[1], line[2]
			cities.append((int(x), int(y)))

	return name, np.array(cities)

def normalize_cities(cities):
	"""normalize cities to aid in convergence"""
	min = np.min(cities, axis=0)
	max = np.max(cities, axis=0)
	return (cities - min) / (max - min)

def parse_arguments():
	parser = optparse.OptionParser("Usage: %prog file [options]")
	parser.add_option("-a",
					  type = float,
					  dest = "alpha",
					  default = 0.2)

	parser.add_option("-b",
					  type = float,
					  dest = "alpha",
					  default = 2.0)

	parser.add_option("-i",
					  type = int,
					  dest = "n_iters",
					  default = 50)

	parser.add_option("-f",
					  type = float,
					  dest = neuron_factor,
					  default = 2.5)

	parser.add_option("-r",
					  type = float,
					  dest = radius, 
					  default = 0.1)

	options, args = parser.parse_args()
	if len(args) != 1:
		print("Must pass in a filename")
		sys.exit(-1)

	return options, args


def get_solution_permutation(dists):
	"""find the permutation of cities which solves the instance"""



def pairwise(iterable):
    "s -> (s0,s1), (s1,s2), (s2, s3), ..."
    a, b = tee(iterable)
    next(b, None)
    return zip(a, b)

if __name__ == '__main__':
	main()

