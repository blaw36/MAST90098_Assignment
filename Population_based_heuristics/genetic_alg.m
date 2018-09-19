%% genetic_algorithm.m
% uses a genetic algorithm population heuristic method for solving the
% makespan problem

% Initialise a population

function [output_array, makespan, generations] = ...
    genetic_alg(input_array, k, init_algo, k2_opt, ...
    init_pop_size)
%     crossover_method, mutation_method, fitness_func, ...
%     pop_selection_method,

% Generate initial population, calculate fitness and other diagnostics
% All randomly initialised for now
% TODO: 10% simple with shuffled machines, 90% random

shuffled_simples_genes = round(0.1*init_pop_size);
random_genes = init_pop_size - shuffled_simples_genes;

for i = 1:shuffled_simples_genes
    [num_jobs, num_machines, output_array, done] = ...
        process_input(input_array, k, "simple");
    pop(i).population = output_array;
    
    % Randomly shuffle two elements around
    j1 = randi(num_jobs,1,1);
    j2 = randi(num_jobs,1,1);
    while j1 == j2
        j2 = randi(num_jobs,1,1);
    end
    m1 = pop(i).population(j1,2);
    pop(i).population(j1,2) = pop(i).population(j2,2);
    pop(i).population(j2,2) = m1;
    
    %%%%%% REPEATED CODE BLOCK ALERT
    % Neaten and sort, from process_input. We're going to have to
    % functionalise just this part or separate the initialisation and
    % neatening functions.
    % Assign unique job_id to each job
    pop(i).population(:,3) = (1:num_jobs)';
    
    % Sort output_array by machine #
    pop(i).population = sortrows(...
        pop(i).population, 2);
    %%%%%%
    
    % Recalculate stats
    [program_costs,machine_start_indices,M,machine_costs,makespan,L] ...
        = initialise_supporting_structs(...
        pop(i).population, num_machines, num_jobs);
    pop(i).fitness = makespan;
    pop(i).prog_costs = program_costs;
    pop(i).mach_start = machine_start_indices;
    pop(i).movable_progs = M;
    pop(i).mach_costs = machine_costs;
end

for i = (shuffled_simples_genes+1):init_pop_size
    [num_jobs, num_machines, output_array, done] = ...
        process_input(input_array, k, "random");
    pop(i).population = output_array;
    
    [program_costs,machine_start_indices,M,machine_costs,makespan,L] ...
        = initialise_supporting_structs(...
        pop(i).population, num_machines, num_jobs);
    pop(i).fitness = makespan;
    pop(i).prog_costs = program_costs;
    pop(i).mach_start = machine_start_indices;
    pop(i).movable_progs = M;
    pop(i).mach_costs = machine_costs;
end

start_gen_makespan = inf;
new_gen_makespan = min([pop([1:end]).fitness]');

generations = 1;
no_chg_generations = 0;
%     while (new_gen_makespan - start_gen_makespan) < -5 % really arbitrary criteria
while no_chg_generations <= 10 % really arbitrary criteria
    
    % Save initial population in case we need to continue using it (no
    % improvement in this gen)
    starting_pop = pop;
    
    % Pop diagnostics to assign probability of being a parent (lower cost
    % is better)
    pop_fit = [pop([1:end]).fitness]';
    start_gen_makespan = new_gen_makespan;
    %     tot_score = sum(pop_fit);
    %     prob_parent = pop_fit./tot_score;
    %     cumul_prob_parent = cumsum(prob_parent);
    
    % Can't think of a way at the moment, just do linear min-max scaling
    max_pop_fit = max(pop_fit);
    min_pop_fit = min(pop_fit);
    pop_fit_scaled = -(pop_fit - max_pop_fit)/(max_pop_fit-min_pop_fit);
    pop_fit_scaled_tot = sum(pop_fit_scaled);
    prob_parent = pop_fit_scaled./pop_fit_scaled_tot ;
    cumul_prob_parent = cumsum(prob_parent);
    
    for i = 1:init_pop_size
        random = rand(1);
        parents(i) = min(find(random <= cumul_prob_parent));
    end
    
    % Crossover
    
    for i = 1:(init_pop_size/2)
        p1_gene = pop(parents((i*2)-1)).population;
        p2_gene = pop(parents((i*2))).population;
        
        % For comparability on the crossover
        [p1_gene_sort,p1_gene_sort_indx] = sortrows(p1_gene,1);
        [p2_gene_sort,p2_gene_sort_indx] = sortrows(p2_gene,1);
        
        p1_fitness = pop(parents((i*2)-1)).fitness;
        p2_fitness = pop(parents((i*2))).fitness;
        p1_wt = p1_fitness/(p1_fitness + p2_fitness);
        
        % 1 denotes get END of p1, 0 denotes get START of p1
        start_or_end = round(rand(1));
        % But lower wt is better, so use (1-p1_wt) when allocating
        % crossover portion.
        p1_carryover = floor(size(p1_gene_sort,1)*(1-p1_wt));
        if start_or_end == 1
            cross_point = size(p1_gene_sort,1) - p1_carryover;
            pop(init_pop_size+i).population = ...
                [p2_gene(p2_gene_sort_indx(1:cross_point),:); ...
                p1_gene(p1_gene_sort_indx((cross_point + 1):num_jobs),:)];
        elseif start_or_end == 0
            cross_point = p1_carryover;
            pop(init_pop_size+i).population = ...
                [p1_gene(p1_gene_sort_indx(1:cross_point),:); ...
                p2_gene(p2_gene_sort_indx((cross_point + 1):num_jobs),:)];
        end
        
        %%%%%% REPEATED CODE BLOCK ALERT
        % Neaten and sort, from process_input. We're going to have to
        % functionalise just this part or separate the initialisation and
        % neatening functions.
        % Assign unique job_id to each job
        pop(init_pop_size+i).population(:,3) = (1:num_jobs)';
        
        % Sort output_array by machine #
        pop(init_pop_size+i).population = sortrows(...
            pop(init_pop_size+i).population, 2);
        %%%%%%
        
        [program_costs,machine_start_indices,M,machine_costs,makespan,L] ...
            = initialise_supporting_structs(...
            pop(init_pop_size+i).population, ...
            num_machines, num_jobs);
        pop(init_pop_size+i).fitness = makespan;
        pop(init_pop_size+i).prog_costs = program_costs;
        pop(init_pop_size+i).mach_start = machine_start_indices;
        pop(init_pop_size+i).movable_progs = M;
        pop(init_pop_size+i).mach_costs = machine_costs;
        
    end
    
    % Mutate - randomly pick a point from the neighbourhood to slightly
    % mutate things (perhaps a 2 neighbourhood?)
    % For now, we'll just grab 2 jobs and swap their machines randomly
    for i = 1:length(pop)
        j1 = randi(num_jobs,1,1);
        j2 = randi(num_jobs,1,1);
        while j1 == j2
            j2 = randi(num_jobs,1,1);
        end
        m1 = pop(i).population(j1,2);
        pop(i).population(j1,2) = pop(i).population(j2,2);
        pop(i).population(j2,2) = m1;
        
        %%%%%% REPEATED CODE BLOCK ALERT
        % Neaten and sort, from process_input. We're going to have to
        % functionalise just this part or separate the initialisation and
        % neatening functions.
        % Assign unique job_id to each job
        pop(i).population(:,3) = (1:num_jobs)';
        
        % Sort output_array by machine #
        pop(i).population = sortrows(...
            pop(i).population, 2);
        %%%%%%
        
        [program_costs,machine_start_indices,M,machine_costs,makespan,L] ...
            = initialise_supporting_structs(...
            pop(i).population, ...
            num_machines, num_jobs);
        pop(i).fitness = makespan;
        pop(i).prog_costs = program_costs;
        pop(i).mach_start = machine_start_indices;
        pop(i).movable_progs = M;
        pop(i).mach_costs = machine_costs;
        
    end
    
    % Trim size back down to init_pop_size
    pop_fit = [pop([1:end]).fitness]';
    [pop_fit_sort, pop_fit_sort_indx] = sortrows(pop_fit);
    genes_to_keep = pop_fit_sort_indx(1:init_pop_size);
    
    pop = pop(genes_to_keep);
    
    [new_gen_makespan,which_min] = min([pop([1:end]).fitness]');
    
    % If we get > 10 generations with no change, stop.
    % Change is arbitrarily an improvement of 5
    if (new_gen_makespan - start_gen_makespan) >= -5
        no_chg_generations = no_chg_generations + 1;
    end
    
    % If no improvement at all, go back to the original population.
    if (new_gen_makespan > start_gen_makespan)
        pop = starting_pop;
        [new_gen_makespan,which_min] = min([pop([1:end]).fitness]');
    end
    
    generations = generations + 1;
    clc
    fprintf("Generation: %d \n", generations);
    fprintf("Makespan: %d \n", new_gen_makespan);
    
end

% Default return for now while function under construction
output_array = pop(which_min).population;
makespan = pop(which_min).fitness;
generations = generations;
end