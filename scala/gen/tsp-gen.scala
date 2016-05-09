/*
 * Quinten McNamara
 * CS 345 - Assignment 6
 *
 * Description of algorithm from http://www.lalena.com/AI/Tsp/ and 
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
            var group = selection

            group = group.sortWith(_.fitness > _.fitness)
            val parent1 = group.take(2)(0)
            val parent2 = group.take(2)(1)

            var replace1 = group.reverse.take(2)(0)
            var replace2 = group.reverse.take(2)(1)

            var child1 = crossover(parent1, parent2)
            if (Random.nextDouble < mutationRate) {
                child1 = mutate(child1)
            }
            var child2 = crossover(parent2, parent1)
            if (Random.nextDouble < mutationRate) {
                child2 = mutate(child2)
            }
            
            replace1 = child1
            replace2 = child2
        }

        def mutate(chromosome: Tour): Tour = {
            chromosome.cities = Random.shuffle(chromosome.cities)
            return chromosome
        }

        def crossover(p1: Tour, p2: Tour): Tour = {
            var child = new Tour(false);

            // Get start and end sub tour positions for parent1's tour
            val crossPos = (Random.nextDouble * p1.cities.length).toInt

            // Temporary buffer to hold child's cities
            var listBuffer = ListBuffer[City]()

            // Loop and add the sub tour from parent1 to our child
            for (i <- 0 until crossPos) {
                listBuffer += p1.cities(i)
            }

            val remaining = (p2.cities.toSet -- listBuffer.toSet).toList
            // Loop through parent2's city tour
            for (city <- remaining) {
                listBuffer += city
            }
            child.cities = listBuffer.toList
            return child
        }

        def selection: List[Tour] = {
            return Random.shuffle(tours.toList).take(groupSize)
        }
    }

    class City(i: Int, x: Int, y: Int) {
        val idx = i
        val X = x;
        val Y = y;

        def distanceTo(city: City): Double = {
            val xDistance = X - city.X
            val yDistance = Y - city.Y
            return Math.sqrt(Math.pow(xDistance, 2) + Math.pow(yDistance, 2));
        }
    }

    class Tour(random: Boolean) {
        var cities = List[City]()

        if (random) {
            cities = Random.shuffle(cityList)
        }

        def fitness: Double = {
            return 1 / distance
        }

        def distance: Double = {
            var totalDistance = 0.0
            for (i <- cities.indices) {
                val start = cities(i)
                val dest = if(i+1 > cities.length-1) cities(0) else cities(i+1)
                totalDistance += start.distanceTo(dest)
            }
            return totalDistance
        }
    }

    var cityList = List[City]()
    def parseCities(file: String) = {
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
        cityList = listBuffer.toList
    }
    

    def main(args: Array[String]): Unit = {
        parseCities(args(0))

        // The size of the simulation population
        val populationSize = 10000

        // Number of random tours chosen from population each generation
        val groupSize = 10

        // The percentage that each child after crossover will undergo mutation
        val mutationRate = 0.03

        // The maximum number of generations for the simulation.
        val maxGenerations = 10000

        var generation = 1
        var population = new Population(populationSize, groupSize, mutationRate)

        while (generation <= maxGenerations) {
            println("Generation " + generation)
            population.evolve
            generation += 1
        }

        // Write out solution
        val solution = population.tours.sortWith(_.fitness > _.fitness)(0).cities
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