# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.


# TODO
* Local Search
    * Tuning and improving batching, probably need to setup some 
    hyper-parameter optimisation. 
    * Currently VDS defaults to using generate_and_test when k!=2
    and GLS defaults to using par_generate_and_test when k!=2,
    which is a bit inconsistent, but probably optimial for each 
    their feasible ranges. The parallelisation is also only on
    cycles, however probably a waste of time writing code that
    won't be used for sake of consitency.
    * This cycle split parallelisation defs helps so also a shame
    to just throw away as well.
* Genetic Algorithm
* Generating Instances
    * Standard Case ?
    * 'Extreme' Case (some mixture dist?)
        * Progs are in batches of fixed cost (3,7,15,...,k, 2 * k + 1)
            with 3 times more of each prog cost as cost increases
        * some other engineeered case?
    * Existing instance libraries?\
* Testing:
    * For initial determination of k testing, want to compare all of the 
    functions on an even footing. Hence can't use k2_opt gen.
    * Perhaps we also don't do anything parallel here as well?
* Finding min neighbour
   * Currently has to look through complete list of programs to compute cost
   of switch
   * Given we only switch between k machines, the number of programs we 
   consider the cost of is significantly smaller than the size of
   population of programs
   * Can we get away with reducing our data that passes through this
   function only to the programs relevant to the k machines, and              
   reduce the size/time of computations in this section?
   * Reply to ^: Think what we are doing in compute_cost_changes is the best
   we can do with the current supporting structures. Might be wrong though,
   feel free to experiment and alter.