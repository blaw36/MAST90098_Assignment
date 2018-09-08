% Updates output_array with the new move.
%% Input:
%   %output_array: Assumed to be sorted by machine_num, (then movable)
%       rows - a job allocated to a position in a machine
%       columns - job_cost, machine_num, unique job_id, (movable)
%   %machine_start_indices: The ith value indicates which row of the
%       output_array the ith machine first appears
%   %move: {order, programs}
%   %fix_moved: Indicates whether the 4th col of output_array exists and
%       whether moved programs should be flagged as being moved.
%% Ouput:
%   %output_array: The altered output_array
%%

function [output_array] = ...
            make_move(output_array, machine_start_indices, move, fix_moved)
    
    %TODO: Nargin, probably faster    
    if ~exist('fix_moved','var')
        fix_moved=false;
    end
                             
    order_indices = move{1};
    program_indices = move{2};
    num_moves = length(program_indices);
    num_machines = length(order_indices);
    
    %Make the moves
    for i = 1:num_moves
        target_index = i+1;
        
        %If cycle then move back to front
        if i+1>num_machines
            target_index = 1;
        end
        
        %Finds where the program to be moved is
        program_index = machine_start_indices(order_indices(i))...
                        + program_indices(i)-1;
        %Moves the program to the target machine
        output_array(program_index, 2) = order_indices(target_index);
        %Flags that this program can no longer be moved
        if fix_moved
           output_array(program_index, 4) = 0;
        end
    end
    
    %Re-sorts the output_array by machine, (then whether movable)
    if fix_moved
        output_array = sortrows(output_array, 4, 'descend');
    end
    output_array = sortrows(output_array, 2);
end