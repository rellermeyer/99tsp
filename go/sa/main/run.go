package main

import (
	"fmt"
	"github.com/bullapse/tspsa"
)

func main() {
	n := tspsa.RunSAFromFile(1000, 1, 0.00001, 0.003, "a280.tsp", false)
	fmt.Printf("Distance: %.6f\n", n.D)
}