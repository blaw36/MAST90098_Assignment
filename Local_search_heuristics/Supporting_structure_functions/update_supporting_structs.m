% Updates the supporting structures
%% Input:
%   %output_array: The newly updated output_array
%   %move: the move that resulted in the update
%   %num_machines: the number of machines
%   %fix_moved: Indicates whether the 4th col of output_array exists and
%       whether moved programs should be flagged as being moved.

%   %program_costs: the cost of the programs ordered as in output_array
%   %machine_start_indices: The ith value indicates which row of the
%       output_array the ith machine first appears
%   %M: The number of (movable) programs in each machine
%   %machine_costs: The costs of all machines
%   %L: The machine numbers of all the loaded machines
%% Ouput:
%   %As defined above but updated
%%

function ...
[program_costs, machine_start_indices, M, machine_costs, L] ...
    = update_supporting_structs(move, output_array, num_machines, ...
                            program_costs, ...
                            machine_start_indices, M, machine_costs, ...
                            makespan, fix_moved)
    if nargin == 8
        fix_moved = false;
    end
    
    order = move{1};
    programs = move{2};
    num_moves = length(programs);
    num_selected = length(order);
    
    %Update machine_costs
    changes = compute_cost_changes(order, programs, ...
                                machine_start_indices, program_costs);
    machine_costs(order) = machine_costs(order) + changes;
    
    %Have to update program_costs after machine_costs as uses old locations
    program_costs = output_array(:,1);
    
    %Update M
    if fix_moved
        M(order(1:num_moves)) = M(order(1:num_moves)) - 1;
    else
        if num_selected>num_moves
            %path
            M(order(1)) = M(order(1)) - 1;
            M(order(num_selected)) = M(order(num_selected)) + 1;
        end
        %cycle has no change
    end
    
    %TODO: Do rolling update, instead of recalc
    %Find where each machine first appears in table (if at all)
    machine_start_indices = zeros(1, num_machines);
    for i = size(output_array,1):-1:1
        machine = output_array(i, 2);
        machine_start_indices(machine) = i;
    end
    
    %Update machine_start_indices
    %ouput_array sorted by machine
    %moving programs in array causes start positions of machines to move up
    %and down. Net movement of start pos of machine i is flow below -flow
    %above
%     for i = 1:num_machines
%         current_pos = machine_start_indices(i)
%         padded_rel_pos = [0, order<current_pos, 0]
%         delta = diff(padded_rel_pos)
%         current_pos = current_pos + sum(delta(1:num_moves))
%         machine_start_indices(i) = current_pos;
%     end
    
    L = find(machine_costs==makespan);
    
%     order
%     programs
%     output_array
%     M
%     machine_costs
%     machine_start_indices
%     L
end
