# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.

# TODO
* Measuring empirical performance of algs might be worth looking into
https://theory.stanford.edu/~aiken/publications/papers/fse07.pdf

* Genetic
    * Clean up
        * Remove dead code
            * Less work for us
        * Better docstrings...
    * Can refactor to have machine costs calculated on a rolling basis.
        * Will decrease the relative time costs of methods that rely on 
        machine costs
    * Refactor init so can use any mutate
    * Union comp mutate
        * Apply different random mutate for even more diverse pop
    * Better initiation?
        * If performance is better than vds at higher n,
            -> exploring pretty well
            maybe can somehow start in a better spot?
        * Possible Algs:
            * Throw in some random proportion of jobs,
            then greedily fill the rest
            * 
    * 'Dynamic'
        * Pop size
        * mutation
        * other?
        * worth?
    * Refactor for better matrix operations and possible parallelisation
    * Probabaly no sig gains from playing around with term cond
        * Just want to avoid stopping 'too early'
        * Hmm maybe could do some calc based on the prop
        of surviving children to parents for a stopping cond?
    * Anything in fitness?
        * Need to pass params down?
        * Every section use same fitness, function maybe?
            lot less free params
        * If using neg-exp no need to normalize
    * Anything in pop culling?
        * Use a fitness function in pop-culling?
    * Other params we should pass down?
* Genetic Param Tuning:
    * Maybe do informal tuning via rough experiments
        * Anything we can eye and say
            "This was clearly better"
    * then do fine tuning via matlab global opt toolbox?



* Presentation:
* Content:
* Division of speaking: