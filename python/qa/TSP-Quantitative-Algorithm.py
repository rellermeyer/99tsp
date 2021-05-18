###############################################################################
# Matheus Lima
# Universidade Federal de Sao Carlos, Brazil
# 2021
###############################################################################

import sys
import math
import random
import copy


DEBUG_SET = True

def debug(label, _str, stop=False, key="none_", write_to_file=True):
    if DEBUG_SET == True:
        print(key + label, _str)

        if write_to_file == True:
            filename = "./output/"+key+"."+label+".txt"
            filename = filename.replace(" ", "")
            f = open(filename, "a")
            f.write(str(_str)+"\n")
            f.close()

    if stop == True:
        input()
    else:
        print()


###############################################################################
# Each Node represents a pyhsical location in the TSP problem.
###############################################################################
class Node:

	def __init__(self, name, x_coord, y_coord):
		self.name = name
		self.x_coord = x_coord
		self.y_coord = y_coord
   
	def getName(self):
   		return self.name

	def getXCoordinate(self):
		return self.x_coord

	def getYCoordinate(self):
		return self.y_coord

	def __repr__(self):
		return '[' + self.name + ', ' + str(self.x_coord) + ', ' + str(self.y_coord) + ']\n'


###############################################################################
# Returns the Edclidean distance between two Nodes.
###############################################################################
def distanceBetween(NodeA, NodeB):
	
	return math.sqrt(((NodeB.getXCoordinate() - NodeA.getXCoordinate()) ** 2) 
		+  ((NodeB.getYCoordinate() - NodeA.getYCoordinate()) ** 2))


###############################################################################
# Parses the a280.tsp file (the TSP input file). Returns a list of Nodes,
# where each Node represents a location in the file.
###############################################################################
def parseTSPFile(TSPfileName):
	
	file = open(TSPfileName, 'r')

	# List of Nodes to return.
	listOfNodes = []

	# Parse line by line.
	for line in file:
		splitList = line.split();

		# If we received three digits, it is a location in the TSP file.
		if all(item.isdigit() for item in splitList):
			if len(splitList) == 3:

				# Make a node out of this location.
				listOfNodes.append(Node(splitList[0], float(splitList[1]), float(splitList[2])))

	return listOfNodes


###############################################################################
# Returns the distance of this tour. The tour goes from the first Node
# in the list to the second Node, to the third Node,..., to the last Node, and 
# back to the first Node.
###############################################################################
def tourDistance(listOfNodes):
	
	distance = 0;

	# Get the distance from Node 1 to Node 2,... to Node N, where N is
	# the last node in the list.
	for i in range(0, len(listOfNodes) - 1):

		distance = distance + distanceBetween(listOfNodes[i], listOfNodes[i + 1])


	# Get the distance from Node N back to Node 1.
	# Note: no error checking here, beacuse the input file is assumed to have
	# locations in it.
	distance += distanceBetween(listOfNodes[len(listOfNodes) - 1], listOfNodes[0])

	return distance


###############################################################################
# Generates a neighboring tour, given a current tour. For now, this will
# simply swap two locations on the tour. For example, [1, 2, 3, 4] might go to
# [1, 4, 3, 2].
###############################################################################
def getNeighborTour(listOfNodes):

	newList = copy.deepcopy(listOfNodes)

	# Generate two random numbers corresponding to two elements in this
	# list of Nodes (in this tour).
	random1 = random.randint(0, len(listOfNodes) - 1)
	random2 = random.randint(0, len(listOfNodes) - 1)

	newList[random1], newList[random2] = newList[random2], newList[random1]

	return newList


decay_rate = 0.0001
p_win = 0.999


###############################################################################
# Bernoulli-Shannon-Kelly coin flip
###############################################################################
def KellyBernoulliCoinFlip(b=None):
	global decay_rate
	global p_win

	if b is None:
		b = random.uniform(0.01, 2)

	f_k = (p_win * (b + 1) - 1) / b

	p_win = p_win - decay_rate

	uniformRandom = random.random()

	bernoulli_trial = random.choices(
		population=[0, 1], weights=[0.999, 0.001], k=1)[0]


	if (uniformRandom < f_k or bernoulli_trial == 1):
		return True
	else:
		return False

###############################################################################
# Given an initial tour, number of iterations, and cooling rate,
# performed quantitative method on the tour and returns the final solution
# tour.
###############################################################################
def runQuantitativeAlgorithm(listOfNodes,numIterations):#(listOfNodes, startingTemp, numIterations, coolingRate):

	# Do not modify the argument.
	s = copy.deepcopy(listOfNodes)


	# Create a random initial state.
	for i in range (0, 500):
		s = getNeighborTour(s)

	# This is the initial cost.
	print ("INITIAL COST: ", tourDistance(s))



	debug("init_cost",
		tourDistance(s), stop=False, key="qa_")

	# The best tour yet is the initial one to start.
	# Must deep copy to kill the reference.
	minTour = copy.deepcopy(s)
	minCost = tourDistance(s)


	for i in range (0, numIterations):
		
		# Get a random neighboring tour.
		# Note: this does not modify s and returns a new list.
		newS = getNeighborTour(s)

		if (tourDistance(newS) < tourDistance(s)):

			# The neighboring tour is better. Jump to it.
			s = copy.deepcopy(newS)

			# See if it is the best so far.
			if (tourDistance(newS) < minCost):
				minCost = tourDistance(newS)
				minTour = copy.deepcopy(newS)

				#print "Updated min tour: old dist: ", minCost, "new dist: ", tourDistance(newS), "iterations left: ", (numIterations - i)
		
		elif KellyBernoulliCoinFlip():

			# Jump to the neighbor, even though it's worse.
			s = copy.deepcopy(newS)


	return minTour

def main():

	# Check for TSP input file.
	if len(sys.argv) < 2:
		print ("No input file given.")
		sys.exit(1)

	# Parse the TSP input file. Get a list of Nodes, where each Node
	# represents a location in the TSP problem within the file.
	#print "Parsing file: ", sys.argv[1]
	listOfNodes = parseTSPFile(sys.argv[1])


	#########################################################
	# Example experiment with:
	#      initial temperature:  200,000
	#      number of iterations: 40,000
	#      cooling rate:         .999
	#########################################################
	from timeit import default_timer

	start = default_timer()  # start time of running 2opt

	# Get a solution to TSP via the simulated annealing algorithm.
	solutionList = runQuantitativeAlgorithm(listOfNodes, 3000)#200)#40000)
	#print ('Solution tour distance: ', tourDistance(solutionList))


	debug("best_cost", tourDistance(
		solutionList), stop=False, key="qa_")

	end = default_timer()  # end time of running 2opt
	time = str(end - start)

	debug("time2run", time, stop=False, key="qa_")


if __name__ == '__main__':
	main()





