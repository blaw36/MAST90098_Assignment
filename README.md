# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan Scheduling Problem.


# TODO

* Neighbourhood Methods 
    * Generation
        * k_exhange = union all methods involving k or less machines  
            * Current NeighbourhoodGenerator -> KMachineGenerator
            * Neighbourhood generator counts from 2,...,k calling KMachineGenerators
            * (Could actually have made seperate cycle and perm classes and 
                unioned them this way but probs not worth now)
        * Actually over generating with how loaded machines are being handled
        at the moment. 
            * Currently choose one of loaded then choose other,
            * Maybe generate all perms then scan for and remove all such
            perms that don't include a loaded machine. 
            (can keep current case for |L|==1, as will be slightly faster)
    * Initiation, find min instead of sorting, probably faster

    * Extensions to VDS
        * M will keep track of the num_movable machines via update_supporting_structs
        * With access to num movable programs, can use same generation function

        * Will be very similar to GLS

            * Init with feasible instance
            * While not done:
                * Start VD iteration
                    * Loop through neighbours comparing cost, but have to move to 
                         best inner_neighbour (even if worse)
                    * If inner_neighbour better, best_neighbour = inner_neighbour
                    * Make move to best inner_neighbour
                    * If there exists a loaded machine with no moveable programs stop
                        (Technically go to no moveable programs,
                        but this saves time, as no moves from this point nothing 
                        can lower the cost [ programs can only move into most 
                        loaded OR another machine becomes most loaded])
                * Set current instance to best neighbour, if no improvement stop.
                * Reset that all programs can be moved again.

* Population(?) Method
    * What and why?
    * Used succesfully in a similar sitch (same problem or other np hard problem,
        that share similar characteristics)
    * Corrects some deficiency of GLS and/or VDS?
* Generating Instances
    * Standard Case ?
    * 'Extreme' Case (some mixture dist?)
        * Progs are in batches of fixed cost (3,7,15,...,k, 2 * k + 1)
            with 3 times more of each prog cost as cost increases
        * some other engineeered case?
    * Existing instance libraries?\
* Finding min neighbour
   * Currently has to look through complete list of programs to compute cost of switch
   * Given we only switch between k machines, the number of programs we consider the cost of is significantly smaller than the size of          population of programs
   * Can we get away with reducing our data that passes through this function only to the programs relevant to the k machines, and              reduce the size/time of computations in this section?
