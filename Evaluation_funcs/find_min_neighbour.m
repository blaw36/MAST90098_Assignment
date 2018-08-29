function [min_neigh_makespan, program_index] = find_min_neighbour(...
                        order, programs, ...
                        machine_costs, output_Array, machine_start_indices)
                    
    [num_shuffles,length_shuffle] = size(programs);
    num_machines = size(order,2);
    %The indices of the programs to be moved in each shuffle
    %Slicing order by length_shuffle allows for cycles and paths
    index_matrix = repmat(machine_start_indices(order(1:length_shuffle))...
                        ,num_shuffles,1) ...
                        +programs-1;
                    
    %TODO: Indexing temp work around
    costs_all_programs = output_Array(:,1);
    %Table to store inflow and outflow of costs padded with zeros
    in_out_costs = [zeros(num_shuffles,1), ...
                    costs_all_programs(index_matrix),...
                    ...%This last column isn't there for cycles
                    zeros(num_shuffles,num_machines-length_shuffle)...
                    ];
    if length_shuffle == num_machines
        %cycle, so last will move into first
        in_out_costs(:,1) = ...
                costs_all_programs(index_matrix(:,length_shuffle));
    end
    %Per column diff
    changes = - diff(in_out_costs,1,2);
%     
%     output_Array
%     order
%     programs
%     
%     in_out_costs
%     changes
%     machine_costs(order)
    
    %Cost of all machines
    costs = repmat(machine_costs,num_shuffles,1);
    %Update the cost of machines with inflow and outflow
    costs(:,order) = costs(:,order) + changes;
    
    %Finds the most loaded machine for each
    max_costs = max(costs,[],2);
    
    %Finds the best neighbour
    [min_neigh_makespan, program_index] = min(max_costs);
end