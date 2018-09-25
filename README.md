# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.


# TODO
* There is a matlab code to latex app, might be useful
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
    * Looking into creating test cases, looks like the uniform choice was fine
    and is largely used in literature.
    * One possible extreme case is described here (in english)
    "Multi-exhange algorithms for the minimum makespan machine"
    in section "4.1 The Instances"
    http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=FF95ABC5BD3FD45008C6441DBD153927?doi=10.1.1.42.7242&rep=rep1&type=pdf 
    Originally from
    "Algoritmi di ricerca locale basati su grafi di miglioramento per il problema di assegnamento di lavori a macchine"
    but my italian isn't too flash.
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