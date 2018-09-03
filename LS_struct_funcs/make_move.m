function [new_array] = make_move(outputArray, machine_start_indices, move)
    order_indices = move{1};
    program_indices = move{2};
    new_array = outputArray;
    
    %Relies on outputArray being sorted
    num_moves = length(program_indices);
    num_machines = length(order_indices);
    for i = 1:num_moves
        %Faster
        target_index = i+1;
        if i+1>num_machines
            target_index = 1;
        end
        
        new_array(...
             machine_start_indices(order_indices(i))+program_indices(i)-1 ...
                    ,2) = order_indices(target_index);
    end
    %Note this new_array is now unsorted.
end

