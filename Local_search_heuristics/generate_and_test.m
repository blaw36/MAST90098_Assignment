function [best_neighbour, best_makespan] = generate_and_test(...
                     num_machines, k, L, M, ...
                     machine_costs, machine_start_indices, program_costs)
    
    best_makespan = inf;
    best_neighbour = {};
    for d = 2:k
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