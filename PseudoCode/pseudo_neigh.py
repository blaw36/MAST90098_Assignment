'''
k-ex:
    All cycles and paths involving k machines (cycles move k programs, paths 
    move k-1 programs) such that the most loaded machine is one of the k.

Feels pretty intuitive to use a generator for the neighborhood,
    no generators in matlab by default but can implement one via something like
    https://stackoverflow.com/questions/21099040/what-is-the-matlab-equivalent-of-the-yield-keyword-in-python

Central Code of GLS:
    1. Generate
    2. Test/Compute Cost

Problem of generating,

Can be reduced to the problem of establishing a total order amongst the elements.
Then just list the next element.

need function 
    next = gen(k, loaded_machine_index, M, curr)

        where M = [num_programs_in_machine_i]

Can use a nested lexicographic order on perms, then on programs

for four machines of sizes M=(2,3,1,2) with k=2

Paths
[(1,2), (1)]
[(1,2), (2)]
[(2,1), (1)]       (has to include 2 so doesnt move to (1,3))
[(2,1), (2)]
[(2,1), (3)]
[(2,3), (1)]
[(2,3), (2)]
[(2,3), (3)]
[(2,4), (1)]
[(2,4), (2)]
[(2,4), (3)]
[(3,2), (1)]
[(4,2), (1)]
[(4,2), (2)]
Cycles
[(1,2), (1,1)]       (pair 1 ... see below)
[(1,2), (1,2)]
[(1,2), (1,3)]
[(1,2), (2,1)]
[(1,2), (2,3)]
[(1,2), (2,3)]
[(2,1), (1,1)]       (pair 1)                  (has to include 2 so doesnt move to (1,3))
[(2,1), (1,2)]
[(2,1), (2,1)]
[(2,1), (2,2)]
[(2,1), (3,1)]
[(2,1), (3,2)]
[(2,3), (1,1)]
[(2,3), (2,1)]
[(2,3), (3,1)]
[(2,4), (1,1)]
[(2,4), (1,2)]
[(2,4), (2,1)]
[(2,4), (2,2)]
[(2,4), (3,1)]
[(2,4), (3,2)]
[(3,2), (1,1)]
[(3,2), (1,2)]
[(3,2), (1,3)]
[(4,2), (1,1)]
[(4,2), (1,2)]
[(4,2), (1,3)]
[(4,2), (2,1)]
[(4,2), (2,2)]
[(4,2), (2,3)]

Cycle Problem:

    c1c2...ck == c2...ckc1 == ...
    
    Can leave in initially, but will inflates size of space by k until fixed.
    
    How can we avoid this while iterating through?

'''

def generate(k, I, M):
    '''
    yields the neighbours of the current instance
    
    Most loaded machine has to be included,
        - Remove it from choice and weave it in at end
    
    O(Neigh)
        - O(paths) + O(cycles)
        - Cycles:
            - Choose order, k*falling_factorial(m-1, k-1)
            - Choose program, prod_i |Mi| <= max(|Mi|)^k
            - Total, k*falling_factorial(m-1, k-1)*max(|Mi|)^k
        - Paths:
            - Choose order, k*falling_factorial(m-1, k-1)
            - Choose program, prod_i |Mi| <= max(|Mi|)^(k-1)
            - Total, k*falling_factorial(m-1, k-1)*max(|Mi|)^(k-1)

        - Combined, k*falling_factorial(m-1, k-1)*max(|Mi|)^k
            - O( k*(m^k)*max(|Mi|)^k )

        Note: never explictly includes n, ( max(|Mi|) could approach it though)
            -> should be able to avoid n based iteration

    parameters:
        k: as above
        I: The index of the most loaded machine
        M: [M1, ..., Mm] where Mi is the number of programs in machine i

    return: [order, programs]
        where |order| = k, orderi = the index of the ith machine of the 
                                    path/cycle
            |programs| = k, or k-1, programsi = the index of the ith program
                                                to be moved
    '''

    return [order, programs]

def compute_cost(instance_state, move):
    '''
    If the lookups specified below can be done in constant time,
    then this alg is O(k)

    parameters:
        instance_state = some encoding of current situation
        move = [order, programs]
    '''
    highest_cost = instance_state.cost

    order = move[0]
    programs = move[1]

    for i in range(2, len(order)):
        in_machine = order[i-1]
        curr_machine = order[i]

        in_index = programs[i-1]
        out_index = programs[i]

        #Want to be able to perform these three lookups in constant time
        in_cost = instance_state.machines[in_machine].\
                                programs[in_index].cost
        out_cost = instance_state.machines[curr_machine].\
                                programs[in_index].cost[out_index].cost
        curr_machine_cost = nstance_state.machines[curr_machine].cost

        updated_machine_cost = curr_machine_cost + (in_cost-out_cost)
        highest_cost = max(updated_machine_cost, highest_cost)

    #TODO:Need a cleanup for cycles, same logic just an edge case

    return highest_cost

def gls_step(curr_state):
    '''
    Number of neighbours  -> number of iterations
        - O( k*(m^k)*max(|Mi|)^k )

    Cost Per iteration
        - O(k)

    total run time each step
        - O( k^2*(m^k)*max(|Mi|)^k ) + cost of updating to new state

    '''
    best_move = None # stay where you are
    best_cost = curr_state.cost

    k = curr_state.getk()
    I = curr_state.getI()
    M = curr_state.getM()

    while neigh_move = generate(k, I, M):
        cost = cost(curr_state, neigh_move)

        if cost < best_cost:
            best_cost = cost
            best_move = neigh_move

    if best_move != None:
        #Only happens once so doesn't matter what O is (within reason)
        new_state = make_move(current_state, best_move)
    else:
        new_state = curr_state

    return new_state