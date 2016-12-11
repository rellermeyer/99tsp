package tspsa

import (
	"math/rand"
	"math"
	"fmt"
	"io/ioutil"
	"strings"
	"strconv"
)

/*
 * Wrapper to call SA with random points
 * it: Itterations
 * t: temp
 * tmin: Min Temp
 * c: coolrate
 * x: Number of x coordinates
 * y: Number of y coordinates
 * p: Number of Points
 * v: Verbose
 */
func RunSARandom(it int, t float64, tmin float64, c float64, x int, y int, p int, v bool) Route {
	return RunSA(it, t, tmin, c, CreateRandomMAP(x, y, p), v)
}

/* 
 * Run Simmulated Annealing Algorithm from a given tsp file
 * it: Itterations
 * t: temp
 * tmin: Min Temp
 * c: Cool Rate
 * f: File Name
 * v: Verbose
 */
func RunSAFromFile(it int, t float64, tmin float64, c float64, f string, v bool) Route {
	lines, err := readFile(f)
	if err != nil {
		fmt.Println(err.Error())
	}
	n := createNodesFromString(lines)
	return RunSA(it, t, tmin, c, n, v)
}

/*
 * l: splice of strings as lines in a file
 */
func createNodesFromString(lines []string) []Node {
	var r []Node
	for i := 0; i < len(lines); i++ {
		l := strings.Fields(lines[i])
		if len(l) == 3 {
			x, err1 := strconv.Atoi(l[1])
			y, err2 := strconv.Atoi(l[2])
			if err1 == nil && err2 == nil {
				n := Node{x, y}
				r = append(r, n)
			}
		}
	}
	return r
}

/*
 * File parsing
 * f: filename
 */
func readFile(f string) ([]string, error) {
	file, err := ioutil.ReadFile(f)
	if err != nil {
		return nil, err
	}
	return strings.Split(string(file), "\n"), nil
}

/*
 * Run the SA algorithm with the given itterations, temp, min temp, coolrate, and a splice of Node objects
 *
 * i:    Itterations
 * t: 	 temp
 * tmin: temp min
 * c: 	 coolrate
 */
func RunSA(it int, t float64, tmin float64, c float64, n []Node, p bool) Route {
	// Set the Routes for the current SA given the list of nodes
	cur  := Route{n, math.MaxFloat64}
	cur.CalcDistance() // old cost
	best := Route{n, math.MaxFloat64}
	next := Route{n, math.MaxFloat64}
	l := cur.Nodes() // Length
	for t > tmin {
		for i := 0; i < it; i++ {
			next.SwapNodes(rand.Intn(l), rand.Intn(l))
			next.CalcDistance()
			if acceptProb(cur.D, next.D, t) >= 0.5 {
				cur.R = next.R
				cur.D = next.D
			}
			if (cur.D < best.D) {
				best.R = cur.R
				best.D = cur.D
			}
		}
		t = t * c
	}
	if p {
		fmt.Println(best.String())
		fmt.Printf("Distance: %.6f\n", best.D)
	}
	return best
}

/*
 * acceptance Probability Calculation
 * This should return 1.0 if the new energy is greater than the current energy
 * Else it will return the acceptance Probability
 */
func acceptProb(e float64, ne float64, t float64) float64 {
	if ne > e {
		return 1
	} else {
		// acceptance probability
		return math.Exp((e - ne) / t)
	}
}





