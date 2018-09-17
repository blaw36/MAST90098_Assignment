%Computes the change in machine costs for a batch of programs on an order
%% Input:
%   %order: Encodes the cycle/path that the movement takes place on.
%   %programs: A batch of ways to move across the order.
%   %machine_start_indices: The ith value indicates which row of the
%       output_array the ith machine first appears
%   %program_costs: The cost of the programs ordered as in output_array
%% Ouput:
%   %changes: A matrix encoding how each machine in the order changes cost
%                when movement specified by the paird program is done to it
%%
function changes = compute_cost_changes(order, programs, ...
                    machine_start_indices, program_costs, ...
                    num_moves, num_selected, length_move)
    
    %indexed_program_costs takes on the dims of programs costs
    % If it is not indexed by a matrix, so want program_costs to be a 
    % vertical vector to cover this edge case.
    if num_moves == 1
        program_costs = program_costs';
    end
                       
    %The inner matrix used to index program costs is the            
    % indices of the programs to be moved in each shuffle
    %Slicing order by length_move allows for cycles and paths
    %Adding row vector to matrix adds the row vector to every row
    indexed_program_costs = program_costs(...
                    machine_start_indices(order(1:length_move)) ...
                    + programs-1);

    %Constructs a matrix to store the inflow and outflow of costs
    %the left column is a padded 0 column,
    %there is a padded 0 right column for paths as well
    in_out_costs = zeros(num_moves, num_selected+1);
    in_out_costs(:,2:(length_move+1)) = indexed_program_costs;

    if length_move == num_selected
        %cycle, so last will move into first
        in_out_costs(:,1) = indexed_program_costs(:,length_move);
    end
    %Per column diff, measures change resulting in moving programs
    changes = - diff(in_out_costs,1,2);
end