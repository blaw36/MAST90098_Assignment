

def cross_over1(p1, p2, num_jobs, num_machines):
    un_assigned = 1:num_jobs

    machines_p1 = shuffle(p1.machines)
    machines_p2 = shuffle(p2.machines)

    p1i = 1
    p2i = 1

    current_p = 1

    child = {}
    child_i = 1

    while p1i<=num_machines || p2i <= num_machines:
        if current_p == 1:
            while p1i<=num_machines && machines_p1(p1i) not in un_assigned:
                p1i += 1

            child.machines(child_i) = machines_p1(p1i)
            un_assigned = un_assigned\child.machines(child_i)
            current_p = 2

        if current_p == 2:
            while p2i<=num_machines && machines_p1(p2i) not in un_assigned:
                p2i += 1

            child.machines(child_i) = machines_p2(p2i)
            un_assigned = un_assigned\child.machines(child_i)
            current_p = 1

    use greedy to assign rest of un_assigned to child
    return child



def cross_over2(parent_pair, parent_genes, ...
    parent_fitness, num_jobs):

    
    '''
    Want a fast way to pick a non-overlapping (in terms of jobs)
    subset of machines from both parents.

    We know that each parent won't overlap on their own machines so only
    need to inspect collision with other parent.
    '''

    pick an initial random proportion of machines of each parent
        could do 1/2 of each or base of fitness

    find all machine collisions via via vector mult

    remove all of the machines were collisions occur
        from the least fit parent

