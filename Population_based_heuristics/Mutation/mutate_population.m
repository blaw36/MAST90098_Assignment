%% mutate_population.m
% A function which is a wrapper for the mutation functions which apply to
% individual members of the population.
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
    % mutate_method:
        % a handle to a function 
                %   [indiv_array, machine_cost_mat] = mutate_method(...
                %        indiv_array, num_machines, num_jobs, ...
                %        machine_cost_mat, jobs_array_aug, k)
        % which performs the mutate operation on each individual member of
        % the population.
    % mutate_method_args: additional args for the function

%% Output:
    % pop_mat: a pop_init_size x num_jobs matrix encoding the
        % job locations of each individual
    % machine_cost_mat:a pop_init_size x num_machines matrix
        % encoding the machine costs of each individual
%%

function [pop_mat, machine_cost_mat] = mutate_population(...
                                        genes_to_mutate, pop_mat, ...
                                        machine_cost_mat, num_machines, ...
                                        num_jobs, job_costs,...
                                        mutate_method, mutate_method_args)

    for i = genes_to_mutate
        [pop_mat(i,:), machine_cost_mat(i,:)] = ...
                mutate_method(pop_mat(i,:), num_machines, ...
                              num_jobs, machine_cost_mat(i,:),...
                              job_costs, mutate_method_args{:});
    end
end