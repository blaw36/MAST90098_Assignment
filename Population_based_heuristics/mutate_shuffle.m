%% mutate_shuffle.m
% Simple random 1-pair shuffle for mutation

function [combined_pop_mat, combined_machine_cost_mat] = ...
    mutate_shuffle(genes_to_mutate, combined_pop_mat, ...
    combined_machine_cost_mat, num_machines, ...
    num_jobs, jobs_array_aug, mutate_method, num_shuffles)

    if mutate_method == "pair_swap"
        % Pair swap method
        for i = genes_to_mutate
            [combined_pop_mat(i,:), costs_shuffled, machines_shuffled] = ...
                shuffle_pair_swap(combined_pop_mat(i,:), num_machines, ...
                num_jobs, jobs_array_aug);
            changes = zeros(1,num_machines);
            machine_change = diff(costs_shuffled);
            changes(machines_shuffled) = [machine_change, -machine_change];
            combined_machine_cost_mat(i,:) = combined_machine_cost_mat(i,:) ...
                + changes;
        end
    elseif mutate_method == "rndom_mach_chg"
        % Random machine change
        for i = genes_to_mutate
            [combined_pop_mat(i,:), costs_shuffled, machines_shuffled] = ...
                shuffle_rndom_mach_chg(combined_pop_mat(i,:), num_machines, ...
                num_jobs, num_shuffles, jobs_array_aug);
            % Can we do this calculation all at once on the array, rather
            % than looping through the rows and reinitialising stuff?
            changes = zeros(1,num_machines);
            for j = 1:size(costs_shuffled,1)
                changes(machines_shuffled(j,:)) = ...
                    changes(machines_shuffled(j,:)) + ...
                    [-costs_shuffled(j,:), costs_shuffled(j,:)];
            end
            combined_machine_cost_mat(i,:) = combined_machine_cost_mat(i,:) ...
                    + changes;
        end
    end
end