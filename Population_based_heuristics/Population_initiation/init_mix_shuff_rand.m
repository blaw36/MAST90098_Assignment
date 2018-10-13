%% init_mix_shuff_rand.m
% initialises GA population by using a mix of (slightly) shuffled simples
% and random to a ratio

function [pop_mat, machine_cost_mat, num_jobs, num_machines, jobs_array_aug] = ...
    init_mix_shuff_rand(input_array_aug, init_pop_size, shuff_prop, ...
                        mutate_method, mutate_args)

    num_simple = round(shuff_prop*init_pop_size);
    num_random = init_pop_size - num_simple;
    length_of_input = length(input_array_aug);
    num_jobs = length_of_input - 1;
    num_machines = input_array_aug(length_of_input);

    % Keep input array with jobs only
    jobs_array_aug = input_array_aug(1:(end-1));
    
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
    machine_cost_mat = calc_machine_costs(jobs_array_aug, pop_mat, ...
        num_machines);
    
    %Mutate the Simple init cases so we have a more diverse population
    indivs_to_mutate = 1:num_simple;
    [pop_mat, machine_cost_mat] = ...
            mutate_method(indivs_to_mutate, pop_mat, ...
                        machine_cost_mat, num_machines, num_jobs, ...
                        jobs_array_aug, mutate_args{:});
end