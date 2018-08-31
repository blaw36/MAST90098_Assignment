%For a given order specifying the target machines, and a matrix of possible
%ways to move the programs between the machines. Computes the lowest cost
%movement of programs.

function [min_neigh_makespan, program_index] = find_min_neighbour(...
                        order, programs, ...
                        machine_costs, machine_start_indices, ...
                        program_costs)
                    
    [num_shuffles,length_shuffle] = size(programs);
    num_selected_machines = size(order,2);
    
    %The indices of the programs to be moved in each shuffle
    %Slicing order by length_shuffle allows for cycles and paths
    index_matrix = repmat(machine_start_indices(order(1:length_shuffle))...
                        ,num_shuffles,1) ...
                        +programs-1;
    
    %program_costs(index_matrix) has same dims as index_matrix unless
    %index_matrix is a vector, i.e. num_shuffles==1
    if num_shuffles == 1
        program_costs = program_costs';
    end
                    
    %Table to store inflow and outflow of costs padded with zeros for diff
    in_out_costs = [zeros(num_shuffles,1), ...
                    program_costs(index_matrix),...
                    ...%This last column isn't there for cycles
                    zeros(num_shuffles,num_selected_machines-length_shuffle)...
                    ];

    if length_shuffle == num_selected_machines
        %cycle, so last will move into first
        in_out_costs(:,1) = ...
                program_costs(index_matrix(:,length_shuffle));
    end
    %Per column diff
    changes = - diff(in_out_costs,1,2);
    
    %Finds the shuffle with the lowest cost
    changes = machine_costs(order) + changes;
    max_costs = max(changes,[],2);
    [min_neigh_makespan, program_index] = min(max_costs);
    
    %Checks the unchanged machines and finds their max cost
    %TODO: This currently is the speed bottleneck 
    %---
    non_selected_machines = 1:length(machine_start_indices);
    non_selected_machines(order) = [];
    max_other_cost = max(machine_costs(non_selected_machines));
    %---
    
    min_neigh_makespan = max([min_neigh_makespan,max_other_cost]);
end