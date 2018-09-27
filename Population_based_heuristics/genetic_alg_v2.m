%% genetic_algorithm.m
% uses a genetic algorithm population heuristic method for solving the
% makespan problem

%% Inputs:
	% input_array: Array of jobs, number of machines
	% init_pop_size: size of population to initialise
	% simple_prop: proportion of init_pop_size to be from the simple initialisation algorithm. (1-simple_prop) will be from a random initialisation
	% parent_selection: function used to convert fitness function into parent_select probabilities.
		% "minMaxLinear" = scale makespans to 1 (min makespan) or 0 (max makespan), and scale to a probability distribution over all candidate genes.
	% parent_ratio: ratio of parents to init_pop_size for crossover. Eg: 2 means we pair up 2x init_pop_size parents together, resulting in init_pop_size number of children being created from crossover.
	% crossover_method: Method for crossover and children creation.
		% "cutover_split" = simple cutover of two parents at one point in the gene, weighted by makespan (lower makespan, more elements get cutover)
	% mutation_select_method: function used to convert fitness function into a probability of selecting that gene for mutation
		% "minMaxLinear" = maps each genes' makespan to a probability between 0 (max makespan) and 1 (min makespan)
	% mutate_method: method used to mutate the genes selected for mutation
		% "shuffle": swap machines allocated to two randomly selected jobs. Jobs must be from different machines.
	% popn_cull: Method for culling enlarged population (parents and children, post-mutation) back to init_pop_size for next generation
		% "top": Takes top init_pop_size, ranked by makespan
	% termination_criteria: # of generations without improvement as termination condition.
%% Outputs
    % makespan:
        % max, across all machines, of sum of jobs for a given machines
    % time_taken:
        % the time taken for the algorithm to run to completion
    % init_makespan:
        % the makespan after initiation
    % best_output: best output of machine allocations to a sorted input job
    % vector
    % best_generation: generation which yielded the best output
    % generation_counter: how many generations used in the process before
    % it terminated
% To do: include different /flexible criteria for termination

function [best_makespan, time_taken, init_makespan, best_output,...
    best_generation, generation_counter] = ...
            genetic_alg_v2(input_array, init_pop_size, simple_prop, ...
                    parent_selection, parent_ratio, crossover_method, ...
                    mutation_select_method, mutate_method, ...
                    popn_cull, ...
                    termination_criteria)

    start_time = tic;

    % wlog, shuffle input_array such that jobs arranged largest to smallest
    % (aligns with our simple initialisation also)
    input_array_aug = zeros(size(input_array));
    input_array_aug = [sort(input_array(:,1:(end-1)), 'descend'), ...
        input_array(end)];

    % Generate initial population
    % Each row corresponds to a gene, each column corresponds to the machine
    % allocated to that job (job order same as in input_array_aug, for all
    % genes)
    [pop_mat, num_jobs, num_machines, jobs_array_aug] = init_mix_shuff_rand(...
        input_array_aug, init_pop_size, simple_prop);

    % Calculate cost per machine for each gene, as well as makespan
    machine_cost_mat = calc_machine_costs(jobs_array_aug, pop_mat, ...
        num_machines);
    makespan_mat = max(machine_cost_mat,[],2);

    % Begin iterations
    start_gen_makespan = inf;
    [new_gen_makespan,gene_indx] = min(makespan_mat);
    
    %Record makespan after Initialisation
    init_makespan = new_gen_makespan;

    % Initialise generation counter
    generation_counter = 1;
    no_chg_generations = 0;

    % Initialise best generation heuristics
    best_generation = {};
    best_generation = {generation_counter, pop_mat(gene_indx,:), new_gen_makespan};

% really arbitrary criteria demanding improvement every n generations
    while no_chg_generations <= termination_criteria

        start_gen_makespan = new_gen_makespan;

        if parent_selection == "minMaxLinear"
            prob_parent_select = fit_to_prob_minmaxLinear(makespan_mat, true);
        end

        cumul_prob_parent = cumsum(prob_parent_select);

        % Generate parent pairings for crossover
        parent_mat = generate_parents(cumul_prob_parent, ...
            parent_ratio, init_pop_size);
        num_children = size(parent_mat,1);

        % Crossover
        crossover_children = zeros(num_children, num_jobs);
        for i = 1:num_children 
            % Can we do this in batch?
            parent_pair = parent_mat(i,:);
            parent_genes = pop_mat(parent_pair,:);
            parent_fitness = makespan_mat(parent_pair,:);

            if crossover_method == "cutover_split"
                crossover_children(i,:) = ...
                c_over_split(parent_pair, parent_genes, parent_fitness, ...
                    num_jobs);
            end
        end

        % Calculate cost per machine of children
        machine_cost_mat_children = calc_machine_costs(jobs_array_aug, ...
            crossover_children, num_machines);

        % Combine children and parents for larger population
        combined_pop_mat = zeros(init_pop_size + num_children, num_jobs);
        combined_pop_mat = [pop_mat; crossover_children];

        combined_machine_cost_mat = zeros(init_pop_size + num_children, 1);
        combined_machine_cost_mat = [machine_cost_mat; machine_cost_mat_children];
        
        % 1 for parent, 0 for children
        parent_child_indicator = [ones(size(pop_mat,1),1); ...
            zeros(size(crossover_children,1),1)];

        combined_makespan_mat = max(combined_machine_cost_mat,[],2);

        % Randomly select elements for mutation
        if mutation_select_method == "minMaxLinear"
            prob_mutation_select = fit_to_prob_minmaxLinear(combined_makespan_mat);
        end
        random_numbers = rand(size(combined_makespan_mat,1),1);
        genes_to_mutate = find(random_numbers <= prob_mutation_select)';

        % Mutate
        if mutate_method == "shuffle"
            [combined_pop_mat, combined_machine_cost_mat] = ...
                mutate_shuffle(genes_to_mutate, combined_pop_mat, ...
                combined_machine_cost_mat, num_machines, num_jobs, ...
                jobs_array_aug);
        end

        combined_makespan_mat = max(combined_machine_cost_mat,[],2);

        % Population culling
        if popn_cull == "top"
            genes_to_keep = cull_top_n(combined_pop_mat, combined_makespan_mat, ...
                init_pop_size);
        end

        pop_mat = combined_pop_mat(genes_to_keep, :);
        makespan_mat = combined_makespan_mat(genes_to_keep, :);
        parent_child_indicator = parent_child_indicator(genes_to_keep, :);
        [new_gen_makespan,gene_indx] = min(makespan_mat);

        generation_counter = generation_counter + 1;

        % If we get > 10 generations with no change, stop.
        if (new_gen_makespan - start_gen_makespan) >= 0
            no_chg_generations = no_chg_generations + 1;
        elseif (new_gen_makespan - start_gen_makespan) < 0
            no_chg_generations = 0;
            best_generation = {generation_counter, pop_mat(gene_indx,:), new_gen_makespan};
        end

        clc
        fprintf("Generation: %d \n", generation_counter);
        fprintf("Makespan: %d \n", new_gen_makespan);
        fprintf("Best makespan: %d \n", best_generation{3});
        fprintf("Avg fitness: %d \n", round(mean(makespan_mat)));
        fprintf("Num parents survived: %d \n", ...
            sum(parent_child_indicator == 1));
        fprintf("Num children survived: %d \n", ...
            sum(parent_child_indicator == 0));

    end

    % Convert best_output to standard output_array format produced by other
    % two algorithms
    best_output = [jobs_array_aug', best_generation{2}'];
    best_output = sortrows(best_output,2);
    best_output(:,3) = zeros(num_jobs,1); % third column is just arbitrary as a
    % placeholder
    
    best_makespan = best_generation{3};
    best_generation = best_generation{1};
    time_taken = toc(start_time);
end