%% fitness_negexp.m
% method of calculating probability from Liu Min, Wu Cheng in the paper,
% "A genetic algorithm for minimizing the makespan in the case of 
% scheduling identical parallel machines.", see report for further details.
%% Inputs: 
    % makespan_mat: the makespan of each individual of the population
    % invert: if true high makespan gives higher prob, if false low
        % makespan gives lower prob
    % a: controls how the probabilities are scaled
%% Output: 
    % prob: the computed probability
%%

function prob = fitness_negexp(makespan_mat, invert, a)

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
        prob = rand(size(makespan_mat,1),1);
    else
        % Otherwise, continue with approach
        if invert
            % Higher makespan, higher probability (mutation selection)
            prob = exp((1/a)*makespan_mat/max_pop_fit);
        else
            % Lower makespan, higher probability (parent selection)
            prob = exp(-a*makespan_mat/max_pop_fit);
        end
    end
    
    %Normalise the values into a probability
    prob = prob/sum(prob);
end