%& genetic_alg_worker.m
% Runs an iteration of the genetic algorithm, within the while loop
% (termination condition). All inputs are described in
% 'genetic_alg_inner.m'

%% Inputs:
    % best_generation: cell which contains information regarding the best
        % outputs the algorithm has developed so far:
        % # of the generation it was created
        % The output array of the best assignment
        % The makespan of the best assignment
    % pop_mat: input version of matrix mentioned in 'outputs'
    % makespan_mat: input version of matrix mentioned in 'outputs'
    % machine_cost_mat: input version of matrix mentioned in 'outputs'
    % job_costs: cost of each job in instance, sorted in descending order.
        % This allows each individual to have, in their jth column, the
        % assigned machine referring to the same job across the population
    % num_machines: number of machines in instance
    % num_jobs: number of jobs in instance
    
% For the following inputs, refer to 'genetic_alg_inner.m' inputs
    % parent_selection_method, parent_selection_args
    % cross_over_method, cross_over_args
    % mutate_select_method, mutate_select_args
    % mutate_method, mutate_args
    % pop_cull_method, pop_cull_args
    % init_pop_size, parent_ratio

%% Outputs
    % pop_mat: Population matrix - rows are individuals, and columns are
        % the machine numbers the job in the jth column has been assigned
        % to (this refers to the sorted 'job_costs' array)
    % machine_cost_mat: Machine cost matrix - rows are individuals and
        % column j is the total costs of the jth machine for that
        % individual
    % makespan_mat: Makespan matrix - a column vector listing the makespan
        % of each individual (ith row, ith individual)
    % parent_child_indicator: Array of 1s and 0s indicating which
        % individual is a parent, and which is a child from the previous
        % generation
    % c_over_time: Time taken to perform crossover step
    % mutation_time: Time taken to perform mutation step
    % best_parent: Best parent makespan before crossover
    % best_child: Best child makespan after creation through crossover
    % best_pre_mutate: Best mutation candidate makespan before mutation
    % best_post_mutate: Best mutation candidate makespan after mutation

function [pop_mat, machine_cost_mat, makespan_mat, parent_child_indicator, ...
    c_over_time, mutation_time, best_parent, best_child, ...
    best_pre_mutate, best_post_mutate] = ...
    genetic_alg_worker(best_generation, pop_mat, makespan_mat, ...
    machine_cost_mat, job_costs, num_machines, num_jobs, ...
    parent_selection_method, parent_selection_args,... %parent sel
    cross_over_method, cross_over_args, ... %crossover
    mutate_select_method, mutate_select_args, ...
    mutate_method, mutate_args, ... %mutation
    pop_cull_method, pop_cull_args, ... %culling
    init_pop_size, parent_ratio)

    % Compute the probability of selecting the parents
    prob_parent_select = parent_selection_method(makespan_mat, ...
        parent_selection_args{:});

    % Generate parent pairings for crossover
    parent_mat = generate_parents(prob_parent_select, ...
        parent_ratio, init_pop_size);
    num_children = size(parent_mat,1);
    
    % Best parent before crossover
    best_parent = min(max(machine_cost_mat(parent_mat,:),[],2));
    % Crossover operation
    tic;
    [crossover_children, machine_cost_mat_children] = ...
        cross_over_method(num_children, num_machines,...
        num_jobs, parent_mat, pop_mat,...
        machine_cost_mat, makespan_mat, ...
        job_costs, cross_over_args{:});
    c_over_time = toc;
    % Best child produced from crossover
    best_child = min(max(machine_cost_mat_children,[],2));

    % Combine children and parents for larger population
    combined_pop_mat = [pop_mat; crossover_children];
    combined_machine_cost_mat = [machine_cost_mat; machine_cost_mat_children];

    % Record which observations are children (0) and parents (1)
    parent_child_indicator = [ones(size(pop_mat,1),1); ...
        zeros(size(crossover_children,1),1)];

    combined_makespan_mat = max(combined_machine_cost_mat,[],2);

    % Select the elements for mutation
    prob_mutation_select = mutate_select_method(combined_makespan_mat, ...
        mutate_select_args{:});

    random_numbers = rand(size(combined_makespan_mat,1),1);
    indivs_to_mutate = find(random_numbers <= prob_mutation_select)';

    % Log best mutation candidate, before mutation
    best_pre_mutate = min(max(combined_machine_cost_mat(...
        indivs_to_mutate,:),[],2));

    tic;
    % Mutate
    [combined_pop_mat, combined_machine_cost_mat] = ...
        mutate_method(indivs_to_mutate, combined_pop_mat, ...
        combined_machine_cost_mat, num_machines, num_jobs, ...
        job_costs, mutate_args{:});
    mutation_time = toc;
    
    % Log best mutation candidate, after mutation
    best_post_mutate = min(max(combined_machine_cost_mat(...
        indivs_to_mutate,:),[],2));

    combined_makespan_mat = max(combined_machine_cost_mat,[],2);

    % Population Culling
    survivors = pop_cull_method(combined_pop_mat,...
                                combined_makespan_mat, ...
                                init_pop_size, pop_cull_args{:});

    % Consolidate the culled into final population for next generation
    pop_mat = combined_pop_mat(survivors, :);
    machine_cost_mat = combined_machine_cost_mat(survivors, :);
    makespan_mat = combined_makespan_mat(survivors, :);
    
    % Log parents and children which survived onto the next generation
    parent_child_indicator = parent_child_indicator(survivors, :);

end