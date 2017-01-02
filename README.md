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
* Linear Programming (lp)
* Simulated Annealing (sa)
* Genetic (gen)
* Neural Network (neural)
* 2-Opt (2opt)
* Dynamic Programming

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

The technique of linear programming to solve problems involves constructing
linear equations that represent constraints on a problem and attempting to 
find the best answer possible under these constraints.

There exist a set of requirements that can be constructed for the traveling
salesman problem that will result in an answer.

See Wikipedia for more information:
https://en.wikipedia.org/wiki/Travelling_salesman_problem#Integer_linear_programming_formulation

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

Good Source (Please do not copy the Java source):
http://www.theprojectspot.com/tutorial-post/simulated-annealing-algorithm-for-beginners/6

### Genetic

A genetic algorithm has the concepts of a population with traits that can be
"mutated" and/or "bred/crossover'd" in order to produce a new population.
The members of a population are the solutions to the problem one is trying
to solve. By selectively mutating and crossing over members with strong
"fitness" (i.e. a good solution), the hope is to create populations
that progressively get better and better until a good solution is
found. In general, the more generations one has an algorithm run for, the 
better the results will be.

For the traveling salesman problem, the members of the populations would
be tours, and one could do mutation/crossing over of good tours to produce
new (and potentially better) tours as generations pass.

Good Source (Please do not copy the Java source):
http://www.theprojectspot.com/tutorial-post/applying-a-genetic-algorithm-to-the-travelling-salesman-problem/5

### Neural Network

Neural networks take some input and, depending on the weights on the edges of 
the network and other things one might add to it, an output is produced that
usually corresponds to some desired result.

TODO

### 2-Opt

According to Wikipedia, 2-Opt was created specifically for the traveling 
salesman problem. The idea is to rearrange your path so that there is no
"crossover", and this is done by reversing particular sections of your
tour. This continues until you do not get a better path.

A complete 2-opt search will try all possible swaps for a particular tour,
so the algorithm can potentially be extremely inefficient.

More details can be found here:
https://en.wikipedia.org/wiki/2-opt

### Dynamic Programming

TODO

Last update: November 30, 2016

## Languages

The following languages and implementations are currently available on the
repository.

Bolded languages are pending implementation/examination (Fall 2016).

* C
    * Greedy
    * Simulated Annealing
* C++
    * Greedy
    * Simulated Annealing
* Clingo
    * Greedy
* Go
    * Greedy
    * Simulated Annealing
* Groovy
    * Greedy
* Haskell
    * Greedy
* Java
    * Greedy
    * Simulated Annealing
    * Dynamic Programming
* Javascript
    * Greedy
    * Genetic
* Julia
    * Greedy
* Kotlin
    * Greedy
* Lisp
    * Greedy
* Matlab
    * Linear (Integer) Programming
    * Greedy
* Objective C
    * Greedy
* Perl
    * Greedy
* Prolog
    * Simulated Annealing
* Python
    * Greedy
    * Genetic
    * Simulated Annealing
    * Neural
    * 2-Opt
    * Dynamic Programming
* R
    * Greedy
* Ruby
    * Greedy
* Rust
    * 2-Opt
* Scala
    * Greedy
    * Genetic
* Swift
    * Genetic
* Verilog
    * Simulated Annealing
* Visual Basic
    * Greedy

Last update: January 2, 2017
