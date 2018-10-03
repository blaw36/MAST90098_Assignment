%% mix_shuffle_random_init.m
% initialises GA population by using a mix of shuffle and random to a ratio

function [pop_mat, num_jobs, num_machines, jobs_array_aug] = ...
    init_mix_shuff_rand(input_array_aug, init_pop_size, shuff_prop, ...
    shuff_method)

shuffled_simples_indiv = round(shuff_prop*init_pop_size);
random_indiv = init_pop_size - shuffled_simples_indiv;
length_of_input = length(input_array_aug);
num_jobs = length_of_input - 1;
num_machines = input_array_aug(length_of_input);

% Keep input array with jobs only
jobs_array_aug = input_array_aug(1:(end-1));

% Shuffled - initiate shuffled with some random element swapped
simple_indiv_mat = zeros(shuffled_simples_indiv, num_jobs);
for i = 1:shuffled_simples_indiv
    % OPTIMISE THIS FN FOR OUR PURPOSES
    tmp = initialise_simple(input_array_aug, num_jobs, num_machines);
    % Keep in the 'input_array' order
    
    % Do random pairwise shuffling of some elements here otherwise top
    % 10% of solutions are all the same
    if shuff_method == "pair_swap"
        indiv_array = shuffle_pair_swap(tmp(:,2)', num_machines, ...
            num_jobs);
    elseif shuff_method == "rndom_mach_chg"
        indiv_array = shuffle_rndom_mach_chg(tmp(:,2)', num_machines, ...
            num_jobs, floor(num_jobs*0.1));
    end
        
    simple_indiv_mat(i,:) = indiv_array ;
end

% Random - initiate random initialisation
random_indiv_mat = zeros(random_indiv, num_jobs);
for i = 1:random_indiv
    % OPTIMISE THIS FN FOR OUR PURPOSES
    tmp = initialise_random(input_array_aug, num_jobs, num_machines);
    % Keep in the 'input_array' order
    
    random_indiv_mat(i,:) = tmp(:,2)';
end

pop_mat = [simple_indiv_mat; random_indiv_mat];
    
end