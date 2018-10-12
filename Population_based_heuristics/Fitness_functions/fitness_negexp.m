%% fitness_negexp.m
    
% fitness = exp(a*-makespan)
% TO DO: tune a! This kind of plays around with how strongly we preference
% weak and strong cases, and how much we 'differentiate' them from the
% rest. Draw some histograms and you'll see. Any other scaling constants
% are not relevant here as randsample takes care of it (it will read a
% probability vector of [1,2] same as [100,200])

% Current param is 3: looked nice on a histogram (transformed the skewed
    % data so the peak was in the middle, giiving a siginficantly higher
    % weighting to better and lower weighting to worse individuals, with the
    % middle 80% or so getting similar-ish probabilities)
% Divided by max to scale the exponent a little
% REALLY ARBITRARY AT THE MOMENT!

% Idea here is to give more spread between best and worst cases I'd say.
% Linear preserves the relative relationships between the makespans (which
% all tend to clump up)

% Note that we only need relative numbers, not actual probabilities between
% 0 and 1, as we use randsample later, which can deal with an array of
% relative likelihoods.

function makespan_prob = fitness_negexp(makespan_mat, invert)

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
        % Otherwise, continue with approach
        if invert
            % Higher makespan, higher probability (mutation selection)
            makespan_prob = exp((1/3)*makespan_mat/max_pop_fit);
        else
            % Lower makespan, higher probability (parent selection)
            makespan_prob = exp(-3*makespan_mat/max_pop_fit);
        end
        
end