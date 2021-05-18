#!/usr/bin/env bash

# The goal of this script is to simplify the collection and the generation of the trial sample data (with n=50 population size).
# The n=50 is arbitrarily set, as the minimum recommendation for the t-test is a sample size larger than 30.

# The code writes the algorithm output variables (i.e. values for the best solution cost, total execution time and the initial solution distance) for each completed execution in a text file.
# Those values were them analyzed using a statistical test (details in the README.md file). The script provides an automated method to deploy the proposed method QA and the benchmark SA. The data set that can be quantified by statistical modeling.


rm -rf ./output/*
for ((i=1;i<=50;i++)); do



    python3.9 ./TSP-Quantitative-Algorithm.py a280.tsp ;
    python3 ./SA-Benchmark.py a280.tsp


echo "====="
done