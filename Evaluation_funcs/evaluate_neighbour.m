function [costs, max_cost, L] = evaluate_neighbour(order, programs, ...
                        output_Array, machine_costs, machine_start_indices)

    if length(programs) == length(order)
        %cycle
        order_indices = machine_start_indices(order);
        shifted_costs = output_Array(programs-1+order_indices);
        first_diff = - shifted_costs(1);
        first_diff = first_diff+shifted_costs(length(programs));
    else
        %path
        order_indices = machine_start_indices(order(1:length(programs)));
        shifted_costs = [output_Array(programs-1+order_indices), 0];
        first_diff = - shifted_costs(1);
    end
    change = [first_diff, -diff(shifted_costs)];
    
    costs = machine_costs;
    costs(order) = costs(order) + change;
    
    [max_cost,L] = max(costs);    
end