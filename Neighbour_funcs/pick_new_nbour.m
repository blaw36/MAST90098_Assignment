% Author: Brendan Law
% Date: 16th August 2018

% Function to:
    % Take an input instance of makespan
    % Evaluate all neighbours, given:
        % exchange: k
        % exchange method:
            % 'swap' just runs through all combos of swapping k jobs
            % between machines
        % Neighbours not evaluated:
            % 1) Set of elements being swapped is identical to that being
            % replaced
            % 2) Swapping completely within machines
    % Pick best neighbour 

% !!!!! HAVE NOT YET GENERALISED TO K > 1 !!!!! %

function [new_array,new_makespan] = pick_new_nbour(input_array, k_exch, ...
    exch_function)

    if(exch_function == 'swap')  
        for m = 1:length(input_array)
            for n = 1:length(input_array{m})
            
    end
    
end