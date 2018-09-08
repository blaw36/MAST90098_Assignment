% Generates and tests the neighbourhood of the current instance

%NOTE: Changing to largely columns had almost no effect on
%       speed
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
function [best_neighbour, best_makespan] = par_generate_and_test(...
                 k, L, M, ...
                 machine_costs, machine_start_indices, program_costs,...
                 selected_machines, machine_orders, machine_orders_end)
    
    best_makespan = inf;
    best_neighbour = {};
    
    %Take the union of all cycles and paths involving <= k machines
    for d = 2:k
        %Prune selections of machines without a loaded machine
        valid_machines = selected_machines(d-1).data(...
            any(ismember(selected_machines(d-1).data,L),2),:);
        
        batch_makespans = Inf(2,1);
        batch_neighbours(2).move = {};
        
        parfor c = 1:2
            cycle = logical(c-1);
            n = numel(valid_machines(:, machine_orders(d-1, c).data));
            orders = reshape(...
               valid_machines(:, machine_orders(d-1, c).data),...
              n/d,d);

            [valid_orders, num_valid] = generate_valid_orders(...
                d, M, cycle, orders);

            if num_valid == 0
                continue
            end
            
            for i = 1:num_valid
                order = valid_orders(i,:);
                programs = generate_programs(order, M, d, cycle);

                %Test
                [min_neigh_makespan, prog_index] = find_min_neighbour(...
                                order, programs, ...
                                machine_costs, machine_start_indices, ...
                                program_costs);

                if min_neigh_makespan < batch_makespans(c)
                    batch_makespans(c) = min_neigh_makespan;
                    batch_neighbours(c).move = {order, programs(prog_index,:)};
                end
            end
        end
        [best_makespan, loc] = min(batch_makespans);
        best_neighbour = batch_neighbours(loc).move;
    end
end