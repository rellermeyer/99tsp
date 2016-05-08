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
    class Population(size: Int, groupSize: Int, mutationRate: Double) {
        var tours = new Array[Tour](size)

        for(i <- 0 until size) {
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
            if(Random.nextDouble < mutationRate) {
                child1 = mutate(child1)
            }
            var child2 = crossover(parent2, parent1)
            if(Random.nextDouble < mutationRate) {
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

            // Loop and add the sub tour from parent1 to our child
            for(i <- 0 until crossPos) {
                child.cities = p1.cities(i) :: child.cities
            }

            val remaining = (p2.cities.toSet -- child.cities.toSet).toList
            // Loop through parent2's city tour
            for(city <- remaining) {
                child.cities = city :: child.cities
            }
            child.cities = child.cities.reverse;
            return child
        }

        def selection: List[Tour] = {
            return Random.shuffle(tours.toList).take(groupSize)
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
        return List[City](new City(5, 6), new City(1, 4), new City(10, 2), new City(3, 2), new City(15, 10))
    }
    

    def main(args: Array[String]): Unit = {
        cityList = parseCities(args(0))

        // May make the algorithm better, not using for now
        // val numNearbyCities = 5
        // val nearbyCitiesOdds = 0.9

        // The size of the simulation population
        val populationSize = 10

        // Number of random tours chosen from population each generation
        val groupSize = 5

        // The percentage that each child after crossover will undergo mutation
        val mutationRate = 0.03

        // The maximum number of generations for the simulation.
        val maxGenerations = 100000

        var generation = 1
        var population = new Population(populationSize, groupSize, mutationRate)

        while (generation <= maxGenerations) {
            println("Generation " + generation)
            population.evolve
            generation += 1
        }

        for(tour <- population.tours) {
            println(tour.fitness)
        }
    }
 }