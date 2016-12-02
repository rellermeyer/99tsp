package main

import (
	"fmt"
	"bufio"
	"os"
	"log"
	// "strings"
	// "strconv"
)

func main() {
    fmt.Println("Hello World!")
    // Open the file.
    f, err := os.Open("input/rat99.tsp")
    if err != nil {
        log.Fatal(err)
    }
    defer f.Close()
    // var a []int
    // var b []int
    // var str []string
    var i = 0
    // Create a new Scanner for the file.
    scanner := bufio.NewScanner(f)
    // Loop over all lines in the file and print them.
    for scanner.Scan() {
    	line := scanner.Text()
    	// str = strings.SplitAfter(line, " ")
    	// test, _ := strconv.Atoi(str[0])
    	fmt.Println(line)
    	// if (reflect.TypeOf(test).Kind() == reflect.Int) {
    	if (i > 5 && line != "EOF") {
    		fmt.Println("QQQQ")
			fmt.Println(line)
			// a[i], _ = strconv.Atoi(str[1])
			// fmt.Println(a[i])
			// b[i], _ = strconv.Atoi(str[2])
			// fmt.Println("B")
		}
		i += 1
		// fmt.Println(line)
    }
    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }
}