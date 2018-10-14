%% init_rand_greedy_tiered.m
% similar to init_rand_greedy, but now creates a certain number of tiers
% (num_tiers) of randomised initialisations - first tier starts with
% 1/num_tiers randomised, second tier has 2/num_tiers randomised, etc,
% until the final tier has all elements randomised.

function [pop_mat, machine_cost_mat, num_jobs, num_machines, jobs_array_aug] = ...
    init_rand_greedy_tiered(input_array_aug, init_pop_size, num_tiers)

    length_of_input = length(input_array_aug);
    num_jobs = length_of_input - 1;
    num_machines = input_array_aug(length_of_input);
    
    % Keep input array with jobs only
    jobs_array_aug = input_array_aug(1:(end-1));
    
    % Jobs to be selected at random at each tier
    jobs_in_tier = ceil(num_jobs/num_tiers);
    
    % Num of pop'n to be in each tier
    popn_in_tier = ceil(init_pop_size/num_tiers);
    
    pop_mat = zeros(init_pop_size, num_jobs);
    machine_cost_mat = zeros(init_pop_size, num_machines);
    
    for j = 1:num_tiers
        % Assign first j*jobs_in_tier(j) jobs at random to popn_in_tier
        % members at a time
        
        job_finish = min((j*jobs_in_tier),num_jobs);
        pop_start = ((j-1)*popn_in_tier+1);
        pop_finish = min((j*popn_in_tier),init_pop_size);
        
        pop_mat(pop_start:pop_finish,...
            1:job_finish) = ...
            randi(num_machines,pop_finish - pop_start + 1, job_finish);
        
        machine_cost_mat(pop_start:pop_finish,:) = ...
            calc_machine_costs(jobs_array_aug, ...
            pop_mat(pop_start:pop_finish,:), num_machines);
        
        % Do the rest greedily
        % Check which jobs still need to be assigned
        un_assigned_jobs = (job_finish+1):num_jobs;
        
        % Assign the remaining jobs
        for job = un_assigned_jobs
            [cost, loc] = min(machine_cost_mat(pop_start:pop_finish,:),[],2);
            for i = 1:(pop_finish - pop_start + 1)
                pop_mat(pop_start:pop_finish,job) = loc(i);
                machine_cost_mat(pop_start + i - 1, loc(i)) = ...
                    cost(i) + jobs_array_aug(job);
            end
        end
    end
    
end