%% rand_whole_mutate.m
% Randomly mutates the entire population
% This is a whole population adaption of shuffle_rndom_mach_chg.m
%
% For every row corresponding to a selected gene
% Selects k random distinct jobs, then assign those k jobs to k new
% machines (machines different from their current machine)
%% Input:
    % genes_to_mutate: elements of [1,..., init_pop_size] indicating which
        % individuals to mutate
    % pop_mat: An init_pop_size x num_jobs matrix encoding the
        % job locations of each individual
    % machine_cost_mat: An init_pop_size x num_machines matrix encoding the
        % machine costs of each individual
    % num_jobs: the number of jobs
    % num_machines: the number of machines
    % job_costs: the cost of each job
    % k: number of jobs to assign to new machines
%% Output:
    % pop_mat: a pop_init_size x num_jobs matrix encoding the
        % job locations of each individual
    % machine_cost_mat:a pop_init_size x num_machines matrix
        % encoding the machine costs of each individual
%%

function [pop_mat, machine_cost_mat] = all_genes_rndom_shuffle(...
                                        genes_to_mutate, pop_mat, ...
                                        machine_cost_mat, num_machines, ...
                                        num_jobs, job_costs, k)

    num_genes = length(genes_to_mutate);
    %Find the targeted genes
    targeted_genes = pop_mat(genes_to_mutate,:);
    
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
    
    pop_mat(genes_to_mutate,:) = targeted_genes;
    
    machine_cost_mat(genes_to_mutate,:) = ...
                    calc_machine_costs(job_costs, ...
                            pop_mat(genes_to_mutate,:), num_machines);
end