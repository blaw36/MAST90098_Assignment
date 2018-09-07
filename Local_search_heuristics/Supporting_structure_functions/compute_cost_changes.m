function changes = compute_cost_changes(order, programs, ...
                    machine_start_indices, program_costs)

    [num_shuffles,length_shuffle] = size(programs);
    num_selected_machines = size(order,2);
    
    %The indices of the programs to be moved in each shuffle
    %Slicing order by length_shuffle allows for cycles and paths
    index_matrix = repmat(machine_start_indices(order(1:length_shuffle))...
                        ,num_shuffles,1) ...
                        +programs-1;
    
    %program_costs(index_matrix) has same dims as index_matrix unless
    %index_matrix is a vector, i.e. num_shuffles==1
    if num_shuffles == 1
        program_costs = program_costs';
    end
                    
    %Table to store inflow and outflow of costs padded with zeros for diff
    in_out_costs = [zeros(num_shuffles,1), ...
                    program_costs(index_matrix),...
                    ...%This last column isn't there for cycles
                    zeros(num_shuffles,num_selected_machines-length_shuffle)...
                    ];

    if length_shuffle == num_selected_machines
        %cycle, so last will move into first
        in_out_costs(:,1) = ...
                program_costs(index_matrix(:,length_shuffle));
    end
    %Per column diff
    changes = - diff(in_out_costs,1,2);