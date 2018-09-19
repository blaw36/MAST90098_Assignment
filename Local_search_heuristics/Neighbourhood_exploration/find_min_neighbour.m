%% find_min_neighbour.m
% Given an ordered sequence of machines, and all possible ways to move
% the programs between the machines, find the lowest cost movement of programs.
%% Input:
    % order: Encodes the cycle/path that the movement takes place on.
    % programs: A matrix of ways to move programs between the machines 
        % specified in the order vector.
    % machine_costs: The ith value indicates the cost of the ith machine
    % machine_start_indices: The ith value indicates which row of the
        % output_array the ith machine first appears
    % program_costs: The cost of the programs ordered as in output_array
    % num_programs: the number of rows of the matrix 'programs' (number of
        % possible ways to move programs between the machines)
    % num_selected: the number of machines involved in the movement
    % length_move: the number of programs being moved in each shuffle
%% Output:
% program_index: the row of 'program' which contains the min makespan
    % program movement
% min_neigh_makespan: the resulting makespan from the min makespan program
    % movement
%%
function [min_neigh_makespan, program_index] = find_min_neighbour(...
                        order, programs, ...
                        machine_costs, machine_start_indices, ...
                        program_costs, ...
                        num_rows_programs, num_selected, length_move)
                    
    changes = compute_cost_changes(order, programs, ...
                            machine_start_indices, program_costs, ...
                            num_rows_programs, num_selected, length_move);
    
    % Finds the move with the lowest cost
    changes = machine_costs(order) + changes;
    max_costs = max(changes,[],2);
    [min_neigh_makespan, program_index] = min(max_costs);
    
    % Checks the unchanged machines and finds their max cost
    non_selected_machines = ones(1,length(machine_start_indices));
    non_selected_machines(order) = 0;
    % 0 prevents the altered machines from being chosen
    max_other_cost = max(machine_costs.*non_selected_machines);
    
    min_neigh_makespan = max([min_neigh_makespan,max_other_cost]);
end