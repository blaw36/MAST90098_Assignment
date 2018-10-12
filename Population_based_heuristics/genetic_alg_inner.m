%% genetic_alg_inner.m
% uses a genetic algorithm population heuristic method for solving the
% makespan problem

%% Methods:
% ~~Fitness calculation: (used to select crossover parents, mutation
% candidates)
    % "minMaxLinear": scale makespans to 1 (min makespan) or 0 
        % (max makespan), and scale to a probability distribution over all 
        % candidate individuals.
    % "neg_exp": exp(-b * makespan)
% ~~Mutation operations: operation which mutates based on an input fitness 
% array of all the individuals
    % "pair_swap": swap machines allocated to two randomly selected jobs. 
        % Jobs must be from different machines.
    % "rndom_mach_chg": take k different jobs, reassign them to new
        % machines.
    % "rndom_mach_chg_load": like "rndom_mach_chg" but preferencing taking
        % elements from loaded machines, and then preferencing putting them
        % into less loaded machines.
% ~~Crossover operations: to determine how the genes from two parents are
% carried over/split into the children
    % "cutover_split" = simple cutover of two parents at one point (ie. all
        % jobs up until that point from one parent, all jobs beyond from
        % the other). Number of jobs from each parent is weighted by
        % makespan (lower makespan, more elements get cutover).
    % "rndm_split" = cutover of two parents at many randomly selected
        % points, but still such that the 'stronger' parent still only gets 
        % up to their alloted number of job assignments to pass on to their
        % children.
% ~~Population culling operations: determines how to scale down the 
% population to carry on to the next generation
    % "top": carries the top n (by makespan) individuals over to the next
        % generation
    % "top_and_bottom": fills x% of the required number by the top (by 
        % makespan) individuals over, with the remaining (1-x)% required
        % made up by the bottom/worst individuals.
    % "top_and_randsamp": fills x% of the required number by the top n, the
        % rest are filled by random sample

%% Inputs:
% ~~Initialisation:
	% input_array: Array of jobs, number of machines
	% init_pop_size: size of population to initialise
	% simple_prop: proportion of init_pop_size to be from the simple 
        % initialisation algorithm. (1-simple_prop) will be from a random 
        % initialisation
    % init_mutate_method: mutation operation used to add randomness to the
        % simple generated initialised instances
    % init_mutate_num_shuffles: number of elements to grab and reassign
        % machines to (at initiation) - unused by 'pair_swap' mutation
% ~~Parent selection and crossover:        
	% parent_selection: fitness operation to generate probabilities of 
        % parent selection
	% parent_ratio: ratio of parents to init_pop_size for crossover. 
        % Eg: 2 means we pair up 2x init_pop_size parents together, 
        % resulting in init_pop_size number of children being created from 
        % crossover.
	% crossover_method: Crossover operation to create children.
% ~~Mutation:
	% mutation_select_method: fitness operation used to generate
        % probabilities of mutating any given individual
	% mutate_method: mutation operation performed on selected individuals
    % mutate_num_shuffles: number of elements to grab and reassign
        % machines to (at initiation) - unused by 'pair_swap' mutation 
% ~~Population culling:        
	% popn_cull: The population culling operation to reduce population back
        % to init_pop_size for next generation
    % cull_prop: the relevant culling proportion parameter (of
        % init_pop_size) that's used by most of our culling operations
% ~~Termination conditions:
	% num_gen_no_improve: max # of generations without improvement
    % max_gens_allowed: max # of generations allowed
%% Outputs
    % best_makespan:
        % max, across all machines, of sum of jobs for a given machines
    % time_taken:
        % the time taken for the algorithm to run to completion
    % init_makespan:
        % the makespan after initiation
    % best_output: best output of machine allocations to a sorted input job
        % vector
    % best_gen_num: generation which yielded the best output
    % generation_counter: how many generations used in the process before
        % it terminated
    % diags_array: array of information which tracks the following metrics
        % throughout the process:
            % Generation number
            % Best makespan in that generation
            % Best makespan overall
            % Average fitness of that generation
            % Minimum fitness of that generation
            % Maximum fitness of that generation
            % Number of parents which survived in that generation
            % Number of children which survived in that generation

function [best_makespan, time_taken, init_makespan, best_output,...
    best_gen_num, generation_counter, diags_array] = ...
        genetic_alg_inner(input_array, ...
            init_method, init_args, ...%initiation
            parent_selection_method, parent_selection_args,... %parent sel
            cross_over_method, cross_over_args, ... %crossover
            mutate_select_method, mutate_select_args, ...
            mutate_method, mutate_args, ... %mutation
            pop_cull_method, pop_cull_args, ... %culling
            init_pop_size, parent_ratio, ...
            num_gen_no_improve, max_gens_allowed) %other args

    start_time = tic;

    % wlog, shuffle input_array such that jobs arranged largest to smallest
    % (aligns with our simple initialisation also)
    input_array_aug = [sort(input_array(:,1:(end-1)), 'descend'), ...
        input_array(end)];

    % Generate initial population
    % Each row corresponds to an individual, each column corresponds to the machine
    % allocated to that job (job order same as in input_array_aug, for all
    % individuals)
    [pop_mat, num_jobs, num_machines, jobs_array_aug] = ...
                                init_method(input_array_aug, init_args{:});

    % Calculate cost per machine for each individual, as well as makespan
    machine_cost_mat = calc_machine_costs(jobs_array_aug, pop_mat, ...
        num_machines);
    makespan_mat = max(machine_cost_mat,[],2);

    % Begin iterations
    best_makespan = inf;
    start_gen_makespan = inf;
    [new_gen_makespan,indiv_indx] = min(makespan_mat);
    
    % Record makespan after Initialisation
    init_makespan = new_gen_makespan;

    % Initialise generation counter
    generation_counter = 0;
    no_chg_generations = 0;

    % Initialise best generation heuristics
    best_generation = {};
    best_generation = {generation_counter, pop_mat(indiv_indx,:), new_gen_makespan};

    % Initialise diagnostics array
    % Add to diagnostics table
        % Columns: Generation#, Best makespan in gen, Best makespan,
        % AvgFit, MinFit, MaxFit NumParentsSurvive, NumChildrenSurvive
    gen_result = [generation_counter, new_gen_makespan, new_gen_makespan, ...
                    round(mean(makespan_mat)), ...
                    round(min(makespan_mat)), round(max(makespan_mat)), ...
                    init_pop_size, 0];
    diags_array = [gen_result];
        
    
    % Termination criteria: # generations with no improvement, max number
    % of generations
    while no_chg_generations <= num_gen_no_improve && ...
            generation_counter <= max_gens_allowed

        start_gen_makespan = best_generation{3};
        
        %Select the parents
        prob_parent_select = parent_selection_method(makespan_mat, ...
                                                parent_selection_args{:});

        % Generate parent pairings for crossover
        parent_mat = generate_parents(prob_parent_select, ...
                                        parent_ratio, init_pop_size);
        num_children = size(parent_mat,1);
        best_parent = min(max(machine_cost_mat(parent_mat,:),[],2));

        % Crossover
        [crossover_children, machine_cost_mat_children,...
                            best_child, c_over_time] = ...
                cross_over_method(num_children, num_machines,...
                                    num_jobs, parent_mat, pop_mat,...
                                    machine_cost_mat, makespan_mat, ...
                                    jobs_array_aug, cross_over_args{:});

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
        tic;
        [combined_pop_mat, combined_machine_cost_mat, ...
            best_pre_mutate, best_post_mutate] = ...
                mutate_method(indivs_to_mutate, combined_pop_mat, ...
                combined_machine_cost_mat, num_machines, num_jobs, ...
                jobs_array_aug, mutate_args{:});
        mutation_time = toc;
        
        combined_makespan_mat = max(combined_machine_cost_mat,[],2);
        
        %Cull the Population
        survivors = pop_cull_method(combined_pop_mat,...
                                    combined_makespan_mat, ...
                                    init_pop_size, pop_cull_args{:});
        

        pop_mat = combined_pop_mat(survivors, :);
        %machine_cost_mat = combined_machine_cost_mat(indivs_to_keep, :);
        machine_cost_mat = calc_machine_costs(jobs_array_aug, pop_mat, ...
                                                num_machines);
        makespan_mat = combined_makespan_mat(survivors, :);
        parent_child_indicator = parent_child_indicator(survivors, :);
        [new_gen_makespan,indiv_indx] = min(makespan_mat);

        generation_counter = generation_counter + 1;

        if (new_gen_makespan - best_generation{3}) >= 0
            no_chg_generations = no_chg_generations + 1;
        elseif (new_gen_makespan - best_generation{3}) < 0
            no_chg_generations = 0;
            best_generation = {generation_counter, pop_mat(indiv_indx,:), new_gen_makespan};
        end
        
        % Record new best if encountered
        if best_generation{3} < best_makespan
            best_makespan = best_generation{3};
            best_sol = best_generation{2};
            best_gen_num = best_generation{1};
        end
        
        clc
        fprintf("Generation: %d \n", generation_counter);
        fprintf("Best makespan in generation: %d \n", new_gen_makespan);
%         fprintf("Best generation makespan: %d \n", best_generation{3});
        fprintf("Best makespan: %d \n", best_makespan);
        fprintf("Avg fitness: %d \n", round(mean(makespan_mat)));
        fprintf("Min fitness: %d \n", round(min(makespan_mat)));
        fprintf("Max fitness: %d \n", round(max(makespan_mat)));
        fprintf("Num gens no improvement: %d \n", no_chg_generations);
        fprintf("Num parents survived: %d \n", ...
            sum(parent_child_indicator == 1));
        fprintf("Num children survived: %d \n", ...
            sum(parent_child_indicator == 0));
        fprintf("Crossover time: %2.6f\n", c_over_time);
        fprintf("Mutation time: %2.6f\n", mutation_time);
        fprintf("Best parent: %d\n", best_parent);
        fprintf("Best child: %d\n", best_child);
        fprintf("Best pre-mutate cand: %d\n", best_pre_mutate);
        fprintf("Best post-mutate cand: %d\n", best_post_mutate);
        
        % Add to diagnostics table
        % Columns: Generation#, Best makespan in gen, Best makespan,
        % AvgFit, MinFit, MaxFit NumParentsSurvive, NumChildrenSurvive
        gen_result = [generation_counter, new_gen_makespan, best_makespan, ...
            round(mean(makespan_mat)), ...
            round(min(makespan_mat)), ...
            round(max(makespan_mat)), ...
            sum(parent_child_indicator == 1), ...
            sum(parent_child_indicator == 0)];
        diags_array = [diags_array; gen_result];

    end

    % Convert best_output to standard output_array format produced by other
    % two algorithms
    best_output = [jobs_array_aug', best_sol'];
    best_output = sortrows(best_output,2);
    best_output(:,3) = zeros(num_jobs,1); % third column is just arbitrary as a
    % placeholder
    
    time_taken = toc(start_time);
end