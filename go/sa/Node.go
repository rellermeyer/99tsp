package tspsa

import (
	"math"
	"strconv"
)

type Node struct {
	x int		// x cord
	y int 		// y cord
}

/*
 *  Calculate the Euclidean distance between the two nodes
 *  return the distance (float64)
 */
func (i *Node) GetEuDistance(j *Node) float64 {
	return math.Sqrt(math.Pow(float64(i.x - j.x), 2) + math.Pow(float64(i.y - j.y), 2))
}

/*
 * String function for Node
 */
func (i *Node) String() string {
	return "NODE:\tX: " +  strconv.FormatInt(int64(i.x), 10) + "\tY: " + strconv.FormatInt(int64(i.y), 10) + "\n"
}