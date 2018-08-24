# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan Scheduling Problem.


# TODO

* Affect of multiple loaded machines on everything
    * Two possible views
        * Include one of the most loaded machines
        * Include all of the most loaded machines
    * Have to pick 1
        * Doesn't break connectivity
        * Will have some changes to big oh and implementation

* Generation
    * Didn't have to use iterators, however many fast sub algs needed 
    'book-keeping' info, didn't really want to repeatedly pass bundles between
    * Need to check further
    * Switch GLS to using generator
    * Optimize + Tidy/Refactor
* Changes to data structures
    * Need O(1) for 
        * Retrieve cost of program by index in machine
        * Retrieve total cost of machine
        * Retrieve number of programs in each machine
        * Retrieve total cost of instance
        * Retrieve number of 'moved/movable' programs in each machine 
                (VDS, could be separate data structure)
    * Need to be able to isolate 'moved' programs in each machine
        * Eg moved programs could be pushed to the end of a list
* Evaluate the cost of each neighbour as they come, keeping best
* Extensions to VDS
    * With access to num movable programs, can use same generation function
        * Pass the num of movable programs in each machine, instead of the num
            of programs
        * If a machine has no movable programs then don't pass it 
            (Or need 0 size exception handling in gen, probs worse sol)
        * This will generate a move on the subset
        * Just need to 're-index' the generated move at end
            * eg [(i,j),(k,m)] 
            * ith NEM -> jth NEM, moving (kth movable, mth movable)
                NEM = non-empty machine 
    * Will be very similar to GLS
        * Init with feasible instance
        * While true:
            * Start VD iteration
                * Loop through neighbours comparing cost, but have to move to best
                    (even if worse)
                * If best neighbour record
                * Make move, recording moves (ie shrinking neighbour)
                * If no moveable programs in most loaded machine stop
                    (Technically go to no moveable machines,
                    but this saves time, as no moves from this point can lower
                    the cost [ programs can only move into most loaded OR
                                another machine becomes most loaded])
            * Set current instance to best sequence, if no improvement stop.