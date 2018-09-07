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
                 k, L, M, ...
                 machine_costs, machine_start_indices, program_costs,...
                 selected_machines, machine_orders, machine_orders_end)
    
    best_makespan = inf;
    best_neighbour = {};
    
    %Take the union of all cycles and paths involving <= k machines
    for d = 2:k
        for cycle = [true, false]
            %TODO: Want orders in columns for speed
            %TODO: Want to pass batches of orders in parallel loops
            %       for valid->programs->min_neigh
            %Note: Distributed arrays for sharing of data in matlab
            
            %TODO: Think here is the best point to parallelise
            %   for different slice of machine_orders_end
            %   
            for i  = 1:machine_orders_end(d-1,cycle+1)
                
                orders =  selected_machines(d-1).data(:, ...
                                machine_orders(d-1, cycle+1).data(i,:));
                
                            
                [valid_orders, num_valid] = generate_valid_orders(...
                    d, L, M, cycle, orders);
                
                if num_valid == 0
                    continue
                end
                
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