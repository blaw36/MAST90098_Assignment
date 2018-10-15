%% fitness_minmaxLinear.m
    
% Can't think of a way to do a probability inversely proportional to 
% makespan at the moment
% Just do linear min-max scaling

% pop_fit_scaled results in a conversion of makespans to a number between 0
% and 1, inversely proportional to the makespan
% 'distribute_across' distributes these into a probability distribution
% across all the elements of the array such that the sum of all the 
% transformed numbers sum to 1.

% Note that we only need relative numbers, not actual probabilities between
% 0 and 1, as we use randsample later, which can deal with an array of
% relative likelihoods.

function makespan_prob = fitness_minmaxLinear(makespan_mat, invert)

    if nargin == 1
        % 'invert' = TRUE is for mutation, It means that we require 
        % probabilities to be inverted (lower makespan, lower probability 
        % of selection). 
        invert = false;
    end

    max_pop_fit = max(makespan_mat);
    min_pop_fit = min(makespan_mat);
    
    if max_pop_fit == min_pop_fit
        % If, somehow, max = min (poor diversity), give random probs
        makespan_prob = rand(size(makespan_mat,1),1);
    else
        % Otherwise, continue with minMaxLinear approach
        if invert
            % Higher makespan, higher probability (mutation selection)
            makespan_prob = (makespan_mat - min_pop_fit)/ ...
                (max_pop_fit-min_pop_fit);
        else
            % Lower makespan, higher probability (parent selection)
            makespan_prob = -(makespan_mat - max_pop_fit)/ ...
                (max_pop_fit-min_pop_fit);
        end
        
end