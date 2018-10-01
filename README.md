# MAST90098-Assignment
A group project, exploring heuristics for solving the Minimum Makespan 
Scheduling Problem.

# TODO
* Genetic alg v2 appears to get stuck when run on hard test case here,
shuffle_elmts_pairs
...
while isempty(m2_elements)
    machines_shuffled(2) = randsample([1:(machines_shuffled(1)-1),...
    (machines_shuffled(1)+1):num_machines],1);
    m2_elements = find(gene_array == machines_shuffled(2));
end