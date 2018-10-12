%% crossover_population.m
% A function which is a wrapper for the crossover of the population:

function [crossover_children, machine_cost_mat_children] = ...
    crossover_population(num_children, num_machines, num_jobs, ...
                            parent_mat, pop_mat, machine_cost_mat,...
                            makespan_mat, jobs_array_aug, ...
                            cross_over_method, cross_over_method_args)

    % Give some ordering to parent machine numbers so they are more
    % meaningful in crossover, rather than having 2 'identical'
    % solutions (but with different arbitrary machine allocations)
    % crossing over into worse children. Re-assign machine numbers from
    % 1 (smallest mspan) to num_machine (largest mspan)

%         % Note: doubtful whether this actually helps
%         [pop_mat, machine_cost_mat] = ...
%             sort_population_mspan(pop_mat, machine_cost_mat, ...
%             num_machines, num_jobs, init_pop_size); 
    crossover_children = zeros(num_children, num_jobs);
    machine_cost_mat_children = zeros(num_children, num_machines);
    for i = 1:num_children 
        % Can we do this in batch?
        parent_pair = parent_mat(i,:);
        parent_indiv = pop_mat(parent_pair,:);
        parent_fitness = makespan_mat(parent_pair,:);
        parent_machine_cost = machine_cost_mat(parent_pair,:);
        
        [crossover_children(i,:), machine_cost_mat_children(i,:)] = ...
                cross_over_method(parent_indiv, parent_fitness, ...
                        parent_machine_cost, jobs_array_aug,...
                        num_jobs, num_machines, cross_over_method_args{:});
    end
end