%% mutate_shuffle.m
% Simple random 1-pair shuffle for mutation

function [combined_pop_mat, combined_machine_cost_mat] = ...
    mutate_shuffle(genes_to_mutate, combined_pop_mat, ...
    combined_machine_cost_mat, num_machines, ...
    num_jobs, jobs_array_aug)

    % Random shuffle method
    for i = genes_to_mutate
        [combined_pop_mat(i,:), costs_shuffled, machines_shuffled] = ...
            shuffle_elmts_pairs(combined_pop_mat(i,:), num_machines, ...
            num_jobs, jobs_array_aug);
        changes = zeros(1,num_machines);
        machine_change = diff(costs_shuffled);
        changes(machines_shuffled) = [machine_change, -machine_change];
        combined_machine_cost_mat(i,:) = combined_machine_cost_mat(i,:) ...
            + changes;
    end
end