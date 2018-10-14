% genetic_alg_iteration.m
% Runs an iteration of the genetic algorithm, within the while loop
% (termination condition). All inputs are described in
% 'genetic_alg_inner.m'

function [pop_mat, machine_cost_mat, makespan_mat, parent_child_indicator, ...
    c_over_time, mutation_time, best_parent, best_child, ...
    best_pre_mutate, best_post_mutate] = ...
    genetic_alg_iteration(best_generation, pop_mat, makespan_mat, ...
    machine_cost_mat, jobs_array_aug, num_machines, num_jobs, ...
    parent_selection_method, parent_selection_args,... %parent sel
    cross_over_method, cross_over_args, ... %crossover
    mutate_select_method, mutate_select_args, ...
    mutate_method, mutate_args, ... %mutation
    pop_cull_method, pop_cull_args, ... %culling
    init_pop_size, parent_ratio)

    %%% START HERE
    start_gen_makespan = best_generation{3};

    %Compute the probability of selecting the parents
    prob_parent_select = parent_selection_method(makespan_mat, ...
        parent_selection_args{:});

    % Generate parent pairings for crossover
    parent_mat = generate_parents(prob_parent_select, ...
        parent_ratio, init_pop_size);
    num_children = size(parent_mat,1);
    best_parent = min(max(machine_cost_mat(parent_mat,:),[],2));

    % Crossover
    tic;
    [crossover_children, machine_cost_mat_children] = ...
        cross_over_method(num_children, num_machines,...
        num_jobs, parent_mat, pop_mat,...
        machine_cost_mat, makespan_mat, ...
        jobs_array_aug, cross_over_args{:});
    c_over_time = toc;
    best_child = min(max(machine_cost_mat_children,[],2));

    % Combine children and parents for larger population
    combined_pop_mat = [pop_mat; crossover_children];

    combined_machine_cost_mat = [machine_cost_mat; machine_cost_mat_children];

    % 1 for parent, 0 for children
    parent_child_indicator = [ones(size(pop_mat,1),1); ...
        zeros(size(crossover_children,1),1)];

    combined_makespan_mat = max(combined_machine_cost_mat,[],2);

    %Select the elements for mutation
    prob_mutation_select = mutate_select_method(combined_makespan_mat, ...
        mutate_select_args{:});

    % TODO: Should probably be inside function
    % Convert to between 0 and 1
    % The problem here is the min gets allocated 0, and the max gets
    % allocated 1
    min_prob = min(prob_mutation_select);
    max_prob = max(prob_mutation_select);
    prob_mutation_select = ...
        (prob_mutation_select - min_prob)./...
        (max_prob - min_prob );

    random_numbers = rand(size(combined_makespan_mat,1),1);
    indivs_to_mutate = find(random_numbers <= prob_mutation_select)';

    % Mutate
    best_pre_mutate = min(max(combined_machine_cost_mat(...
        indivs_to_mutate,:),[],2));

    tic;
    [combined_pop_mat, combined_machine_cost_mat] = ...
        mutate_method(indivs_to_mutate, combined_pop_mat, ...
        combined_machine_cost_mat, num_machines, num_jobs, ...
        jobs_array_aug, mutate_args{:});

    mutation_time = toc;
    best_post_mutate = min(max(combined_machine_cost_mat(...
        indivs_to_mutate,:),[],2));

    combined_makespan_mat = max(combined_machine_cost_mat,[],2);

    %Cull the Population
    % TODO: Dynamic Culling, more or less pop over run time?
    survivors = pop_cull_method(combined_pop_mat,...
                                combined_makespan_mat, ...
                                init_pop_size, pop_cull_args{:});

    pop_mat = combined_pop_mat(survivors, :);
    machine_cost_mat = combined_machine_cost_mat(survivors, :);

    makespan_mat = combined_makespan_mat(survivors, :);
    parent_child_indicator = parent_child_indicator(survivors, :);
    %%% STOP HERE

end