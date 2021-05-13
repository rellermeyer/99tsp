#!/usr/bin/env bash

rm -rf ./output/*
for ((i=1;i<=50;i++)); do



    python3.9 ./TSP-Quantitative-Algorithm.py a280.tsp ;
    python3 ./SA-Benchmark.py a280.tsp


echo "====="
done