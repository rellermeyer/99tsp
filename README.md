# The 99 Traveling Salespeople Project

The 99 Traveling Salespeople project is a project that aims to collect
implementations of the Traveling Salesman from different programming
languages that exist, practical or esoteric. The purpose of the collection is
to illustrate the many differences among programming languages when implementing
the same algorithm, in this case, the traveling salesman.

## What is the Traveling Salesman Problem?

(adapted from Wikipedia)

You have a bunch of cities and a list of distances between the cities (if
a path between the 2 exists). The task is to find a route that will
do the following:

* Visit every city exactly once
* Returns to the city you started from
* Returns the shortest possible route

The problem is NP-hard, basically meaning there isn't a polynomial time 
algorithm currently known that can produce a correct answer.

## Algorithms

The following variations of the Traveling Salesman problem are currently 
available in this repository.

* Greedy (greedy)
* ~~Linear Programming (lp)~~ (no one has done 1 yet)
* Simulated Annealing (sa)
* Genetic (gen)
* ~~Neural Network (neural)~~ (no one has done 1 yet)
* 2-Opt (2opt)

If more implementations are added, this list will be added to as well.
Below are short descriptions of each implementation method. Note that the 
implementations contained in this repository may differ from these 
descriptions.

### Greedy

A greedy solution, in general, is one that picks the "best" choice at every
step in program execution in hope that it will produce the best (or a good)
result at the end of execution.

A greedy implementation will simply grab the nearest neighbor from the current
city at every step until all cities have been visited. The last city
on the tour is the starting city, so the last step isn't necessarily
greedy.

### Linear Programming

TODO

### Simulated Annealing

Simulated annealing will do "hill climbing" in that it will randomly make
changes to the tour and accept the change if the change results in a better
solution. If the change doesn't result in a better solution, then there
is still a possibility that the change will be accepted for the next step.
The probability of it being accepted is controlled by the current 
"temperature": the higher it is, the more of a chance it has to accept a
"bad" change. Bad changes are accepted as they might let the program
escape local optima in search of a global optima. The temperature of
the program decreases as time passes, and when it reaches a specified
point, execution stops and the solution is returned.

In terms of the traveling salesman, the random change would be to swap
cities of an already existing tour in hope that it will produce
a better tour.

### Genetic

TODO

### Neural Network

TODO

### 2-Opt

TODO

Last update: November 22, 2016

## Languages

The following languages and implementations are currently available on the
repository.

* R
    * Greedy
* C
    * Greedy
    * Simulated Annealing
* C++
    * Greedy
    * Simulated Annealing
* Java
    * Greedy
* Javascript
    * Greedy
* Objective C
    * Greedy
* Prolog
    * Simulated Annealing
* Python
    * Greedy
    * Genetic
    * Simulated Annealing
    * 2-Opt
* Ruby
    * Greedy
* Rust
    * 2-Opt
* Scala
    * Greedy
    * Genetic
* Verilog
    * Simulated Annealing
* Visual Basic
    * Greedy

Last update: November 22, 2016
