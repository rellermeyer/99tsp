package tspsa

import (
	"math/rand"
)

/*
 * Create a random map for the TSP problem
 * Modifies the map in the subsequent given TSPMAP struct
 * x: Max x cord
 * y: Max y cord
 * p: Number of points
 */
func CreateRandomMAP(x int, y int, p int) []Node{
	var r []Node
	for i := 0; i < p; i++ {
		n := Node{rand.Intn(x), rand.Intn(y)}
		r = append(r, n)
	}
	return r
}