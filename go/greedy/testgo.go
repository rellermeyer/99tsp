package main

import (
	"fmt"
	"bufio"
	"os"
	"strings"
	"strconv"
    "math"
)

func main() {
    fmt.Println()
    // Open the file.
    
    var a [1000]int // x-coordinate
    var b [1000]int // y-coordinate
    parseInput(a, b)


}

func parseInput(a [1000]int, b [1000]int) {
    f, _ := os.Open("input/rat99.tsp")
    defer f.Close()

    var i = 0
    // Create a new Scanner for the file.
    scanner := bufio.NewScanner(f)
    // Loop over all lines in the file and print them.
    for scanner.Scan() {
        line := scanner.Text()
        if (i > 5 && line != "EOF") {
            str := strings.Fields(line)
            a[i-5], _ = strconv.Atoi(str[1])
            b[i-5], _ = strconv.Atoi(str[2])
        }
        i += 1
    }
    numOfPoints := i - 6 - 1
    startpoint := 55
    // fmt.Println(numOfPoints)
    ab := findNearNeighbor(a, b, numOfPoints, startpoint)
    fmt.Println("dfewfefe", ab)
}

func findNearNeighbor(a [1000]int, b [1000]int, num int, start int) int {
    neighbor := 0
    smDist := 10000.0
    for i := 1; i <= num; i++ {
        if i != start {
            sqSum := math.Pow(float64(a[i] - a[start]), 2) + math.Pow(float64(b[i] - b[start]), 2)
            dist := math.Sqrt(sqSum)
            if dist < smDist {
                neighbor = i
                smDist = dist
            }
        }
    }
    fmt.Println(a[start], b[start])
    fmt.Println(neighbor)
    fmt.Println(a[neighbor], b[neighbor])
    return neighbor
}