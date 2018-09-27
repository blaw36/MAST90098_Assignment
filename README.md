# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.

# TODO
* There is a matlab code to latex app, might be useful
* Genetic Algorithm
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
* Testing Scripts:
    * Need to run at least 10 trials, 20?
        say longest takes about 3mins -> longer than an hour
        but a lot of variance in run times so hard to tune this fway but probably fine 
        if overnight
    * Also output tables, found a lib on file exchange that does most of what
    we need (might need to tweak) for triple cell (will have a look later)

    Metric 1
                    machine proportion ...
    num_programs    [alg1_result; alg2_result; alg3_result] 
    ... 

* Thursday Meeting:
    * Genetic Alg
        * Output conversion function to output_array so can use same results analysis
            (Don't need to include this in runtime of alg)