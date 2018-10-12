%% crossover_population.m
% A function which is a wrapper for the crossover of the population:

function [crossover_children, machine_cost_mat_children, best_child,...
            c_over_time] = ...
    crossover_population(num_children, num_machines, num_jobs, ...
                            parent_mat, pop_mat, machine_cost_mat,...
                            makespan_mat, jobs_array_aug, crossover_method)

    % Give some ordering to parent machine numbers so they are more
    % meaningful in crossover, rather than having 2 'identical'
    % solutions (but with different arbitrary machine allocations)
    % crossing over into worse children. Re-assign machine numbers from
    % 1 (smallest mspan) to num_machine (largest mspan)

%         % Note: doubtful whether this actually helps
%         [pop_mat, machine_cost_mat] = ...
%             sort_population_mspan(pop_mat, machine_cost_mat, ...
%             num_machines, num_jobs, init_pop_size); 
        
    tic;
    crossover_children = zeros(num_children, num_jobs);
    machine_cost_mat_children = zeros(num_children, num_machines);
    for i = 1:num_children 
        % Can we do this in batch?
        parent_pair = parent_mat(i,:);
        parent_indiv = pop_mat(parent_pair,:);
        parent_fitness = makespan_mat(parent_pair,:);
        parent_machine_cost = machine_cost_mat(parent_pair,:);

        if crossover_method == "cutover_split"
            crossover_children(i,:) = ...
                c_over_split(parent_indiv, parent_fitness, num_jobs);
        elseif crossover_method == "rndm_split"
            crossover_children(i,:) = ...
                c_over_rndm_split(parent_indiv, parent_fitness, num_jobs);
        elseif crossover_method == "c_over_1"
            [crossover_children(i,:), machine_cost_mat_children(i,:)] = ...
                c_over_1(parent_indiv, parent_fitness, ...
                        parent_machine_cost, jobs_array_aug,...
                        num_jobs, num_machines);
        elseif crossover_method == "c_over_2"
            [crossover_children(i,:), machine_cost_mat_children(i,:)] = ...
                c_over_2(parent_indiv, parent_fitness, ...
                        parent_machine_cost, jobs_array_aug,...
                        num_jobs, num_machines);
        end
    end

    if crossover_method == "cutover_split" || crossover_method == "rndm_split"
        % Calculate cost per machine of children
        machine_cost_mat_children = calc_machine_costs(jobs_array_aug, ...
            crossover_children, num_machines);
    end
    best_child = min(max(machine_cost_mat_children,[],2));
    
    c_over_time = toc;
end