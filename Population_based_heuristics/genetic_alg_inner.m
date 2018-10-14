%% genetic_alg_inner.m
% uses a genetic algorithm population heuristic method for solving the
% makespan problem

%% Inputs:
    % input_array: an array of lengther number of jobs + 1, where the first
        % n entries encode job sizes and the last entry, the number of
        % machines
    % init_method:
        % a handle to a function
        % [pop_mat, num_jobs, num_machines, jobs_array_aug] = ...
        %                        init_method(input_array_aug, init_args{:})
        % which process, the input and returns the initial population
    % init_args: additional optional arguments to the function above.
    % parent_selection_method:
        % a handle to a function
        % prob_parent_select = parent_selection_method(makespan_mat, ...
        %                                        parent_selection_args{:});
        % which computes the probability of selection of each member of the
        % population, with a function of the makespan
    % parent_selection_args: additional optional arguments to the function above.
    % cross_over_method:
    % a handle to a function
        %[crossover_children, machine_cost_mat_children] = ...
        %         cross_over_method(num_children, num_machines,...
        %                           num_jobs, parent_mat, pop_mat,...
        %                           machine_cost_mat, makespan_mat, ...
        %                           jobs_array_aug, cross_over_args{:});
        % which performs the crossover operation
    % cross_over_args: additional optional arguments to the function above.
    % mutate_select_method:
        % a handle to a function
        % prob_mutation_select = mutate_select_method(combined_makespan_mat, ...
        %                                        mutate_select_args{:});
        % which computes the probability of selection of each member of the
        % population, with a function of the makespan
    % mutate_select_args: additional optional arguments to the function above.
    % mutate_method:
    % mutate_args: additional optional arguments to the function above.
    % pop_cull_method:
    % pop_cull_args: additional optional arguments to the function above.
    % init_pop_size:
    % parent_ratio:
    % num_gen_no_improve:
    % max_gens_allowed:
    % diagnose:

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
            num_gen_no_improve, max_gens_allowed, ... %termination
            diagnose, parallel) %other args

    start_time = tic;

    % wlog, shuffle input_array such that jobs arranged largest to smallest
    % (aligns with our simple initialisation also)
    input_array_aug = [sort(input_array(:,1:(end-1)), 'descend'), ...
                        input_array(end)];

    % Generate initial population
    % Each row corresponds to an individual, each column corresponds to the machine
    % allocated to that job (job order same as in input_array_aug, for all
    % individuals)
    [pop_mat, machine_cost_mat, num_jobs, num_machines, jobs_array_aug] = ...
                                init_method(input_array_aug, init_args{:});

    % Calculate makespan
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
    
    if diagnose
        % Initialise diagnostics array
        % Add to diagnostics table
            % Columns: Generation#, Best makespan in gen, Best makespan,
            % AvgFit, MinFit, MaxFit NumParentsSurvive, NumChildrenSurvive
        gen_result = [generation_counter, new_gen_makespan, new_gen_makespan, ...
                        round(mean(makespan_mat)), ...
                        round(min(makespan_mat)), round(max(makespan_mat)), ...
                        init_pop_size, 0];
        diags_array = [gen_result];
    else
        diags_array = [];
    end
        
    % Termination criteria: # generations with no improvement, max number
    % of generations
    while no_chg_generations <= num_gen_no_improve && ...
            generation_counter <= max_gens_allowed
        
%         if parallel
%             % Split data into two even batches
%                 b1 = logical(zeros(2*init_pop_size,1));
%                 b2 = b1;
%                 b1(randperm(2*init_pop_size,init_pop_size)) = 1;
%                 b2 = logical(1 - b1);
%                 b = [b1, b2];
%                 for i = 1:2
%                     parallel_data(i).pop_mat = pop_mat(b(:,i),:);
%                     parallel_data(i).machine_cost_mat = ...
%                         machine_cost_mat(b(:,i),:);
%                     parallel_data(i).makespan_mat = makespan_mat(b(:,i),:);
%                     parallel_data(i).parent_child_indicator = {};
%                 end
%             
%             parfor b = 1:2 % 2 processes
%                 [parallel_data(b).pop_mat, ...
%                     parallel_data(b).machine_cost_mat, ...
%                     parallel_data(b).makespan_mat, ...
%                     parallel_data(b).parent_child_indicator] = ...
%                     genetic_alg_iteration(best_generation, ...
%                     parallel_data(b).pop_mat, ...
%                     parallel_data(b).makespan_mat, ...
%                     parallel_data(b).machine_cost_mat, ...
%                     jobs_array_aug, num_machines, num_jobs, ...
%                     parent_selection_method, parent_selection_args,... %parent sel
%                     cross_over_method, cross_over_args, ... %crossover
%                     mutate_select_method, mutate_select_args, ...
%                     mutate_method, mutate_args, ... %mutation
%                     pop_cull_method, pop_cull_args, ... %culling
%                     init_pop_size, parent_ratio);
%             end
%             
%             pop_mat = [parallel_data(1).pop_mat; parallel_data(2).pop_mat];
%             machine_cost_mat = [parallel_data(1).machine_cost_mat; ...
%                 parallel_data(2).machine_cost_mat];
%             makespan_mat = [parallel_data(1).makespan_mat; ...
%                 parallel_data(2).makespan_mat];
%             parent_child_indicator = [parallel_data(1).parent_child_indicator; ...
%                 parallel_data(2).parent_child_indicator];
%             
%         else

            [pop_mat, machine_cost_mat, makespan_mat, parent_child_indicator, ...
                c_over_time, mutation_time, best_parent, best_child, ...
                best_pre_mutate, best_post_mutate] = ...
                genetic_alg_iteration(best_generation, pop_mat, makespan_mat, ...
                machine_cost_mat, jobs_array_aug, num_machines, num_jobs, ...
                parent_selection_method, parent_selection_args,... %parent sel
                cross_over_method, cross_over_args, ... %crossover
                mutate_select_method, mutate_select_args, ...
                mutate_method, mutate_args, ... %mutation
                pop_cull_method, pop_cull_args, ... %culling
                init_pop_size, parent_ratio, ...
                parallel);
        
%         end
        
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
        
        if diagnose
            %Output Diagnostics
            clc
            fprintf("Jobs: %d \n", num_jobs);
            fprintf("Machines: %d \n", num_machines);
            fprintf("Generation: %d \n", generation_counter);
            fprintf("Best makespan in generation: %d \n", new_gen_makespan);
            %fprintf("Best generation makespan: %d \n", best_generation{3});
            fprintf("Best makespan: %d \n", best_makespan);
            fprintf("Avg fitness: %d \n", round(mean(makespan_mat)));
            fprintf("Min fitness: %d \n", round(min(makespan_mat)));
            fprintf("Max fitness: %d \n", round(max(makespan_mat)));
            fprintf("Num gens no improvement: %d \n", no_chg_generations);
            fprintf("Num parents survived: %d \n", ...
                sum(parent_child_indicator == 1));
            fprintf("Num children survived: %d \n", ...
                sum(parent_child_indicator == 0));
            
%             if ~parallel    
                fprintf("Crossover time: %2.6f\n", c_over_time);
                fprintf("Mutation time: %2.6f\n", mutation_time);
                fprintf("Best parent: %d\n", best_parent);
                fprintf("Best child: %d\n", best_child);
                fprintf("Best pre-mutate cand: %d\n", best_pre_mutate);
                fprintf("Best post-mutate cand: %d\n", best_post_mutate);
%             end

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

    end

    % Convert best_output to standard output_array format produced by other
    % two algorithms
    best_output = [jobs_array_aug', best_sol'];
    best_output = sortrows(best_output,2);
    best_output(:,3) = zeros(num_jobs,1); % third column is just arbitrary as a
    % placeholder
    
    time_taken = toc(start_time);
end