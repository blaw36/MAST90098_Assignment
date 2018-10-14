# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.

# TODO
* Measuring empirical performance of algs might be worth looking into
https://theory.stanford.edu/~aiken/publications/papers/fse07.pdf

* Genetic
    * Clean up
        * Get rid of dead code
        * Finalise code functionality
        * Tidy
    * Anything in fitness?
        * Normalisation needed?, fro genetic alg iteration
            ```
    % TODO: Should probably be inside function
    % Convert to between 0 and 1
    % The problem here is the min gets allocated 0, and the max gets
    % allocated 1
    min_prob = min(prob_mutation_select);
    max_prob = max(prob_mutation_select);
    prob_mutation_select = ...
        (prob_mutation_select - min_prob)./...
        (max_prob - min_prob );
        ```
* Genetic Param Tuning:
    * By hand just for choice of functions in each section
    * then do fine tuning of params via matlab global opt toolbox?