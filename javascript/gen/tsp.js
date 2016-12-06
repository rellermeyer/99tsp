class City {
	constructor (id, x, y) {
		this.id = id
		this.x = x
		this.y = y
	}

	distanceTo (otherCity) {
		var xDistance = Math.abs(this.x - otherCity.x)
		var yDistance = Math.abs(this.y - otherCity.y)
		var distance = Math.sqrt((xDistance*xDistance) + (yDistance*yDistance))

		return distance
	}

	toString () {
		return this.id + ":(" + this.x + ", " + this.y + ")"
	}
}

class Manager {
	constructor () {
		this.destinationCities = []
	}

	addCity (city) {
		this.destinationCities.push(city)
	}

	getCity (index) {
		return this.destinationCities[index]
	}

	numCities () {
		return this.destinationCities.length
	}
}

class Tour {
	constructor (manager) {
		this.manager = manager
		this.fitness = 0
		this.distance = 0
		this.cities = new Array(manager.numCities()).fill(null)
	}

	generateIndividual () {
		this.cities = this.manager.destinationCities.slice()

		// shuffle
		this.cities.sort(function() {
			return .5 - Math.random()
		})
	}

	getCity(index) {
		return this.cities[index]
	}

	setCity (index, city) {
		this.cities[index] = city

		this.fitness = 0
		this.distance = 0
	}

	includesCity (city) {
		return (this.cities.filter(function(c) {
			return (c !== null) && c.id === city.id
		}).length) > 0
	}

	getFitness () {
		if (this.fitness === 0) {
			this.fitness = 1 / this.getDistance()
		}

		return this.fitness
	}

	getDistance () {
		if (this.distance === 0) {
			var tourDistance = 0

			this.cities.forEach ((fromCity, index) => {
				var destinationCity

				if (index === this.size() - 1) {
					destinationCity = this.cities[0]
				} else {
					destinationCity = this.cities[index + 1]
				}

				tourDistance += Math.floor(fromCity.distanceTo(destinationCity))
			})

			this.distance = tourDistance
		}

		return this.distance
	}
	
	size () {
		return this.cities.length
	}

	toString () {
		return this.cities.map(function(c) { return c.id }).join("->")
	}
}

class Population {
	constructor (size, shouldInitialize, manager) {
		this.tours = new Array(size).fill(null)
		
		if (shouldInitialize) {
			for (var i = 0; i < size; i++) {
				var tour = new Tour(manager)
				tour.generateIndividual()
				this.tours[i] = tour
			}
		}
	}

	getFittest () {
		var fittest = this.tours[0]

		this.tours.forEach((tour) => {
			if (fittest.getFitness() <= tour.getFitness()) {
				fittest = tour
			}
		})

		return fittest
	}

	getTour (index) {
		return this.tours[index]
	}

	saveTour (index, tour) {
		this.tours[index] = tour
	}

	size () {
		return this.tours.length
	}
}

class GenAlgorithm {
	constructor (useElitism) {
		this.manager = new Manager()
		this.mutationRate = 0.015
		this.tournamentSize = 5
		this.elitism = useElitism
	}

	start () {
		var pop = new Population(100, true, this.manager)
		console.log("Starting. Initial distance: " + pop.getFittest().getDistance())

		for (var i = 0; i < 200; i++) {
			pop = this.evolvePopulation(pop)
		}

		var fittest = pop.getFittest()

		console.log("Finished")
		console.log("Final distance: " + fittest.getDistance())
		console.log("Solution:")
		console.log(fittest.toString())
	}

	evolvePopulation(pop) {
		var newPopulation = new Population(pop.size(), false, this.manager)

		var offset = 0

		if (this.elitism) {
			offset = 1
			newPopulation.saveTour(0, pop.getFittest())
		}

		for (var i = offset; i < newPopulation.size(); i++) {
			var parent1 = this.tournamentSelection(pop)
			var parent2 = this.tournamentSelection(pop)

			var child = this.crossover(parent1, parent2)
			this.mutate(child)
			newPopulation.saveTour(i, child)
		}

		return newPopulation
	}

	crossover (parent1, parent2) {
		var child = new Tour(this.manager)

		var startPos = Math.floor(Math.random() * parent1.size())
		var endPos = Math.floor(Math.random() * parent1.size())

		if (startPos > endPos) {
			var temp = startPos
			startPos = endPos
			endPos = temp
		}

		for (var i = startPos; i <= endPos; i++) {
			child.setCity(i, parent1.getCity(i))
		}

		parent2.cities.forEach((city) => {
			if (!child.includesCity(city)) {
				var index = child.cities.findIndex((c) => {
					return c === null
				})

				child.setCity(index, city)
			}
		})

		return child
	}

	mutate (tour) {
		tour.cities.forEach((city, index) => {
			if (Math.random() < this.mutationRate) {
				var tourPos = Math.floor(Math.random() * tour.size())

				var city2 = tour.getCity(tourPos)

				tour.setCity(tourPos, city)
				tour.setCity(index, city2)
			}
		})
	}

	tournamentSelection (pop) {
		var tournament = new Population(this.tournamentSize, false, this.manager)

		for (var i = 0; i < this.tournamentSize; i++) {
			var randomId = Math.floor(Math.random() * pop.size())
			tournament.saveTour(i, pop.getTour(randomId))
		}

		return tournament.getFittest()
	}

	addCity (city) {
		this.manager.addCity(city)
	}
}

module.exports.City = City
module.exports.Manager = Manager
module.exports.Tour = Tour
module.exports.Population = Population
module.exports.GenAlgorithm = GenAlgorithm
