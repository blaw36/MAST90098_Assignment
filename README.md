# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.

# TODO
* Measuring empirical performance of algs might be worth looking into
https://theory.stanford.edu/~aiken/publications/papers/fse07.pdf

* Genetic
    * Clean up
        * Get rid of dead code
        * Tidy
    * Can refactor to have machine costs calculated on a rolling basis.
        * Will decrease the relative time costs of methods that rely on 
        machine costs
    * Better initiation?
        * alter init_simple_grad_rand so can choose and vary num_shuffles
    * 'Dynamic'
        * Pop size
        * mutation
        * other?
        * worth?
    * Refactor for better matrix operations and possible parallelisation
    * Anything in fitness?
        * Need to pass params down?
        * Every section use same fitness, function maybe?
            lot less free params
        * If using neg-exp no need to normalize
* Genetic Param Tuning:
    * By hand just for choice of functions in each section
    * then do fine tuning of params via matlab global opt toolbox?



* Presentation:
* Content:
* Division of speaking: