%% rand_whole_mutate.m
% Randomly mutates the entire population
% This is a whole population adaption of shuffle_rndom_mach_chg.m
%
% For every row corresponding to a selected gene
% Selects k random distinct jobs, then assign those k jobs to k new
% machines (machines different from their current machine)

function [combined_pop_mat, combined_machine_cost_mat] = ...
    all_genes_rndom_shuffle(genes_to_mutate, combined_pop_mat, ...
            combined_machine_cost_mat, num_machines, ...
            num_jobs, jobs_array_aug, k)

    num_genes = length(genes_to_mutate);
    %Find the targeted genes
    targeted_genes = combined_pop_mat(genes_to_mutate,:);
    
    %Generate num_genes*k distinct
    [~, target_jobs] = sort(rand(num_jobs, num_genes));
    target_jobs = target_jobs(1:k,:)';
    
    current_machines = targeted_genes(target_jobs);
    %Generate num_genes*k new machines
    new_machines = randi(num_machines, num_genes, k);
    matches = new_machines == current_machines;
    num_matches = sum(sum(matches));
    while num_matches > 0
        new_machines(matches) = randi(num_machines,1,num_matches);
        matches = new_machines == current_machines;
        num_matches = sum(sum(matches));
    end
    
    %Reassign the targeted genes
    targeted_genes(target_jobs) = new_machines;
    
    combined_pop_mat(genes_to_mutate,:) = targeted_genes;
    
    combined_machine_cost_mat(genes_to_mutate,:) = ...
                    calc_machine_costs(jobs_array_aug, ...
                        combined_pop_mat(genes_to_mutate,:), num_machines);
end