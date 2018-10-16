%% genetic_alg_outer.m
% This is the 'outer' wrapper function for the Genetic Algorithm 
% population-based heuristic method for solving the makespan problem. This
% script translates desired methods for each operation from a string input 
% into a function handle, with the respective required arguments. These
% are then passed through into genetic_alg_inner, which begins performing 
% operations.

%% Methods:
% ~~Initiation method:
    % "init_mix_shuff_rand": Initiates a certain proportion with simple
        % greedy algo, plus mutation and a mutation factor to add some
        % noise to this deterministic process
    % "init_mix_rand_greedy": Randomly assigns first k jobs to a machine,
        % then does greedy assignment for the rest.
% ~~Fitness calculation: converts makespan to a probability or relative
% proportion for selection of crossover parents, mutation candidates.
    % "neg_exp": exp(-b * makespan / max_pop_mspan)
% ~~Mutation operations: operation which mutates based on an input fitness 
% array of all the individuals
    % "rndom_mach_chg": take k different jobs, reassign them to new
        % machines.
    % "mutate_greedy": take k different jobs, and reassign them to new
        % machines greedily (machines with the lowest cost, first)
    % "all_genes_rndom_shuffle": A batched method of performing the 
        % "rndom_mach_chg" mutation across all the mutation candidates
        % simultaneously, rather than by looping over each individual.
% ~~Crossover operations: to determine how the genes from two parents are
% carried over/split into the children
    % "rndm_split": cutover of two parents at many randomly selected
        % points, but still such that the 'stronger' parent still only gets 
        % up to their alloted number of job assignments to pass on to their
        % children.
    % "c_over_1": picks a random sequence of machines from the two
        % parents. Takes the first machine in the sequence, and all of its 
        % jobs, from the fitter parent, and carries the same assignment 
        % over to the child. This is repeated on the less fit parent, on
        % its first machine in the sequence where there exist no collisions
        % of jobs. We then continue this process back and forth,
        % alternating the picking and assignment and machines and parents,
        % until no more machines can be picked from either parent, due to
        % each machine containing at least one 'colliding' job. The
        % remaining unassigned jobs are assigned greedily.
    % "c_over_2": takes a set proportion of the fitter parent's
        % machines, and for each machine, carries over all the jobs to the
        % child. Note that the machines may be relabelled in the child. It
        % then takes a set proportion of the less fit parent's machines,
        % and inserts them into the child if, for each machine, there
        % exists no jobs already assigned (a 'collision') by the fitter 
        % parent. Then, as many machines without collisions from the fitter
        % parent are assigned to the child. Jobs remaining unassigned are
        % assigned greedily.
    % "c_over_2_all": A batched method of performing the c_over_2 cutover
        % across all the parent pairings simultaneously, rather than 
        % pairwise.
% ~~Population culling operations: determines how to scale down the 
% population to carry on to the next generation
    % "top_and_bottom": fills x% of the required number by the top (by 
        % makespan) individuals over, with the remaining (1-x)% required
        % made up by the bottom/worst individuals.
    % "top_and_randsamp": fills x% of the required number by the top n, the
        % rest are filled by a uniformly distributed random sample over the
        % remaining population.

%% Inputs:
% ~~Initialisation:
	% input_array: Array of jobs, number of machines
	% init_pop_size: size of population to initialise
    % init_method: string representing desired initiation method
	% simple_prop (for "init_mix_shuff_rand"): proportion of init_pop_size
        % to be taken from a simple initiation method.
    % init_prop_random (for "init_rand_greedy"): proportion of
        % init_pop_size to be assigned randomly.
    % num_tiers: deprecated (applies to methods not in use)
% ~~Fitness and selection:
	% selection_method: fitness calculation operation to generate 
        % probabilities of parent selection
    % alpha_parent: numerical constant for fitness function when selecting
        % parents
    % alpha_mutation: numerical constant for fitness function when 
        % selecting mutation candidates
% ~~Parents and crossover
    % parent_ratio: ratio of parents to init_pop_size for crossover. 
        % Eg: 2 means we pair up 2x init_pop_size parents together, 
        % resulting in init_pop_size number of children being created from 
        % crossover. (Half this number is ratio of children to
        % init_pop_size)
	% cross_over_method: Crossover operation to create children.
    % least_fit_proportion (used in "c_over_2", "c_over_2_all"): proportion
        % of machines from least fit parent to create a sequence from.
    % most_fit_proportion (used in "c_over_2", "c_over_2_all"): proportion
        % of machines from most fit parent to create a sequence from.
    % prop_switch_parent_fitness (used in "c_over_2", "c_over_2_all"): the 
        % probability of switching the most and least fit parents, and
        % treating them respectively. Adds some noise into the crossover
        % method.
% ~~Mutation:
	% mutate_method: mutation operation performed on selected individuals
    % mutate_proportion: the proportion of jobs to mutate for each chosen
        % individual
% ~~Population culling:        
	% popn_cull: the population culling operation to reduce population back
        % to init_pop_size for next generation
    % keep_prop: the proportion of the init_pop_size which will be composed
        % of the top (init_pop_size * keep_prop) individuals in the
        % population.
% ~~Termination conditions:
	% num_gen_no_improve: max # of generations without improvement
    % max_gens_allowed: max # of generations allowed
% ~~Other params:
    % diagnose: 'true' to keep an informative array of how the GA 
        % progressed between generations, and to print progress to screen
    % parallel: 'true' to run GA in paralle. Creates two separate GAs of
        % the specified size, runs in parallel, and each 'num_split_gens'
        % generations, combines, reshuffles, and resplits into two same
        % sized GAs.
    % num_split_gens: number of generations for each GA to run in parallel
        % before all the parallel GAs are combined together, reshuffled and
        % re-split into two even GAs for the next parallel step.
%% Outputs
    % See genetic_alg_inner 

%% Function
function [best_makespan, time_taken, init_makespan, best_output,...
    best_gen_num, generation_counter, diags_array] = ...
            genetic_alg_outer(input_array, ... % input array
            init_pop_size, init_method, simple_prop, init_prop_random, num_tiers, ... % initiation
            selection_method, alpha_parent, alpha_mutation, ... % fitness function
            parent_ratio, cross_over_method, ... % crossover
            least_fit_proportion, most_fit_proportion, ... % crossover
            prop_switch_parent_fitness, ... % crossover
            mutation_method, mutate_proportion, ... % mutation
            popn_cull, keep_prop, ... % culling
            num_gen_no_improve, max_gens_allowed, ... % termination conditions
            diagnose, ... % verbose/diagnose
            parallel, num_split_gens) % other arguments - implementation
    
    %% Fitness calculation function
    % For selecting parents -- bias (higher probability) for parents with
    % lower makespans (fitter)
    invert = false;
    
    if selection_method == "neg_exp"
        parent_selection_method = @fitness_negexp;
        parent_selection_args = {invert,alpha_parent};
    else
        error("Invalid Fitness Selection Method");
    end
    
    % For selecting mutation candidates -- bias (higher probability) for 
    % parents with higher makespans (less fit). Hence, invert = true.
    invert = true;
    if selection_method == "neg_exp"
        mutate_select_method = @fitness_negexp;
        mutate_select_args = {invert, alpha_mutation};
    else
        error("Invalid Fitness Selection Method");
    end
    
    %% Crossover methods
    cross_over_inner_args = {};
    if cross_over_method ~= "c_over_2_all"
        % If crossover is performed at a pairwise level, then:
        % 1) Assign the method for each pair
        if cross_over_method == "rndm_split"
            cross_over_inner_method = @c_over_rndm_split;
            cross_over_inner_args = {};
        elseif cross_over_method == "c_over_1"
            cross_over_inner_method = @c_over_1;
            cross_over_inner_args = {};
        elseif cross_over_method == "c_over_2"
            cross_over_inner_method = @c_over_2;
            cross_over_inner_args = {least_fit_proportion, ...
                                     most_fit_proportion,...
                                     prop_switch_parent_fitness};
        else
            error("Invalid Crossover Method");
        end
        % 2) Assign the wrapper (looping) function:
        cross_over_method = @crossover_population;
        cross_over_args = {cross_over_inner_method, cross_over_inner_args};
    else
        % If crossover method performs simultaneously across all pairs,
        % then:
        cross_over_method = @c_over_2_all;
        cross_over_args = {least_fit_proportion, most_fit_proportion,...
                            prop_switch_parent_fitness};
    end
    
    %% Mutation methods
    mutate_num_shuffles = floor(mutate_proportion*(size(input_array,2)-1));
    if mutation_method~= "all_genes_rndom_shuffle"
        % If mutation method is performed at an individual level, then:
        % 1) Assign the method for each individual
        if mutation_method == "mutate_greedy"
            mutate_method_inner = @mutate_greedy;
            mutate_method_inner_args = {mutate_num_shuffles};
        elseif mutation_method == "rndom_mach_chg"
            mutate_method_inner = @shuffle_rndom_mach_chg;
            mutate_method_inner_args = {mutate_num_shuffles};
        else
            error("Invalid Mutation Method");
        end
        % 2) Assign the wrapper (looping) function
        mutate_method = @mutate_population;
        mutate_args = {mutate_method_inner, mutate_method_inner_args};
    else
        % If mutation method performs simultaneously across all candidates,
        % then:
        mutate_method = @all_genes_rndom_shuffle;
        mutate_args = {mutate_num_shuffles};
    end
    
    %% Population initiation methods
    init_inner_args = {};
    if init_method == "init_mix_shuff_rand"
        init_method = @init_mix_shuff_rand;
        init_inner_args = {simple_prop, mutate_method, mutate_args};
    elseif init_method == "init_rand_greedy"
        init_method = @init_rand_greedy;
        init_inner_args = {init_prop_random};
    else
        error("Invalid Initiation method")
    end
    init_args = {init_pop_size, init_inner_args{:}};    
    
    %% Population culling methods
    if popn_cull == "top_and_randsamp"
        pop_cull_method = @cull_top_and_randsamp;
        pop_cull_args = {keep_prop};
    else
        error("Invalid Culling Method");
    end
    
    %% Pass to inner function
    [best_makespan, time_taken, init_makespan, best_output, best_gen_num, ...
        generation_counter, diags_array] = ...
        genetic_alg_inner(input_array, ...  % input array
            init_method, init_args, ... % initiation
            parent_selection_method, parent_selection_args,... % parent selection
            cross_over_method, cross_over_args, ... % crossover
            mutate_select_method, mutate_select_args, ... % mutation candidate selection
            mutate_method, mutate_args, ... % mutation
            pop_cull_method, pop_cull_args, ... % culling
            init_pop_size, parent_ratio, ... % 
            num_gen_no_improve, max_gens_allowed, ... % termination conditions
            diagnose, parallel, num_split_gens); % other args - implementation
end