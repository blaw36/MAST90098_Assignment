%% mutate_population.m
% A function which is a wrapper for mutating population:

% Needs a mutation function (eg: pair_swap, rndom_mach_chg), which admits a
% population matrix, and outputs:
    % altered population matrix
    % machines_shuffled: k x 2 array which outputs the k movements, 1st 
        % column being the from machine, 2nd column being the to machine
    % costs_shuffled: k x 1 array which details the costs of the jobs being
        % moved between jobs in row k of the corresponding machines_shuffled
        % array

function [combined_pop_mat, combined_machine_cost_mat] = ...
    mutate_population(genes_to_mutate, combined_pop_mat, ...
            combined_machine_cost_mat, num_machines, ...
            num_jobs, jobs_array_aug, mutate_method, mutate_method_args)

    for i = genes_to_mutate
        [combined_pop_mat(i,:), combined_machine_cost_mat(i,:)] = ...
                mutate_method(combined_pop_mat(i,:), num_machines, ...
                              num_jobs, combined_machine_cost_mat(i,:),...
                              jobs_array_aug, mutate_method_args{:});
    end
end