# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.


# TODO
* Local Search
    * Tuning and improving batching, probably need to setup some 
    hyper-parameter optimisation. 
    * Both VDS and GLS default to non-parallel standard imp if k2_opt = false
    * The new batching method and the old cycle/path method have very 
    similar performance, prior to parallelisation and
    they have the same batches for many cases
    => with proper parameter tuning batching will be the dominate the old
    method in performance (as can match base, then continue to scale)
    * par_gen_and_test no longer in use
* Genetic Algorithm
* Generating Instances
    * Standard Case ?
    * 'Extreme' Case (some mixture dist?)
        * Progs are in batches of fixed cost (3,7,15,...,k, 2 * k + 1)
            with 3 times more of each prog cost as cost increases
        * some other engineeered case?
    * Existing instance libraries?\
* Testing:
    * 
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