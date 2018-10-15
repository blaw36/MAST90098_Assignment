%% init_mix_shuff_rand.m
% initialises the population with a proportion of simple members of the
% population, who are mutated and a the remainder random.
%% Input:
    % input_array_aug: a vector of the jobs, ordered by cost and the number
        % of machines as the final element.
    % init_pop_size: The number of individuals in the population to
        %initialize.
    % simple_prop: The proportion of individuals to be initialised via 
        %simple, then mutated.
    % : The proportion of jobs to be assigned randomly.
    % mutate_method:
        % a handle to a function 
                %   [indiv_array, machine_cost_mat] = mutate_method(...
                %        indiv_array, num_machines, num_jobs, ...
                %        machine_cost_mat, jobs_array_aug, k)
        % which performs the mutate operation on each individual member of
        % the population.
    % mutate_method_args: additional args for the function
%% Output:
    % pop_mat: An init_pop_size x num_jobs matrix encoding the
        % job locations of each individual
    % machine_cost_mat: An init_pop_size x num_machines matrix encoding the
        % machine costs of each individual
    % num_jobs: the number of jobs
    % num_machines: the number of machines
    % job_costs: the cost of each job
%%
function [pop_mat, machine_cost_mat, num_jobs, num_machines,...
            job_costs] = ...
                init_mix_shuff_rand(input_array_aug, init_pop_size,...
                                    simple_prop, ...
                                    mutate_method, mutate_args)

    num_simple = round(simple_prop*init_pop_size);
    num_random = init_pop_size - num_simple;
    length_of_input = length(input_array_aug);
    num_jobs = length_of_input - 1;
    num_machines = input_array_aug(length_of_input);

    % Keep input array with jobs only
    job_costs = input_array_aug(1:(end-1));
    
    %Perform a simple Initiation and copy it num_simple times
    tmp = initialise_simple(input_array_aug, num_jobs, num_machines);
    tmp = tmp(:,2)';
    simple_indiv_mat = repmat(tmp, num_simple,1);
    
    % Random - initiate random initialisation
    random_indiv_mat = zeros(num_random, num_jobs);
    for i = 1:num_random
        tmp = initialise_random(input_array_aug, num_jobs, num_machines);
        % Keep in the 'input_array' order
        random_indiv_mat(i,:) = tmp(:,2)';
    end

    pop_mat = [simple_indiv_mat; random_indiv_mat];
    machine_cost_mat = calc_machine_costs(job_costs, pop_mat,num_machines);
    
    %Mutate the Simple init cases so we have a more diverse population
    indivs_to_mutate = 1:num_simple;
    [pop_mat, machine_cost_mat] = ...
            mutate_method(indivs_to_mutate, pop_mat, ...
                        machine_cost_mat, num_machines, num_jobs, ...
                        job_costs, mutate_args{:});
end