# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.

# TODO
* There is a matlab code to latex app, might be useful
* Local Search
    * TODO: Why is k2_opt gls slower then std for edge case of prop_machines =1?
        As far as I can tell they do exactly the same thing
    * Optimisation of not_subset?
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
    * Do we want to also report relative to LPT method?
    * Instead of the current 2nd graph do we want to scale the average makespan somehow
    (suppose this is already sort of covered by relative error but might be a better way?)
    * 'Hardest' machine proportion not consistent accross algorithms and generators
    will need to consider and properly report on (and 'hardest' in terms of what metric)
* Testing Scripts:
    * Decide on all the tests we want to run, maybe do initial rough analysis
    in terms of just a few trials. Need to finalise code before final results
    are locked in. (also experiments with large numbers of trials could take
    a long time to run, [ie leave running over lunch/night])
    * Reading through the spec, think we'll need
        * 1.c choose_k_gls_script
        * (1.c.2 outside of report but needed if only briefly?) k2_opt_perf_gain_script
            * exact same output so just need time graphs here
        * 1.d, 2.c, 3. compare_all_script                      (Same test cases)
            * Maybe only cover hard test case here in final comparision
            and not in other scripts?(otherwise doubling amount of work)
    * How many trials and on what computer do we want to run these?
    * Automatically save figures instead of waiting for user input

* Thursday Meeting:
    * Go over progress/issues                  (<<Together>>)
    * Fully setout project template with rough dot points covering what we want
        to do in each unfinished section       (<<Together>>)
    * (<<Subdivide from here?>>)
    * Decide on final experimental design,
        * Choose appropriate ranges and num trials (at least for GLS and VDS
            unlikely to change much from this point on, not sure on genetic)
        * What machine?
        * What metrics are we reporting on?
    * Genetic Alg
        * Output conversion function to output_array so can use same results analysis
            (Don't need to include this in runtime of alg)
        * Refactor?
        * Hows performance currently tracking?
        * What areas need most work?
            * Prioritize these ones.
    * Report/Latex key areas
        * Description of k-exhange and proofs?
        * Pseudo-code sections and proof vds meets conds?
        * Justification of 
        * Probably should also have pseudo code for genetic,
            * Description of higher level wrapper
            * Description of methodology of each of the final functions chosen