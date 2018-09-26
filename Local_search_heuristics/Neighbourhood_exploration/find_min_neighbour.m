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
    % curr_makespan: the makespan of the current instance
    % L: The machine numbers of all the loaded machines
    % greedy_flag: a boolean flag indicating whether greedy or not
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
                        num_rows_programs, num_selected, length_move, ...
                        curr_makespan, L, greedy_flag)
                    
    %Firstly finds the unchanged machine with the highest cost
    
    %Checks that all of the loaded machines are included in the order, if
    % not then the max_cost of the other machines is the current makespan
    % as one of the other machines must be a loaded machine
    if num_selected < length(L) || not_subset(L, order)
        max_other_cost = curr_makespan;
        if greedy_flag
            %Can terminate early as we know this option won't be chosen 
            % as it is at least as bad as curr_makespan
            min_neigh_makespan = max_other_cost;
            program_index = 1;
            return;
        end
    else    
        % Otherwise checks all unchanged machines to find their max cost
        non_selected_machines = ones(1,length(machine_start_indices));
        non_selected_machines(order) = 0;
        % 0 prevents the altered machines from being chosen
        max_other_cost = max(machine_costs.*non_selected_machines);
    end
    
    % Next finds the move with the lowest cost
    changes = compute_cost_changes(order, programs, ...
                            machine_start_indices, program_costs, ...
                            num_rows_programs, num_selected, length_move);
    
    changes = machine_costs(order) + changes;
    max_costs = max(changes,[],2);
    [min_neigh_makespan, program_index] = min(max_costs);
    
    % Then takes the max of both
    min_neigh_makespan = max([min_neigh_makespan,max_other_cost]);
end
%%
%TODO: Might be able to optimise this, care though profile viewer reports
%the marker method to be faster then the ismember method but when profile
%viewer is off the ismember method outperforms.

% Inspired by 
% https://au.mathworks.com/matlabcentral/answers/51102-ismember-function-too-slow
%% Input:
    %a: a vector of integers
    %b: a vector of integers
%% Output:
    %res: true if a is not a subset of b false if it is
%%
function res = not_subset(a,b)
    res = any(~ismember(a,b));
    %res = ~all(ismember(a,b));
%     markers = zeros(1,max(max([a,b])));
%     %mark all a elements
%     markers(a) = 1;
%     %Unmark all b elements
%     markers(b) = 0;
%     %If any remain marked then a is not a subset of b
%     res = any(markers);
end