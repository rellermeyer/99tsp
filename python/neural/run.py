from elastic import ElasticNet 
from scipy.spatial.distance import pdist
import itertools
import numpy as np
import optparse
import os 
import sys
import matplotlib.pyplot as plt
import seaborn as sns

def main():
    options, args = parse_arguments()

    # load in parameters
    cities = load_instance(args[0])

    n_iters = options.n_iters
    neuron_factor = options.neuron_factor
    alpha = options.alpha
    beta = options.beta
    radius = options.radius
    plotting = options.plots
    slides = options.slides

    norm_cities = normalize_cities(cities)
    elastic_net = ElasticNet(n_iters, neuron_factor, alpha, beta, radius, slides)
    print()
    print("Fitting Elastic Net having parameters: \
        \n Iterations: {n_iters} \
        \n neurons: {neurons} \
        \n alpha: {alpha} \
        \n beta: {beta} \
        \n radius: {radius}".format(n_iters=n_iters, neurons=int(cities.shape[0]*neuron_factor), 
                                   alpha=alpha, beta=beta, radius=radius))

    elastic_net.fit(norm_cities)

    city_permutation = elastic_net.get_solution_permutation()
    edges, tour_length = elastic_net.get_tour_length(city_permutation, cities)

    print_solution(city_permutation, tour_length)

    if plotting:
        plot_solution(cities, edges)

def plot_solution(cities, edges):
    fig, ax = plt.subplots()
    ax.scatter(cities[:,0], cities[:,1])
    for e in edges:
        plt.plot([cities[e[0],0], cities[e[1],0]], [cities[e[0],1], cities[e[1],1]], c='green')
    plt.show()

def print_solution(city_permutation, tour_length):
    print()
    print("---SOLUTION---")
    print("Tour Length: %d" % tour_length)

def load_instance(path):
    """load instance of TSP from file"""
    print("Loading Instance from %s..." % path.split("/")[-1])
    cities = []
    with open(path, 'r') as f:
        line = ""
        while line != "NODE_COORD_SECTION" and line != "DISPLAY_DATA_SECTION":
            line = f.readline().strip()
        for line in f:
            line = line.strip().split()
            if line[0] == "EOF" or line[0] == "TOUR_SECTION":
                break
            x, y = line[1], line[2]
            cities.append((float(x), float(y)))
    print("Finished Loading file")
    return np.array(cities)

def normalize_cities(cities):
    """normalize cities to aid in convergence"""
    min = np.min(cities, axis=0)
    max = np.max(cities, axis=0)
    return (cities - min) / (max - min)

def parse_arguments():
    parser = optparse.OptionParser("Usage: %prog <file.tsp> [options]")
    parser.add_option("-a",
                      type = float,
                      dest = "alpha",
                      default = 0.4)

    parser.add_option("-b",
                      type = float,
                      dest = "beta",
                      default = 2.0)

    parser.add_option("-i",
                      type = int,
                      dest = "n_iters",
                      default = 30)

    parser.add_option("-f",
                      type = float,
                      dest = "neuron_factor",
                      default = 2.5)

    parser.add_option("-r",
                      type = float,
                      dest = "radius", 
                      default = 0.1)

    parser.add_option("-p", "--plot",
                      action = "store_true",
                      dest = "plots",
                      default = False,
                      help = "Enable Plotting")

    parser.add_option("-s", "--slideshow",
                      action = "store_true",
                      dest = "slides",
                      default = False,
                      help = "Show Neurons Every Iteration")

    options, args = parser.parse_args()
    if len(args) != 1:
        print("Must pass in a filename")
        sys.exit(-1)

    return options, args

if __name__ == '__main__':
    main()

