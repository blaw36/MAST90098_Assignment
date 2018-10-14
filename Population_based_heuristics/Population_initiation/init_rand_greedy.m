%% init_rand_greedy.m
% initialises GA population by assigning first k*num_jobs to random machines
% machines, then doing a greedy (simple) on the rest

function [pop_mat, machine_cost_mat, num_jobs, num_machines, jobs_array_aug] = ...
    init_rand_greedy(input_array_aug, init_pop_size, k)

    length_of_input = length(input_array_aug);
    num_jobs = length_of_input - 1;
    num_machines = input_array_aug(length_of_input);
    
    % Keep input array with jobs only
    jobs_array_aug = input_array_aug(1:(end-1));
    
    % Num jobs to assign randomly:
    if k < 0
        k = 0;
    elseif k > 1
        k = 1;
    end
    jobs_rndm = floor(num_jobs * k);

    % Assign first k jobs to random machines
    pop_mat = zeros(init_pop_size, num_jobs);
    pop_mat(:,1:jobs_rndm) = randi(num_machines,init_pop_size,jobs_rndm);
    
    % How about assigning k random jobs to k random machines?

    machine_cost_mat = calc_machine_costs(jobs_array_aug, pop_mat, ...
    num_machines);
    
    % Do the rest greedily
    % Check which jobs still need to be assigned
    un_assigned_jobs = (jobs_rndm+1):num_jobs;

    % Assign the remaining jobs
    for job = un_assigned_jobs
        % Randomise the 0s we assign it to?
        [cost, loc] = min(machine_cost_mat,[],2);
        for i = 1:init_pop_size
            pop_mat(i,job) = loc(i);
            machine_cost_mat(i, loc(i)) = cost(i) + jobs_array_aug(job); 
        end
    end

end