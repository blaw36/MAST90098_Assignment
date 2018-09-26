%% fit_to_prob_minmaxLinear.m
    
% Can't think of a way to do a probability inversely proportional to 
% makespan at the moment
% Just do linear min-max scaling

% pop_fit_scaled results in a conversion of makespans to a number between 0
% and 1, inversely proportional to the makespan
% 'distribute_across' distributes these into a probability distribution
% across all the elements of the array such that the sum of all the 
% transformed numbers sum to 1.

function makespan_prob = fit_to_prob_minmaxLinear(makespan_mat, ...
    distribute_across)

    if nargin == 1
        % 'distribute_across' is used for parent selection (or any other
        % process requiring us to choose 1 element out of all the arrays)
        distribute_across = false;
    end

    max_pop_fit = max(makespan_mat);
    min_pop_fit = min(makespan_mat);
    makespan_prob = (makespan_mat - min_pop_fit)/(max_pop_fit-min_pop_fit);
    if distribute_across
        pop_fit_scaled_tot = sum(makespan_prob);
        makespan_prob = makespan_prob./pop_fit_scaled_tot ;
    end

end