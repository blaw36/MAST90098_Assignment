%% genetic_alg_outer.m
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
            parent_selection, parent_ratio, cross_over_method, less_fit_c_over_machs, ... %crossover
            mutation_select_method, mutation_method, mutate_num_shuffles, ... %mutation
            popn_cull, cull_prop, ... %culling
            num_gen_no_improve, max_gens_allowed, ... %termination
            diagnose, ... %verbose/diagnose
            parallel)
    
    %Move outside
%     diagnose = true;
   
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
    
    %Cross_over function
    cross_over_inner_args = {};
    if cross_over_method ~= "c_over_2_all"
        if cross_over_method == "cutover_split"
            cross_over_inner_method = @c_over_split;
            cross_over_inner_args = {};
        elseif cross_over_method == "rndm_split"
            cross_over_inner_method = @c_over_rndm_split;
            cross_over_inner_args = {};
        elseif cross_over_method == "c_over_1"
            cross_over_inner_method = @c_over_1;
            cross_over_inner_args = {};
        elseif cross_over_method == "c_over_2"
            cross_over_inner_method = @c_over_2;
            cross_over_inner_args = {};
        elseif cross_over_method == "c_over_2_simplified"
            cross_over_inner_method = @c_over_2_simplified;
            cross_over_inner_args = {less_fit_c_over_machs};
        else
            error("Invalid Crossover Method");
        end
        cross_over_method = @crossover_population;
        cross_over_args = {cross_over_inner_method, cross_over_inner_args};
    else
        cross_over_method = @c_over_2_all;
        cross_over_args = {};
    end

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
    
    % Mutate
        
    % Hard to justify improvements on mutation, and all seem to
    % provide enough randomness. Main driver of performance is probably in
    % the crossover. This method was originally designed to increase
    % mutation amount on less fit individuals, but hard to see the
    % difference. Shuffle_mat is a matrix of probabilities, and these would
    % be multiplied by the 'num_shuffles' for each i in genes_to_mutate to
    % get a new mutation amount for each mutation candidate.
    %     % Mutation length for each gene - lower makespan, lower number
    %     shuffle_mat = fitness_minmaxLinear(...
    %         max(combined_machine_cost_mat,[],2));
    if mutation_method~= "all_genes_rndom_shuffle"
        if mutation_method == "mutate_greedy"
            mutate_method_inner = @mutate_greedy;
            mutate_method_inner_args = {mutate_num_shuffles};
        % Pick mutation method for each gene
        elseif mutation_method == "pair_swap"
            mutate_method_inner = @shuffle_pair_swap;
            mutate_method_inner_args = {};
        elseif mutation_method == "rndom_mach_chg"
            mutate_method_inner = @shuffle_rndom_mach_chg;
            mutate_method_inner_args = {mutate_num_shuffles};
        elseif mutation_method == "shuffle_rndom_mach_chg_load"
            mutate_method_inner = @shuffle_rndom_mach_chg;
            mutate_method_inner_args = {mutate_num_shuffles};
        else
            error("Invalid Mutation Method");
        end
        mutate_method = @mutate_population;
        mutate_args = {mutate_method_inner, mutate_method_inner_args};
    else
        mutate_method = @all_genes_rndom_shuffle;
        mutate_args = {mutate_num_shuffles};
    end
    
    %After mutate as uses the same mutation methods
    %TODO: Extend to init_simple_grad_rand
    init_method = @init_mix_shuff_rand;
    
    % If parallel, double the size of the initial population - will be
    % split into two batches later.
    if parallel
        init_args = {init_pop_size * 2, simple_prop, mutate_method, mutate_args};
    else
        init_args = {init_pop_size, simple_prop, mutate_method, mutate_args};
    end
    
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
            num_gen_no_improve, max_gens_allowed, ... %termination
            diagnose, parallel);%other args
end