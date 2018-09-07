% Generates and tests the neighbourhood of the current instance
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
function [best_neighbour, best_makespan] = generate_and_test(...
                     num_machines, k, L, M, ...
                     machine_costs, machine_start_indices, program_costs)
    
    best_makespan = inf;
    best_neighbour = {};
    
    %Take the union of all cycles and paths involving <= k machines
    for d = 2:k
        %TODO: Selected_machines and machine_orders static between
        %when this func is called could be saved in mem to save time.
        selected_machines = combnk(1:num_machines, d);
        for cycle = [true, false]
            if cycle
                %Fix the first element and then perm the remainder.
                machine_orders = [ones(factorial(d-1),1), perms(2:d)];
                machine_order_end = prod(1:(d-1));
            else
                machine_orders = perms(1:d);
                machine_order_end = prod(1:d);
            end

            for i  = 1:machine_order_end
                [valid_orders, num_valid] = generate_valid_orders(...
                                d, L, M, cycle,...
                                selected_machines, machine_orders(i,:));
                if num_valid == 0
                    continue
                end
                
                %TODO: Here is the most obvious place to parallelize
                for j = 1:num_valid
                    order = valid_orders(j,:);
                    programs = generate_programs(order, M, d, cycle);
                    
                    %Test
                    [min_neigh_makespan, prog_index] = find_min_neighbour(...
                                    order, programs, ...
                                    machine_costs, machine_start_indices, ...
                                    program_costs);

                    if min_neigh_makespan < best_makespan
                        best_makespan = min_neigh_makespan;
                        best_neighbour = {order, programs(prog_index,:)};
                    end
                end       
            end
        end
    end
end