%% init_simple_grad_rand.m
% initialises GA population by using a mix of (slightly shuffled) simples,
% simples with just the machine numbers changed around, simples with
% increasing degrees of shuffles, and randoms.

function [pop_mat, num_jobs, num_machines, jobs_array_aug] = ...
    init_simple_grad_rand(input_array_aug, init_pop_size, shuff_prop, ...
    shuff_method,num_shuffles)

    % Currently generates 4 graduations, up to a max of half the pop'n
    half_popn = 0.5 * init_pop_size;
    shuffled_simples_indiv = min(round(shuff_prop*init_pop_size) * 4,...
        half_popn);
    batch_size = floor(shuffled_simples_indiv/4); 
    shuffled_simples_indiv = batch_size * 4;
    
    random_indiv = init_pop_size - shuffled_simples_indiv;
    length_of_input = length(input_array_aug);
    num_jobs = length_of_input - 1;
    num_machines = input_array_aug(length_of_input);

    % Keep input array with jobs only
    jobs_array_aug = input_array_aug(1:(end-1));
    
    num_shuffles = num_shuffles / 2;
    
    % Four levels of mutation change: base, double, double, double
    % Shuffled - initiate shuffled with some random element swapped
    simple_indiv_mat = zeros(shuffled_simples_indiv, num_jobs);
    for j = 1:4
        num_shuffles = min(num_shuffles * 2,num_jobs);
        for i = 1:batch_size

            tmp = initialise_simple(input_array_aug, num_jobs, num_machines);
            % Keep in the 'input_array' order

            % Do random pairwise shuffling of some elements here otherwise
            % these solutions are all the same (as this method is not random)
            if shuff_method == "pair_swap"
                indiv_array = shuffle_pair_swap(tmp(:,2)', num_machines, ...
                    num_jobs);
            elseif shuff_method == "rndom_mach_chg"
                indiv_array = shuffle_rndom_mach_chg(tmp(:,2)', num_machines, ...
                    num_jobs, num_shuffles);
            end

            simple_indiv_mat((j-1)*batch_size + i,:) = indiv_array ;
        end
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