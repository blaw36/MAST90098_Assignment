def genetic_alg(input_array, init_pop_size, simple_prop,
                parent_ratio, ... ): 

    #This function takes the parameters that will be used by the functions

    #Declare all the functions that will be used here using handlers
    # like in the experiments


    init_func = @(...) chosen_init_func(...)
    #eg
    init_func = @(input_array_aug, init_pop_size) init_mix_shuff_rand(input_array_aug, init_pop_size, simple_prop)
    #^ we are treating input_array_aug, init_pop_size as required inputs and simple prop
    #as an additional arg used by the function
    ...

    #Or could just have one mutation func
    mutation_selction_func = @(...)
    mutation_fun = @(...) chosen_mutation_func(mutation_selction_func, ...)

    ...

    genetic_alg_wrapper(init_func, parent_selection_func, ...)
"""
%
%% Inputs:
    % init_func: a handle to the initialisation function,
        % the handle must be of the form 
        % init_func = @(input_array_aug, init_pop_size) f(input_array_aug, init_pop_size, ...)
        % where f returns [pop_mat, num_jobs, num_machines, jobs_array_aug]
    % ...
%
"""
def genetic_alg_wrapper(input_array, init_func, parent_selection_func,
                        termination_func, parent_selection_func, 
                        crossover_func, mutation_fun, population_cull_func)
    
    #--------------------------------------------------------------------------
    % wlog, shuffle input_array such that jobs arranged largest to smallest
    % (aligns with our simple initialisation also)
    input_array_aug = zeros(size(input_array));
    input_array_aug = [sort(input_array(:,1:(end-1)), 'descend'), ...
        input_array(end)];
    #--------------------------------------------------------------------------
    
    [pop_mat, num_jobs, num_machines, jobs_array_aug] = init_func(...)

    #--------------------------------------------------------------------------
    % Calculate cost per machine for each gene, as well as makespan
    machine_cost_mat = calc_machine_costs(jobs_array_aug, pop_mat, ...
        num_machines);
    makespan_mat = max(machine_cost_mat,[],2);

    % Begin iterations
    start_gen_makespan = inf;
    [new_gen_makespan,gene_indx] = min(makespan_mat);

    % Initialise generation counter
    generation_counter = 1;
    no_chg_generations = 0;

    % Initialise best generation heuristics
    best_generation = {};
    best_generation = {generation_counter, pop_mat(gene_indx,:), new_gen_makespan};
    #--------------------------------------------------------------------------

    while termination_func(...)
        #----------------------------------------------------------------------
        parents_mat = parent_selection_func(...)
        #----------------------------------------------------------------------
        num_children = size(parent_mat,1);
        #----------------------------------------------------------------------

        #----------------------------------------------------------------------
        ... = crossover_func(...)

        #----------------------------------------------------------------------
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
        #----------------------------------------------------------------------

        ... = mutation_fun(...)

        #----------------------------------------------------------------------
        combined_makespan_mat = max(combined_machine_cost_mat,[],2);
        #----------------------------------------------------------------------

        ... = population_cull_func(...)

        #----------------------------------------------------------------------
        
        update bookkeeping vals