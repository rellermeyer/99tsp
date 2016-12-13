var classes = require("./tsp.js")
var fs = require('fs')

var filePath = process.argv[2]

var file = fs.readFileSync(filePath).toString().split('\n')
file.splice(-2, 2) // remove "EOF"
file.splice(0, 6) // remove header

var algo = new classes.GenAlgorithm(true)
for (let [i, line] of file.entries()) {
	// clean string
	var cleaned = line.trim().replace(/\s+/g, " ").split(" ")

	var city = new classes.City(cleaned[0], cleaned[1], cleaned[2])
	algo.addCity(city)
}


algo.start()
