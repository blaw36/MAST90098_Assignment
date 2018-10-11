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

function [combined_pop_mat, combined_machine_cost_mat, ...
    best_pre_mutate_candidate, best_post_mutate_candidate] = ...
    mutate_population(genes_to_mutate, combined_pop_mat, ...
    combined_machine_cost_mat, num_machines, ...
    num_jobs, jobs_array_aug, mutate_method, num_shuffles)

    % Hard to justify improvements on mutation, and all seem to
    % provide enough randomness. Main driver of performance is probably in
    % the crossover. This method was originally designed to increase
    % mutation amount on less fit individuals, but hard to see the
    % difference. Shuffle_mat is a matrix of probabilities, and these would
    % be multiplied by the 'num_shuffles' for each i in genes_to_mutate to
    % get a new mutation amount for each mutation candidate.
%     % Mutation length for each gene - lower makespan, lower number
%     shuffle_mat = fitness_minmaxLinear(...
%         max(combined_machine_cost_mat,[],2));

    best_pre_mutate_candidate = min(max(combined_machine_cost_mat(...
        genes_to_mutate,:),[],2));

    for i = genes_to_mutate
        if mutate_method == "mutate_greedy_refactor"
            [combined_pop_mat(i,:), combined_machine_cost_mat(i,:)] = ...
                mutate_greedy_refactor(combined_pop_mat(i,:), num_machines, ...
                num_jobs, num_shuffles, combined_machine_cost_mat(i,:), jobs_array_aug);
            continue
        end
        % Pick mutation method for each gene
        if mutate_method == "pair_swap"
            [combined_pop_mat(i,:), costs_shuffled, machines_shuffled] = ...
                shuffle_pair_swap(combined_pop_mat(i,:), num_machines, ...
                num_jobs, jobs_array_aug);
        elseif mutate_method == "rndom_mach_chg"
            [combined_pop_mat(i,:), costs_shuffled, machines_shuffled] = ...
                shuffle_rndom_mach_chg(combined_pop_mat(i,:), num_machines, ...
                num_jobs, num_shuffles, ...
                jobs_array_aug);
        elseif mutate_method == "rndom_mach_chg_load"
            [combined_pop_mat(i,:), costs_shuffled, machines_shuffled] = ...
                shuffle_rndom_mach_chg_load(combined_pop_mat(i,:), num_machines, ...
                num_jobs, num_shuffles, combined_machine_cost_mat(i,:), ...
                jobs_array_aug);
        elseif mutate_method == "geo_path_cycle"
            [combined_pop_mat(i,:), costs_shuffled, machines_shuffled] = ...
                geo_path_cycle_shuffle(combined_pop_mat(i,:), num_machines, ...
                num_jobs, num_shuffles, combined_machine_cost_mat(i,:), jobs_array_aug);
        elseif mutate_method == "mutate_greedy"
            [combined_pop_mat(i,:), costs_shuffled, machines_shuffled] = ...
                mutate_greedy(combined_pop_mat(i,:), num_machines, ...
                num_jobs, num_shuffles, combined_machine_cost_mat(i,:), jobs_array_aug);
        end
        
        % Update makespan incrementally
        changes = zeros(size(costs_shuffled,1),num_machines);
            for j = 1:size(machines_shuffled,1)
                changes(j,machines_shuffled(j,:)) = ...
                    [-costs_shuffled(j,:), costs_shuffled(j,:)];
            end
        changes = sum(changes, 1);
        combined_machine_cost_mat(i,:) = combined_machine_cost_mat(i,:) ...
                + changes;
    end

    best_post_mutate_candidate = min(max(combined_machine_cost_mat(...
        genes_to_mutate,:),[],2));
    
end