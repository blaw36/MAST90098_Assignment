# MAST90098-Assignment #
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.

The three heuristics explored were 
1. Greedy Local Search (GLS)
2. Kernighan and Lin Variable Depth Search (VDS)
3. Genetic Algorithm (GA)

GLS was the fastest of the algorithms but tended to get trapped in local
minima. VDS typically achieved the Lowest Makespans out of 
algorithms, but also had the longest run times. GA fell into a middle 
ground between the two methods with its tuned parameters,
outputting better solutions then GLS, much faster than VDS, but with 
higher makespans then VDS. The performance of GA is quite tune-able 
however, and it can be altered to achieve comparable results to VDS, 
at the cost of more time.

## Project Organisation ##

If you just want to play around with algorithms, their parameters and 
different test cases you can can use runscript.m

### Local_search_heuristics ###

Contains all of the code for GLS and VDS.

### Population_based_heuristics ###

Contains all of the code for our genetic algorithm. 

### Generate_makespan_instances ###

Contains the code used to generate our test cases.

### Experiments ###

Contains code for running the algorithms on a range of test cases,
and also for tuning parameters.

### Analysis Funcs ###

Contains the code for doing analysis, also includes graphics functions.