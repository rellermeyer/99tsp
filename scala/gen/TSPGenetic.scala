/*
 * Quinten McNamara
 * CS 345 - Assignment 6
 *
 * Description of algorithm from
 * http://www.theprojectspot.com/tutorial-post/applying-a-genetic-algorithm-to-the-travelling-salesman-problem/5
 *
 */

 import scala.util.Random
 import scala.collection.mutable.ListBuffer
 import scala.io.Source
 import java.io._

 object TSPGenetic {
    class Population(size: Int, groupSize: Int, mutationRate: Double) {
        var tours = new Array[Tour](size)

        for (i <- 0 until size) {
            tours(i) = new Tour(true)
        }

        def evolve: Unit = {
            // Breed and mutate this population
            var newTours = new Array[Tour](size)
            newTours(0) = fittest // Elitism
            for (i <- 1 until size) {
                val parent1 = selection
                val parent2 = selection

                var child = crossover(parent1, parent2)
                mutate(child)

                newTours(i) = child
            }
            tours = newTours
        }

        def mutate(t: Tour): Unit = {
            // Go through list, randomly swapping elements at mutationRate
            t.cities.indices.foreach { i =>
                if (Random.nextDouble < mutationRate) {
                    val swapPos =  Random.nextInt(t.cities.length)
                    // Swap two cities
                    var arr = t.cities.toArray
                    val temp = arr(i)
                    arr(i) = arr(swapPos)
                    arr(swapPos) = temp
                    t.cities = arr.toList
                }
            }
        }

        def crossover(p1: Tour, p2: Tour): Tour = {
            // Create child tour with random chunk from p1 and the rest from p2
            var child = new Tour(false);

            val crossPos = Random.nextInt(p1.cities.length)
            val leftSlice = p1.cities.slice(0, crossPos)
            val rightSlice = (p2.cities.toSet -- leftSlice.toSet).toList

            child.cities = leftSlice:::rightSlice
            child
        }

        def selection: Tour = {
            // Take most fit tour from a random sample
            Random.shuffle(tours.toList).take(groupSize).maxBy(_.fitness)
        }

        def fittest: Tour = {
            tours.maxBy(_.fitness)
        }
    }

    class City(i: Int, x: Int, y: Int) {
        val idx = i
        val X = x;
        val Y = y;

        def distanceTo(city: City): Double = {
            // Euclidean distance to another city
            val xDistance = X - city.X
            val yDistance = Y - city.Y
            Math.sqrt(Math.pow(xDistance, 2) + Math.pow(yDistance, 2));
        }
    }

    class Tour(random: Boolean) {
        var cities = List[City]()

        if (random) {
            cities = Random.shuffle(cityList)
        }

        def fitness: Double = {
            // Maximize this in order to minimize distance
            1 / distance
        }

        def distance: Double = {
            // Sum of distances across the tour
            cities.indices.foldLeft(0.0)((total, i) => {
                val start = cities(i)
                val dest = if(i+1 > cities.length-1) cities(0) else cities(i+1)
                total + start.distanceTo(dest)
            })
        }
    }

    var cityList = List[City]()
    def parseCities(file: String): List[City] = {
        // Parse file into a list of cities
        val lines = Source.fromFile(file).getLines.toList
        var listBuffer = new ListBuffer[City]()
        var read = false
        for (line <- lines) {
            if (line == "NODE_COORD_SECTION") {
                read = true
            }
            else if (line == "EOF") {
                read = false
            }
            else if (read) {
                val cityInfo = line.split("\\s+")
                val shift = cityInfo.length - 3 // Cause input can either be 3 or 4 columns
                listBuffer += new City(cityInfo(0+shift).toInt, cityInfo(1+shift).toInt, cityInfo(2+shift).toInt)
            }
        }
        listBuffer.toList
    }
    

    def main(args: Array[String]): Unit = {
        // Read .tsp file given as command line arg
        try { 
            cityList = parseCities(args(0))
        } catch {
            case ioe: IOException => println("IOException occurred") ; System.exit(0)
            case ex: FileNotFoundException  => println("File not found") ; System.exit(0)
        }

        // The size of the simulation population
        val populationSize = 50

        // Number of random tours chosen from population each generation
        val groupSize = 5

        // The percentage that each child after crossover will undergo mutation
        val mutationRate = 0.015

        // The maximum number of generations for the simulation.
        val maxGenerations = 1000

        var generation = 1
        var population = new Population(populationSize, groupSize, mutationRate)

        println("Initial distance " + population.fittest.distance)

        // Run evolution
        while (generation <= maxGenerations) {
            population.evolve
            generation += 1
        }

        println("Final distance " + population.fittest.distance)

        // Write out solution
        val solution = population.fittest.cities
        val writer = new PrintWriter(new File("a280tsp-gen-output.tsp"))
        writer.write("NAME : a280tsp-gen-output.tsp\n")
        writer.write("TYPE : TOUR\n")
        writer.write("DIMENSION : " + solution.length + "\n")
        writer.write("TOUR_SECTION\n")
        solution.foreach { city => writer.write(city.idx + "\n") }  
        writer.write("-1")
        writer.close()
    }
 }