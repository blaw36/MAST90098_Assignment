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
    %See genetic_alg_inner
%%

function [best_makespan, time_taken, init_makespan, best_output,...
    best_gen_num, generation_counter, diags_array] = ...
            genetic_alg_outer(input_array, init_pop_size, simple_prop, ... %inits
            init_mutate_method, init_mutate_num_shuffles, ... %inits
            parent_selection, parent_ratio, crossover_method, ... %crossover
            mutation_select_method, mutation_method, mutate_num_shuffles, ... %mutation
            popn_cull, cull_prop, ... %culling
            num_gen_no_improve, max_gens_allowed)


    init_method = @init_mix_shuff_rand;
    init_args = {init_pop_size, simple_prop, init_mutate_method, ...
                init_mutate_num_shuffles};
   
    %Use the fitness function to select the parents, with bias given to
    %fitter parents
    invert = false;
    parent_selection_args = {invert};
    
    if parent_selection == "minMaxLinear"
        parent_selection_method = @fitness_minmaxLinear;
    elseif parent_selection == "neg_exp"
        parent_selection_method = @fitness_negexp;
    else
        error("Invalid Fitness Selection Method");
    end
    
    %TODO: These need to all give consistent outputs perform can replace
    %here
    cross_over_method = @crossover_population;
    cross_over_args = {crossover_method};

    %Use the fitness function to select the parents, with bias given to
    %fitter parents
    invert = true;
    mutate_select_args = {invert};
    
    if mutation_select_method == "minMaxLinear"
        mutate_select_method = @fitness_minmaxLinear;
    elseif mutation_select_method == "neg_exp"
        mutate_select_method = @fitness_negexp;
    else
        error("Invalid Fitness Selection Method");
    end
    
    %TODO: Need refactor for this change as well
    mutate_method = @mutate_population;
    mutate_args = {mutation_method, mutate_num_shuffles};
    
    %Cull
    if popn_cull == "top"
        pop_cull_method = @cull_top_n;
        pop_cull_args = {};
    elseif popn_cull == "top_and_bottom"
        pop_cull_method = @cull_top_bottom_n;
        pop_cull_args = {cull_prop};
    elseif popn_cull == "top_and_randsamp"
        pop_cull_method = @cull_top_and_randsamp;
        pop_cull_args = {cull_prop};
    else
        error("Invalid Culling Method");
    end
    
    %Pass these all to the inner function
    [best_makespan, time_taken, init_makespan, best_output,...
    best_gen_num, generation_counter, diags_array] = ...
        genetic_alg_inner(input_array, ...
            init_method, init_args, ...%initiation
            parent_selection_method, parent_selection_args,... %parent sel
            cross_over_method, cross_over_args, ... %crossover
            mutate_select_method, mutate_select_args, ...
            mutate_method, mutate_args, ... %mutation
            pop_cull_method, pop_cull_args, ... %culling
            init_pop_size, parent_ratio, ...
            num_gen_no_improve, max_gens_allowed);%other args
end