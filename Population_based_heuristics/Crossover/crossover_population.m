%% crossover_population.m
% A function which is a wrapper for the crossover functions which apply to
% individual members of the population.
%% Input:
    % num_children: the number of children
    % num_jobs: the number of jobs
    % num_machines: the number of machines
    % parent_mat: A number_children x 2 matrix encoding the individuals of
        % population paired as parents
    % pop_mat: An init_pop_size x num_jobs matrix encoding the
        % job locations of each individual
    % machine_cost_mat: An init_pop_size x num_machines matrix encoding the
        % machine costs of each individual   
    % makespan_vec: An init_pop_size vector encoding the makespan of each
        % member of the population.
    % job_costs: the cost of each job
    % cross_over_method:
        % a handle to a function 
        %[crossover_children, machine_cost_mat_children] = ...
        %	[child_array, child_machine_cost] = cross_over_method(...
        %           parent_genes, parent_fitness, ...
        %           parent_machine_cost, job_costs,...
        %           num_jobs, num_machines, cross_over_method_arg{:})
        % which performs the crossover operation on an individual member of
        % the population
    % cross_over_method_args: additional args for the function

%% Output:
    % crossover_children: a num_children x num_jobs matrix encoding the
        % job locations of each child
    % machine_cost_mat_children: a num_children x num_machines matrix
        % encoding the machine costs of each individual
%%

function [crossover_children, machine_cost_mat_children] = ...
    crossover_population(num_children, num_machines, num_jobs, ...
                            parent_mat, pop_mat, machine_cost_mat,...
                            makespan_mat, job_costs, ...
                            cross_over_method, cross_over_method_args)

    crossover_children = zeros(num_children, num_jobs);
    machine_cost_mat_children = zeros(num_children, num_machines);
    for i = 1:num_children 
        % Extract each parent pair and pass them and their genes to the
        % cross_over_method
        
        parent_pair = parent_mat(i,:);
        parent_indiv = pop_mat(parent_pair,:);
        parent_fitness = makespan_mat(parent_pair,:);
        parent_machine_cost = machine_cost_mat(parent_pair,:);
        
        [crossover_children(i,:), machine_cost_mat_children(i,:)] = ...
                cross_over_method(parent_indiv, parent_fitness, ...
                        parent_machine_cost, job_costs,...
                        num_jobs, num_machines, cross_over_method_args{:});
    end
end