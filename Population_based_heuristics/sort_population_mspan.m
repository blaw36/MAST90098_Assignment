%% sort_population_mspan.m

% re-maps each individuals' machine numbers so that 1 is the machine with
% the lowest total cost, and m is the machine with the highest total cost.
% This provides a more consistent ordering for more meaningful crossovers.

%% Warning, may be time consuming!
%% An alternative is to 'smartly' match up parents, based on their 
    % 'similarity' through indices or something of the sort.

function [sorted_pop_mat, sorted_machine_cost_mat] = ...
    sort_population_mspan(pop_mat, machine_cost_mat, ...
    num_machines, num_jobs, init_pop_size)

    new_order = 1:num_machines;
    sorted_pop_mat = zeros(init_pop_size,num_jobs);
    sorted_machine_cost_mat = zeros(init_pop_size,num_machines);
    
    for i = 1:init_pop_size
        % sort
        [sorted_machine_cost_mat(i,:),indx] = sort(machine_cost_mat(i,:));
        % the mind-boggling magic happens here
        % https://stackoverflow.com/questions/13812656/elegant-vectorized-version-of-changem-substitute-values-matlab
        [a,b] = ismember(pop_mat(i,:),indx);
        tmp(a) = new_order(b(a));
        sorted_pop_mat(i,:) = tmp;
    end
    
end