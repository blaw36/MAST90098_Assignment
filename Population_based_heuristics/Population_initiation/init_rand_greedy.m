%% init_rand_greedy.m
% initialises population by assigning the first proportion of jobs to
% random machines, then greedily (simply) asssigning the rest.
%% Input:
    % input_array_aug: a vector of the jobs, ordered by cost and the number
        % of machines as the final element.
    %init_pop_size: The number of individuals in the population to
        %initialize.
    %init_prop_random: The proportion of jobs to be assigned randomly.
%% Output:
    % pop_mat: An init_pop_size x num_jobs matrix encoding the
        % job locations of each individual
    % machine_cost_mat: An init_pop_size x num_machines matrix encoding the
        % machine costs of each individual
    % num_jobs: the number of jobs
    % num_machines: the number of machines
    % job_costs: the cost of each job
%%
function [pop_mat, machine_cost_mat, num_jobs, num_machines, job_costs] = ...
    init_rand_greedy(input_array_aug, init_pop_size, init_prop_random)

    length_of_input = length(input_array_aug);
    num_jobs = length_of_input - 1;
    num_machines = input_array_aug(length_of_input);
    
    % Keep input array with jobs only
    job_costs = input_array_aug(1:(end-1));
    
    % Num jobs to assign randomly:
    if init_prop_random<0
        init_prop_random = 0;
    elseif init_prop_random>1
        init_prop_random = 1;
    end
    jobs_rndm = floor(num_jobs * init_prop_random);

    % Assign first k jobs to random machines
    pop_mat = zeros(init_pop_size, num_jobs);
    pop_mat(:,1:jobs_rndm) = randi(num_machines,init_pop_size,jobs_rndm);

    machine_cost_mat = calc_machine_costs(job_costs, pop_mat,num_machines);
    
    % Assign the largest unassigned job, to the emptiest machine until
    % done.
    
    % Check which jobs still need to be assigned
    un_assigned_jobs = (jobs_rndm+1):num_jobs;

    % Assign the remaining jobs
    for job = un_assigned_jobs
        [cost, loc] = min(machine_cost_mat,[],2);
        for i = 1:init_pop_size
            pop_mat(i,job) = loc(i);
            machine_cost_mat(i, loc(i)) = cost(i) + job_costs(job); 
        end
    end
end