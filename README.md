# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.

# TODO
* Measuring empirical performance of algs might be worth looking into
https://theory.stanford.edu/~aiken/publications/papers/fse07.pdf
* So many bad possible instances just moving randomly unlikely to do anything
so idealy would have a less random system for mutation and or crossover.
* 

* Genetic
    * Can refactor to have machine costs calculated on a rolling basis.
        * Will decrease the relative time costs of methods that rely on 
        machine costs
    * Tried reducing symmetry by sorting all machines descending cost
        degraded performance by a bit, at cost of more time from sorting