
"""
Greed algorithm for TSP

Requires .tsp file format.

Josh Kelle
May 5, 2016
CS 345

"""

import sys
from math import sqrt


################################################################################
#                               greedy algorithm                               #
################################################################################


def dist2(x1, y1, x2, y2):
    """
    Computes Euclidean distance squared
    """
    return (x2 - x1)**2 + (y2 - y1)**2


def getNearestNode(remaining_nodes, current_node):
    """
    Args:
        remaining_nodes: list of (nodeid, x, y) triples
        current_node: the "current" node; (nodeid, x, y)

    Returns:
        1. nearest node: the (nodeid, x, y) triple closest to the current node
        2. the distance between this nearest node and the current node
    """
    _, cur_x, cur_y = current_node
    # dict that maps {dist2(a, b) -> b} where a is the "current" node.
    dist_to_node = {dist2(cur_x, cur_y, x, y): (nodeid, x, y) for nodeid, x, y in remaining_nodes}
    return dist_to_node[min(dist_to_node)], sqrt(min(dist_to_node))


def solveGreedyTSP(data):
    """
    Args:
        data: a list of lists of 3 ints.
                [
                    [nodeid, x, y],
                    [nodeid, x, y],
                    ...
                    [nodeid, x, y]
                ]

    Returns:
        solution: list of nodeids representing the order in which nodes should
            be visited.
    """
    best_path = None
    min_dist = None

    for start_node in data:
        total_distance = 0
        visited_nodes = [start_node]
        remaining_nodes = [node for node in data if node is not start_node]

        while len(remaining_nodes) > 0:
            nearest_node, distance = getNearestNode(remaining_nodes, visited_nodes[-1])
            visited_nodes.append(nearest_node)
            remaining_nodes.remove(nearest_node)
            total_distance += distance

        if min_dist is None or total_distance < min_dist:
            best_path = visited_nodes
            min_dist = total_distance
            print("starting at node {i} gives a distance of {d}".format(i=start_node[0], d=total_distance))

    return best_path, min_dist


################################################################################
#                                   parsing                                    #
################################################################################


def isDataLine(line):
    """
    Used for parsing data file. Returns true if the parameter is a data line,
    false otherwise.

    Args:
        line: string, a line from the data file.

    Returns:
        True or False
    """
    return len(line.split()) == 3 and all(x.isdigit() for x in line.split())


def parseFile(filepath):
    """
    Parses files with a280.tsp format.

    Args:
        filepath: string representing filesystem path to data file

    Return:
        data: a list of triples of ints.
                [
                    (nodeid, x, y),
                    (nodeid, x, y),
                    ...
                    (nodeid, x, y)
                ]
    """
    data = []

    with open(filepath) as datafile:
        for line in datafile:
            if isDataLine(line):
                data.append(tuple([int(x) for x in line.split()]))

    return data


################################################################################
#                                     main                                     #
################################################################################


def main():
    if len(sys.argv) < 2:
        print("99 TSP - No input file")
        sys.exit(1)

    data = parseFile(sys.argv[1])
    nodes, distance = solveGreedyTSP(data)
    node_ids = [nodeid for nodeid, _, _ in nodes]

    print(node_ids)
    print(distance)


if __name__ == '__main__':
    main()
