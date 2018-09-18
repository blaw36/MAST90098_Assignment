% Generates and tests the neighbourhood of the current instance
%       Improved speed and memory constraints for k=2
%   TODO: Parameters used for batching still need to be tuned, but pretty
%       sure this will be the way to go.
%% Input:
%   %num_machines: The number of machines
%   %k: The size of the k-exchange
%   %L: The machine numbers of all the loaded machines
%   %M: The number of (movable) programs in each machine
%   %cycle: Whether the order is encoding a cycle or not
%   %machine_costs: The costs of all machines
%   %machine_start_indices: The ith value indicates which row of the
%       output_array the ith machine first appears
%   %program_costs: The cost of the programs ordered as in output_array
%% Ouput:
%   %best_neighbour = {order, programs} encoding move to best found
%   %best_makespan
%%
function [best_neighbour, best_makespan] = k2_generate_and_test(L, M,...
                 machine_costs, machine_start_indices, program_costs)
    k=2;
    num_machines = length(machine_start_indices);
    best_makespan = Inf;
    best_neighbour = {};
 
    [batches, num_workers, use_par] = construct_batches(L, M, k, num_machines);
    
    if use_par == false
        %Just evaluate all of the batches sequentially
        for b = 1:num_workers
            cycle = batches(b).cycle;
            length_move = batches(b).length_move;
            for j = 1:batches(b).size
                order = batches(b).batch(j,:);
                [programs, num_programs] = generate_programs(order, M, k, cycle);
                %Test
                [min_neigh_makespan, prog_index] = find_min_neighbour(...
                                order, programs, ...
                                machine_costs, machine_start_indices, ...
                                program_costs, ...
                                num_programs, k, length_move);

                if min_neigh_makespan < best_makespan
                    best_makespan = min_neigh_makespan;
                    best_neighbour = {order, programs(prog_index,:)};
                end
            end
        end
    else
        %Evaluate the batches of neighbours in parallel
        batch_makespans = Inf(num_workers,1);
        parfor (b = 1:num_workers, num_workers)
            cycle = batches(b).cycle;
            length_move = batches(b).length_move;
            for j = 1:batches(b).size
                order = batches(b).batch(j,:);
                [programs, num_programs] = generate_programs(order, M, k, cycle);
                %Test
                [min_neigh_makespan, prog_index] = find_min_neighbour(...
                                order, programs, ...
                                machine_costs, machine_start_indices, ...
                                program_costs, ...
                                num_programs, k, length_move);

                if min_neigh_makespan < batch_makespans(b)
                    batch_makespans(b) = min_neigh_makespan;
                    batches(b).move = {order, programs(prog_index,:)};
                end
            end
        end
        %Workers finished, so determine best of all batches
        [best_makespan, loc] = min(batch_makespans);
        best_neighbour = batches(loc).move;
    end
end