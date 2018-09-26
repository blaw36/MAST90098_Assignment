%% k2_generate_and_test.m
% Generates and tests the neighbourhood of the current instance
% Improved speed and memory constraints for k=2
%% Input:
    % curr_makespan: the makespan of the current instance
    % L: The machine numbers of all the loaded machines
    % M: The number of (movable) programs in each machine
    % num_machines: The number of machines    
    % machine_costs: The ith value indicates the cost of the ith machine
    % machine_start_indices: The ith value indicates which row of the 
        % output_array the ith machine first appears
    % program_costs: The cost of the programs ordered as in output_array
    % greedy_flag: a boolean flag indicating whether greedy or not
%% Output:
    % best_neighbour = {order, programs} encoding move to best found
    % best_makespan: makespan value of lowest makespan ('best') neighbour
%%
function [best_neighbour, best_makespan] = k2_generate_and_test(...
    curr_makespan, L, M,...
    num_machines,...
    machine_costs, machine_start_indices, program_costs, greedy_flag)
    
    %Equivalent to if ~exist('greedy_flag','var')
    if nargin == 7
        greedy_flag = false;
    end

    k=2;
    best_makespan = Inf;
    best_neighbour = {};
 
    % Split work into batches for a number of workers
    [batches, num_workers, valid_orders, use_par] = construct_batches(L, M, k, num_machines);
    
    if use_par == false
        % Just evaluate all of the batches sequentially (loop through each
        % worker's batch)
        for b = 1:num_workers
            cycle = batches(b).cycle;
            length_move = batches(b).length_move;
            batch_orders = valid_orders(batches(b).start:batches(b).finish,:);
            for j = 1:batches(b).size
                order = batch_orders(j,:);
                % Generate program move combinations
                [programs, num_programs] = generate_programs(order, M, k, cycle);
                % Find the minimum makespan neighbour
                [min_neigh_makespan, prog_index] = find_min_neighbour(...
                                order, programs, ...
                                machine_costs, machine_start_indices, ...
                                program_costs, ...
                                num_programs, k, length_move, ...
                                curr_makespan, L, greedy_flag);

                if min_neigh_makespan < best_makespan
                    best_makespan = min_neigh_makespan;
                    best_neighbour = {order, programs(prog_index,:)};
                end
            end
        end
    else
        % Evaluate the batches of neighbours in parallel
        batch_makespans = Inf(num_workers,1);
        parfor b = 1:num_workers
            cycle = batches(b).cycle;
            length_move = batches(b).length_move;
            batch_orders = valid_orders(batches(b).start:batches(b).finish,:);
            for j = 1:batches(b).size
                order = batch_orders(j,:);
                % Generate program move combinations
                [programs, num_programs] = generate_programs(order, M, k, cycle);
                % Find the minimum makespan neighbour
                [min_neigh_makespan, prog_index] = find_min_neighbour(...
                                order, programs, ...
                                machine_costs, machine_start_indices, ...
                                program_costs, ...
                                num_programs, k, length_move, ...
                                curr_makespan, L, greedy_flag);

                if min_neigh_makespan < batch_makespans(b)
                    batch_makespans(b) = min_neigh_makespan;
                    batches(b).move = {order, programs(prog_index,:)};
                end
            end
        end
        % Workers finished, determine best neighbour from all batches, and
        % that best neighbour's move set
        [best_makespan, loc] = min(batch_makespans);
        best_neighbour = batches(loc).move;
    end
end