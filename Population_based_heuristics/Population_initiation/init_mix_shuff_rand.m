%% init_mix_shuff_rand.m
% initialises GA population by using a mix of (slightly) shuffled simples
% and random to a ratio

function [pop_mat, num_jobs, num_machines, jobs_array_aug] = ...
    init_mix_shuff_rand(input_array_aug, init_pop_size, shuff_prop, ...
    shuff_method,num_shuffles)

    shuffled_simples_indiv = round(shuff_prop*init_pop_size);
    random_indiv = init_pop_size - shuffled_simples_indiv;
    length_of_input = length(input_array_aug);
    num_jobs = length_of_input - 1;
    num_machines = input_array_aug(length_of_input);

    % Keep input array with jobs only
    jobs_array_aug = input_array_aug(1:(end-1));

    % Shuffled - initiate shuffled with some random element swapped
    simple_indiv_mat = zeros(shuffled_simples_indiv, num_jobs);
    
    %Can have this out here as not changing each time
    tmp = initialise_simple(input_array_aug, num_jobs, num_machines);
    %[~, ~, ~, tmp] = gls(input_array_aug, 2, 'simple', true);
    tmp = tmp(:,2)';
    for i = 1:shuffled_simples_indiv
        % Do random pairwise shuffling of some elements here otherwise
        % these solutions are all the same (as this method is not random)
        if shuff_method == "pair_swap"
            indiv_array = shuffle_pair_swap(tmp, num_machines, ...
                num_jobs);
        elseif shuff_method == "rndom_mach_chg"
            indiv_array = shuffle_rndom_mach_chg(tmp, num_machines, ...
                num_jobs, num_shuffles);
        end

        simple_indiv_mat(i,:) = indiv_array ;
    end

    % Random - initiate random initialisation
    random_indiv_mat = zeros(random_indiv, num_jobs);
    for i = 1:random_indiv

        tmp = initialise_random(input_array_aug, num_jobs, num_machines);
        % Keep in the 'input_array' order

        random_indiv_mat(i,:) = tmp(:,2)';
    end

    pop_mat = [simple_indiv_mat; random_indiv_mat];
    
end