/*
 * Quinten McNamara
 * CS 345 - Assignment 6
 *
 * Description of algorithm from http://www.lalena.com/AI/Tsp/ and 
 * http://www.theprojectspot.com/tutorial-post/applying-a-genetic-algorithm-to-the-travelling-salesman-problem/5
 *
 */

 import scala.util._

 object TSPGenetic {
    class Population(size: Int) {
        var tours = new Array[Tour](size)

        for(i <- 0 until size) {
            tours(i) = new Tour(true)
        }

        def evolve : Unit = {

        }
    }

    class City(x: Int, y: Int) {
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

        if(random) {
            cities = Random.shuffle(cityList)
        }

        def fitness: Double = {
            return 1 / distance
        }

        def distance: Double = {
            var totalDistance = 0.0
            for(i <- cities.indices) {
                val start = cities(i)
                val dest = if(i+1 > cities.length-1) cities(0) else cities(i+1)
                totalDistance += start.distanceTo(dest)
            }
            return totalDistance
        }
    }

    var cityList = List[City]()
    def parseCities(file: String): List[City] = {
        return List[City](new City(5, 6), new City(1, 4), new City(10, 2))
    }
    

    def main(args: Array[String]): Unit = {
        cityList = parseCities(args(0))

        // The size of the simulation population
        val populationSize = 10000

        // Number of random tours chosen from population each generation
        val groupSize = 5

        // Number of cities considered close to current city
        val numNearbyCities = 5

        // Odds of using nearby city as a tour link
        val nearbyCitiesOdds = 0.9

        // The maximum number of generations for the simulation.
        val maxGenerations = 10000

        // The percentage that each child after crossover will undergo mutation
        val mutationRate = 0.03

        var generation = 1
        var population = new Population(populationSize)

        while (generation <= maxGenerations) {
            println("Generation " + generation)
            population.evolve
            generation += 1
        }

        val g = new City(6, 5)
        val f = new City(9, 2)
        println(g.distanceTo(f))
        println(g.Y)
    }
 }