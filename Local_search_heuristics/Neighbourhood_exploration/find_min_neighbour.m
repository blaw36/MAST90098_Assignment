%For a given order specifying the target machines, and a matrix of possible
%ways to move the programs between the machines. Computes the lowest cost
%movement of programs.

function [min_neigh_makespan, program_index] = find_min_neighbour(...
                        order, programs, ...
                        machine_costs, machine_start_indices, ...
                        program_costs)
                    
    
    changes = compute_cost_changes(order, programs, ...
                                    machine_start_indices, program_costs);
    
    %Finds the shuffle with the lowest cost
    changes = machine_costs(order) + changes;
    max_costs = max(changes,[],2);
    [min_neigh_makespan, program_index] = min(max_costs);
    
    %Checks the unchanged machines and finds their max cost
    non_selected_machines = ones(1,length(machine_start_indices));
    non_selected_machines(order) = -1;
    %-1 prevents the altered machines from being chosen
    max_other_cost = max(machine_costs.*non_selected_machines);
    
    min_neigh_makespan = max([min_neigh_makespan,max_other_cost]);
end