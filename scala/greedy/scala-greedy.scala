/*
 * Gilad Oved
 * May 11th 2016
 * CS 345
 */

import scala.io.Source
import scala.collection.mutable.{ Map, ArrayBuffer, Set }
import java.io.{ FileReader, FileNotFoundException, IOException, File, PrintWriter }

object tspgreedy {

  class Path(np: ArrayBuffer[TSPNode], d: Double) {
    var nodePath = np
    var distance = d
  }
  
  object TSPObject {
    var map = Map[String, String]()
    var data = ArrayBuffer[TSPNode]()

    def addNode(i: Int, x: Int, y: Int) {
      data += new TSPNode(i, x, y)
    }
    
    def addMap(a: String, b: String) {
      map(a) = b
    }
    
    def getBestPath: Path ={
      var bestPath = new Path(null, Integer.MAX_VALUE)
      var bestDistance = Double.MaxValue
      
      var i = 0;
      for(i <- 1 to data.length-1) {
        var nextPath = getPath(i)
        if (nextPath.distance < bestDistance) {
          bestPath = nextPath
          bestDistance = nextPath.distance
        }
      }
            
      bestPath
    }

    def getPath(start: Int): Path = {
      var nodePath = ArrayBuffer[TSPNode]()
      var explore = Set[TSPNode]()
      var distance = 0.0
      TSPObject.data.foreach { node =>
        explore.add(node)
      }
      var prevNode = TSPObject.data(start)
      explore.remove(prevNode)
      nodePath += prevNode
      while (!explore.isEmpty) {
        var nextCity = findNearest(prevNode, explore)
        distance += prevNode.distanceTo(nextCity)
        nodePath += nextCity
        explore.remove(nextCity)
        prevNode = nextCity
      }
      new Path(nodePath, distance)
    }

    private def findNearest(from: TSPNode, options: Set[TSPNode]): TSPNode = {
      var bestDistance = Double.MaxValue
      var bestNode: TSPNode = from
      options.toList.foreach { node =>
        val dist = from.distanceTo(node)
        if (dist < bestDistance) {
          bestDistance = dist
          bestNode = node
        }
      }
      bestNode
    }

    def printProperties() {
      map.keys.foreach { x => println(x + " is " + map(x)) }
    }

    def printData() {
      data.foreach { d => println(d) }
    }
  }

  class TSPNode(i: Int, a: Int, b: Int) {
    var index: Int = i
    var x: Int = a
    var y: Int = b

    //Euclidean distance
    def distanceTo(to: TSPNode): Double = {
      Math.sqrt(((x-to.x) * (x-to.x)) + ((y-to.y) * (y-to.y)))
    }

    override def toString(): String = index + ": (" + x + ", " + y + ")";
  }

  //parse the .tsp file into objects
  def parseTSP(lines: List[String]) {
    var readingData = false
    lines.foreach { line =>
      val regex = "[:]\\s+".r
      var newLine = regex.replaceFirstIn(line, "-")
      var splitLine = newLine.split("-")
      if (splitLine.length == 2) {
        TSPObject.addMap(splitLine(0), splitLine(1))
      }

      if (splitLine(0).equals("NODE_COORD_SECTION")) {
        readingData = true
      }
      if (readingData) {
        var nodeParts = newLine.split("\\s+")
        if (nodeParts.length == 3) {
          TSPObject.addNode(nodeParts(0).toInt, nodeParts(1).toInt, nodeParts(2).toInt)
        } else if (nodeParts.length == 4) {
          TSPObject.addNode(nodeParts(1).toInt, nodeParts(2).toInt, nodeParts(3).toInt)
        }
      }
    }
  }

  def main(args: Array[String]) {
    if (args.length == 0) {
      System.err.println("99 TSP - No input file");
    }
    var filepath = args(0)
    
    try {
      var l = Source.fromFile(filepath).getLines.toList
      parseTSP(l)
    } catch {
      case ex: FileNotFoundException => println("Couldn't find that file.")
      case ex: IOException           => println("Had an IOException trying to read that file")
    }
    
    //Write an output file with the resulting path
    val path = TSPObject.getBestPath
    val writer = new PrintWriter(new File("a280tsp-greedy-output.tsp"))
    writer.write("NAME : a280tsp-greedy-output.tsp\n")
    writer.write("TYPE : TOUR\n")
    writer.write("DIMENSION : " + path.nodePath.length + "\n")
    writer.write("TOUR_SECTION\n")
    path.nodePath.foreach { node => writer.write(node.index + "\n") }  
    writer.write("-1")
    writer.close()
  }

}