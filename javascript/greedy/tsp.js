/*
 *	Greedy TSP in JavaScript/NodeJS implemented by Brandon Dang	
 *
 *	npm install npm xml2js
 *	node tsp.js [input.xml] [startIndex]
 *
 *	or
 *
 *	make run
 */
var file = process.argv[2]
var s = parseInt(process.argv[3])

var fs = require('fs')
var parseString = require('xml2js').parseString

//if(!file.endsWith('.xml'))
//	throw 'ERR: expecting XML file input'

var xml = fs.readFileSync(file)

parseString(xml, function(err, result) {
	if(err)
		throw err
	xml = result
})

var graph = xml.travellingSalesmanProblemInstance.graph

var vertices = graph[0].vertex
var nodes = {}
for(var v in vertices) {
	var i = parseInt(v)
	nodes[i] = vertices[i].edge
}

if(isNaN(s))
	throw 'ERR: index is NaN'
else if(s < 0 || s >= Object.keys(nodes).length)
	throw 'ERR: index out of bounds'

var start = s
var path = []
var total = 0

var current = start
while(Object.keys(nodes).length > 0) {
	path.push(current)

	var edges = nodes[current]
	delete nodes[current]

	var min = Number.MAX_SAFE_INTEGER
	edges.forEach(function(e) {
		var edge = e
		var num = parseInt(edge._)
		var cost = edge.$.cost
		
		if(cost < min && nodes[num] != undefined) {
			min = cost
			current = num
		}
	})

  if(min != Number.MAX_SAFE_INTEGER)
    total += parseFloat(min)

  if(Object.keys(nodes).length == 1) {
    edges.forEach(function(e) {
      var edge = e
      var num = parseInt(edge._)
      var cost = edge.$.cost

      if(num == start)
        total += parseFloat(cost)
    })
  }
}
path.push(start)

console.log(path)
console.log(total)
