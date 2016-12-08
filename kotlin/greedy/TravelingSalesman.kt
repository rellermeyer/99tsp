import java.io.File
import java.util.*
import java.util.regex.Pattern

/**
 * TravelingSalesman
 *
 * @author Ian Caffey
 * @since 1.0
 */
//regex for node line
val LINE_PATTERN: Pattern = Pattern.compile("\\s+")

fun main(args: Array<String>) {
    //Read all node lines from file, parse into Triple<Int, Int, Int>, and solve
    File(args[0] + ".tsp").readLines().filterNotNull().
            /*primitive filtering of non-node lines*/
            filter { it.indexOf(":") == -1 && it != "NODE_COORD_SECTION" && it != "EOF" }.
            map(String::trim).map(::parse).apply(::solve)
}

/**
 * Solves the Traveling Salesman problem given a collection of nodes which represent a graph.
 *
 * @param nodes the graph of node triples(first -> id, second -> x, third -> y)
 */
fun solve(nodes: List<Triple<Int, Int, Int>>) {
    var distance = 0
    val unvisited = ArrayList<Triple<Int, Int, Int>>(nodes)
    val path = ArrayList<Triple<Int, Int, Int>>()
    val start = nodes[(Math.random() * nodes.size).toInt()] //begin path at random node
    path.add(start)
    unvisited.remove(start) //prune start to manually create path from last node to start
    while (unvisited.isNotEmpty()) {
        val (nearestDistance, nearest) = nearest(path.last(), unvisited)
        distance += nearestDistance
        path.add(nearest)
        unvisited.remove(nearest)
    }
    println("Distance: " + (distance + distance(start, path.last())))
    path.forEach { println(it.first) }
    println(-1)
}

/**
 * Calculates the nearest nodes within a collection of nodes.
 *
 * @param start the start node triple(second -> x, third -> y)
 * @param neighbors the neighbor node tripls
 * @return a {@code Pair} consisting of the distance and the nearest node triple
 * @see distance
 */
fun nearest(start: Triple<Int, Int, Int>, neighbors: Iterable<Triple<Int, Int, Int>>): Pair<Int, Triple<Int, Int, Int>> {
    var nearest: Triple<Int, Int, Int> = Triple(0, 0, 0)
    var nearestDistance = Int.MAX_VALUE
    neighbors.forEach {
        val distance = distance(start, it)
        if (distance < nearestDistance) {
            nearest = it
            nearestDistance = distance
        }
    }
    return Pair(nearestDistance, nearest)
}

/**
 * Calculates the Euclidean distance between two node triples.
 *
 * @param source the source node triple(second -> x, third -> y)
 * @param destination the destination node triple(second -> x, third -> y)
 * @return the euclidean distance rounded using {@code nint((int) x + 0.5)}
 */
fun distance(source: Triple<Int, Int, Int>, destination: Triple<Int, Int, Int>): Int {
    return (Math.sqrt(Math.pow((source.second - destination.second).toDouble(), 2.0) +
            Math.pow((source.third - destination.third).toDouble(), 2.0)) + 0.5).toInt()
}

/**
 * Parses a trimmed space-delimited line of 3 numbers into a new {@code Triple<Int, Int, Int>}.
 *
 * @param line the input number string
 * @return a new {@code Triple<Int, Int, Int>}
 */
fun parse(line: String): Triple<Int, Int, Int> {
    val parts = line.split(LINE_PATTERN)
    if (parts.size != 3)
        throw IllegalStateException("Malformed line. Expected 3 space-delimited numbers. Actual: " + parts)
    return Triple(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]), Integer.parseInt(parts[2]))
}