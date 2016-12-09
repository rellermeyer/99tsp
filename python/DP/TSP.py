import itertools
import sys
from math import hypot


class Node:
		def __init__(self, num, x, y):
			self.num = num
			self.x = x
			self.y = y

		def getNum(self):
			return self.num

		def getX(self):
			return self.x

		def getY(self):
			return self.y

		def getDistance(self, other):
			return hypot(self.x - other.x, self.y - other.y)


def parseTSP(fileName):
	file = open(fileName, 'r')

	nodes = []

	for line in file:
		split = line.split()
		if len(split) == 3 and all(k.isdigit() for k in split):
			nodes.append(Node(int(split[0]), float(split[1]), float(split[2])))

	return nodes

def solveTSP(nodes):
	distMatrix = generateDistanceMatrix(nodes)
	n = len(distMatrix)
	C = {}

	for k in range (1, n):
		C[(1 << k, k)] = (distMatrix[0][k], 0)

	for s in range(2, n):
		for subset in itertools.combinations(range(1,n), s):
			mask = 0
			for bit in subset:
				mask |= 1 << bit

			for elem in subset:
				prev = mask & ~(1 << elem)
				result = []

				for elem2 in subset:
					if elem2 == 0 or elem2 == elem:
						continue
					result.append((C[(prev, elem2)][0] + distMatrix[elem2][elem], elem2))
				C[(mask, elem)] = min(result)

	bits = (2**n - 1) - 1
	result = []
	for i in range(1, n):
		res.append((C[(bits,i)][0] + dists[i][0], k))
	opt, previous = min(result)

	path = []
	for k in range(n-1):
		path.append(previous)
		bits2 = bits & ~(1 << previous)
		_, previous = C[(bits, previous)]
		bits = bits2

	path.append(0)
	return opt, list(reversed(path))

def generateDistanceMatrix(nodes):
	M = [[node.getDistance(node2) for node in nodes] for node2 in nodes]
	return M

def main():
	nodes = parseTSP('a280.tsp')
	opt, path = solveTSP(nodes)
	print(opt)
	print(path)

if __name__ == '__main__':
	main()
