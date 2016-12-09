# Elastic Net Algorithm
---
This implementation tries to solve the TSP through a heuristic called the 
elastic net algorithm, which is described more in depth [here](http://www.iro.umontreal.ca/~dift6751/paper_potvin_nn_tsp.pdf) [1]. Basically, it tries to stretch an elastic band having 'neurons' on it around the cities in the instance which you feed it. Once it has done this, you have a tour you can take! 

# Usage
---
This program requires `python3`, `numpy`, `matplotlib`, and `seaborn`
It takes files in the TSPLIB format
#### Parameters
+ alpha: Controls the force moving neurons towards cities
+ beta: Controls the force moving neurons towards other neurons
+ neuron_factor: What to multiply number of cities by to get number of neurons
+ n_iters: Number of iterations to run the algorithm
+ radius: Starting radius of the neuron ring 

`-p` adds a solution plot and `-s` will show you the elastic at each iteration

### Examples
For help
```
python run.py <file.tsp> -h 
```
For when you want to optimize your trip to [Djibouti](https://en.wikipedia.org/wiki/Djibouti)
```
python run.py instances/dj38.tsp -i 15  -a 0.7 -f 4 -p -s
```

In my experience, you have to play around with the parameters to get good results. As the number of cities increases, you need many more iterations to get a good tour. The algorithm struggles greatly with bunched or clustered points, and if the parameters are set to poor values the solution will diverge

# References
---
[1] [Potvin, J-Y. The Traveling Salesman Problem: A Neural Network Perspective, 1993.](http://www.iro.umontreal.ca/~dift6751/paper_potvin_nn_tsp.pdf)  
[2] https://github.com/larose/ena
