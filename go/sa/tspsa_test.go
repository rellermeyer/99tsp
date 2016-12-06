package tspsa

import (
	"testing"
	"fmt"
)

func TestRandom1(t *testing.T) {
	printSep()
	fmt.Println("Test 1: ")
	n := RunSARandom(100, 1, 0.00001, 0.4, 200, 200, 50, false)
	fmt.Printf("Distance: %.6f\n", n.D)
}

func TestRandom2(t *testing.T) {
	printSep()
	fmt.Println("Test 2: ")
	n := RunSARandom(1000, 1, 0.00001, 0.003, 300, 200, 50, false)
	fmt.Printf("Distance: %.6f\n", n.D)
}

func TestRandom3(t *testing.T) {
	printSep()
	fmt.Println("Test 3: ")
	n := RunSARandom(1000, 1, 0.00001, 0.004, 200, 300, 50, false)
	fmt.Printf("Distance: %.6f\n", n.D)
}

func TestRandom4(t *testing.T) {
	printSep()
	fmt.Println("Test 4: ")
	n := RunSARandom(1000, 1, 0.00001, 0.00005, 20, 20, 1555, false)
	fmt.Printf("Distance: %.6f\n", n.D)
}

func TestRandom5(t *testing.T) {
	printSep()
	fmt.Println("Test 5: ")
	n := RunSARandom(1000, 1, 0.00001, 0.003, 8000, 5222, 10, false)
	fmt.Printf("Distance: %.6f\n", n.D)
	printSep()
}
func printSep() {
	fmt.Println("=============================================")
}