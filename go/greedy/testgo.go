package main

import (
	"fmt"
	"bufio"
	"os"
	"strings"
	"strconv"
    "math"
    "math/rand"
)

// Run the program
func main() {
    fmt.Println("99 Traveling Salespeople Problem - go version")
    parseInput()
}

// Read information from the input file.
func parseInput() {

    // Open the input file.
    // f, _ := os.Open("input/rat99.tsp")
    // f, _ := os.Open("input/a280.tsp")
    // f, _ := os.Open("input/pla85900.tsp")
    f, _ := os.Open("input/burma14.tsp")
    defer f.Close()

    // Use a scanner to read lines from the input file
    scanner := bufio.NewScanner(f)
    arraySize := 0
    j := 0

    // Loop over all lines in the file and print them.
    for (scanner.Scan()) {
        line := scanner.Text()
        str := strings.Fields(line)

        // Get the number of dimension
        if (strings.Contains(str[0], "DIMENSION")) {
            for i := 1; i < len(str); i++ {
                nextToken, _ := strconv.Atoi(str[i])
                if (nextToken != 0) {
                    arraySize = nextToken
                }
            }
            break
        }
    }
    a := make([]float64, arraySize + 1)
    b := make([]float64, arraySize + 1)
    for (scanner.Scan()) {
        line := scanner.Text()
        str := strings.Fields(line)
        firstToken, _ := strconv.Atoi(str[0])
        if (firstToken != 0 && line != "EOF") {
            j++
            a[j], _ = strconv.ParseFloat(str[1], 64)
            b[j], _ = strconv.ParseFloat(str[2], 64)
        }
        if (str[0] == "EOF") {
            break
        }
    }
    findRoute(a, b, arraySize)
    fmt.Println(arraySize)
}

// Find the closest point to this point.
func findNearNeighbor(a []float64, b []float64, points map[int]int, start int) int {
    neighbor := 0
    smDist := 10000000.0
    for i := 1; i < len(points); i++ {
        if (i != start) && (points[i] != 0) {
            sqSum := math.Pow(a[i] - a[start], 2) + math.Pow(b[i] - b[start], 2)
            dist := math.Sqrt(sqSum)
            if dist < smDist {
                neighbor = i
                smDist = dist
            }
        }
    }
    // fmt.Println(start)
    // fmt.Println(a[start], b[start])
    // fmt.Println(neighbor)
    // fmt.Println(a[neighbor], b[neighbor])
    return neighbor
}

// Use greedy algorithm to find the solution route
func findRoute(a []float64, b []float64, arraySize int) {
    
    // Randomly generate a start point
    startpoint := rand.Intn(arraySize) + 1
    solutionRoute := make([]int, arraySize + 1)
    solutionRoute[1] = startpoint

    unvisitedPoints := make(map[int]int)
    for l := 0; l <= arraySize; l++ {
        unvisitedPoints[l] = l
    }
    unvisitedPoints[startpoint] = 0

    for k := 2; k <= arraySize; k++ {
        nearNeighbor := findNearNeighbor(a, b, unvisitedPoints, startpoint)
        solutionRoute[k] = nearNeighbor
        startpoint = nearNeighbor
        unvisitedPoints[nearNeighbor] = 0
    }
    printResult(solutionRoute)
}

// Print out the solution route, in the format of "LocationNumber-LocationNumber-LocationNumber-...".
func printResult(solutionRoute []int) {
    for z := 1; z < len(solutionRoute) - 1; z++ {
        fmt.Print(solutionRoute[z], "-")
    }
    fmt.Println(solutionRoute[len(solutionRoute) - 1])
    // for z := 0; z<len(unvisitedPoints); z++ {
    //     if (unvisitedPoints[z] != 0) {
    //         fmt.Println("WHAT",z)
    //     }
    // }
}