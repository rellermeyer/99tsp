"""Python implementation of the elastic net algorithm to solve the Traveling Salesman Problem"""
import numpy as np
from scipy.spatial.distance import cdist
import itertools
import matplotlib.pyplot as plt
import seaborn as sns

class ElasticNet:
    def __init__(self, n_iters=30, neuron_factor=2.5, alpha=0.4, beta=2.0, radius=0.1, plotting=False):
        self._n_iters = n_iters
        self._neuron_factor = neuron_factor
        self._alpha = alpha
        self._beta = beta
        self._radius = radius
        self._plotting = plotting

    def _city_force(self):
        """compute first two terms in update
        1. force enacted on neruons by cities, allowing elastic to expand
        2. force which keeps neurons evenly distributed about the ring"""
        return np.einsum('ij,ijk->jk', self._w, self._delta), np.dot(self._s.T, self._near_delta)

    def _neuron_force(self):
        """compute force enacted on neurons by other neurons
        which minimizes the length of the elastic"""
        nshape = self._neurons.shape

        temp_neurons = np.concatenate((self._neurons[-1,np.newaxis], 
                                       self._neurons,
                                       self._neurons[0,np.newaxis]))
        return np.array([
            (temp_neurons[i+1] + temp_neurons[i-1] - 2 * temp_neurons[i]) 
            for i in range(1, temp_neurons.shape[0]-1) ])

    def _update_K(self):
        """update K as the average squared distance between 
        each city and its closest neuron on the tour"""
        self._K = np.mean(self._near_d2)
        # solution diverges if K becomes too small
        if self._K < 0.01:
            self._K = 0.01

    def _update_neurons(self):
        """update neurons as gradient of the energy function"""
        fw,fs = self._city_force()
        term1 = self._alpha * fw
        term2 = self._alpha * fs
        term3 = self._beta * self._K * self._neuron_force() 
        self._neurons += (term1 + term2 + term3)

    def _update_weights(self):
        """compute both sets of weights, w_ij and s_ij"""

        def phi(d, K):
            return np.exp(-d**2 / (2*K**2))

        # compute difference between each city and neuron: (dx, dy)
        self._delta = self._cities[:,np.newaxis] - self._neurons 
        self._dists = cdist(self._cities, self._neurons)
        # nearest neurons to every city
        near_neurons = self._neurons[np.argmin(self._dists, axis=1)]
        # difference between each city and its nearest neuron
        self._near_delta = self._cities - near_neurons
        self._near_d2 = np.sum(self._near_delta**2, axis=1)
        # distance from nearest neuron to each city and the other neurons
        self._near_dists = cdist(near_neurons, self._neurons)

        # update K here since it needs squared distance b/w each city and its 
        # closest neuron
        self._update_K()

        # compute and normalize weights
        self._s = phi(self._near_dists, self._K)
        self._s /= np.sum(self._s, axis=1)[:,np.newaxis]
        self._w = phi(self._dists, self._K)
        self._w /= np.sum(self._w, axis=1)[:,np.newaxis]

    def _init_neurons(self, size):
        """Initialize neurons in ring of given radius about the center of the cities"""
        center = self._cities.mean(axis=0)
        neurons = np.linspace(0, 2*np.pi, size, False)
        neuron_ring = np.array([np.cos(neurons), np.sin(neurons)])
        neuron_ring *= self._radius
        neuron_ring += center[:,np.newaxis]
        return neuron_ring.T

    def _pairwise(self, iterable):
        a,b = itertools.tee(iterable)
        next(b, None)
        return zip(a,b)

    def fit(self, cities):
        """fit neurons to given instance of TSP"""
        self._cities = cities
        self._neurons = self._init_neurons(cities.shape[0] * self._neuron_factor)

        for i in range(self._n_iters):

            self._iter = i + 1

            # uncomment to get a slideshow
            if self._plotting:
                fig, ax = plt.subplots()
                ax.scatter(self._cities[:,0], self._cities[:,1], c='red')
                ax.scatter(self._neurons[:,0], self._neurons[:,1], c='blue')
                tn = np.vstack((self._neurons, self._neurons[0]))
                edges = list(self._pairwise(tn))
                for e in edges:
                    plt.plot([e[0][0], e[1][0]],[e[0][1], e[1][1]], c='green')
                plt.show()

            self._update_weights()
            self._update_neurons()

    def get_solution_permutation(self):
        """return the permutation of cities which the algorithm has chosen"""
        pairs = []
        distances = self._dists

        for i in range(self._cities.shape[0]):
            city = np.min(distances, axis=1).argmin()
            neuron = np.argmin(distances[city])

            distances[city] = np.inf
            distances[:,neuron] = np.inf

            pairs.append((neuron, city))

        pairs.sort(key=lambda x: x[0])
        return [x[1] for x in pairs]

    def get_tour_length(self, city_permutation, original_cities):
        city_permutation.append(city_permutation[0])
        edges = list(self._pairwise(city_permutation))
        length = np.sum([cdist(original_cities[e[0],np.newaxis], 
            original_cities[e[1],np.newaxis]) for e in edges])
        return edges, length





