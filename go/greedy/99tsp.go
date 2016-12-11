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

// Run the program.
func main() {
    fmt.Println("99 Traveling Salespeople Problem - go version")
    parseInput()
}

// Read information from the input file.
func parseInput() {

    // Open the input file.
    f, _ := os.Open(os.Args[1])
    defer f.Close()

    // Use a scanner to read lines from the input file.
    scanner := bufio.NewScanner(f)
    arraySize := 0
    j := 0

    // Skip first few lines and get the number of dimension.
    for (scanner.Scan()) {
        line := scanner.Text()
        str := strings.Fields(line)

        // Get the number of dimension.
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

    // Create two arrays to store x and y coordinates respectively.
    x := make([]float64, arraySize + 1)
    y := make([]float64, arraySize + 1)

    // Read all x, y coordinates of all points.
    for (scanner.Scan()) {
        line := scanner.Text()
        str := strings.Fields(line)
        firstToken, _ := strconv.Atoi(str[0])
        if (firstToken != 0 && line != "EOF") {
            j++
            x[j], _ = strconv.ParseFloat(str[1], 64)
            y[j], _ = strconv.ParseFloat(str[2], 64)
        }
        if (str[0] == "EOF") {
            break
        }
    }
    findRoute(x, y, arraySize)
}

// Find the closest point to this point.
func findNearNeighbor(x []float64, y []float64, points map[int]int, start int) int {
    neighbor := 0
    smDist := 10000000.0

    // Loop through all yet visited points to find out the cloesest point to current point.
    for i := 1; i < len(points); i++ {
        if (i != start) && (points[i] != 0) {
            sqSum := math.Pow(x[i] - x[start], 2) + math.Pow(y[i] - y[start], 2)
            dist := math.Sqrt(sqSum)
            if dist < smDist {
                neighbor = i
                smDist = dist
            }
        }
    }
    return neighbor
}

// Use greedy algorithm to find the solution route.
func findRoute(x []float64, y []float64, arraySize int) {
    
    // Randomly generate a start point.
    startpoint := rand.Intn(arraySize) + 1

    // Create an array to save the order of points to visit as the solution.
    solutionRoute := make([]int, arraySize + 1)
    solutionRoute[1] = startpoint

    // Create a map to store the points which have not been visited yet.
    unvisitedPoints := make(map[int]int)
    for l := 0; l <= arraySize; l++ {
        unvisitedPoints[l] = l
    }
    unvisitedPoints[startpoint] = 0

    // Find the cloesest point to the current one and go to that point, and repeat.
    for k := 2; k <= arraySize; k++ {
        nearNeighbor := findNearNeighbor(x, y, unvisitedPoints, startpoint)
        solutionRoute[k] = nearNeighbor
        startpoint = nearNeighbor
        unvisitedPoints[nearNeighbor] = 0
    }
    printResult(solutionRoute)
}

// Print out the solution route, in the format of "LocationNumber-LocationNumber-LocationNumber-...".
func printResult(solutionRoute []int) {
    for z := 1; z < len(solutionRoute); z++ {
        fmt.Print(solutionRoute[z], "-")
    }

    // Prints out the start point because it requires to return to the city started.
    fmt.Println(solutionRoute[1])
}