%% mix_shuffle_random_init.m
% initialises GA population by using a mix of shuffle and random to a ratio

function [pop_mat, num_jobs, num_machines] = ...
    init_mix_shuff_rand(input_array, init_pop_size, shuff_prop)

shuffled_simples_genes = round(shuff_prop*init_pop_size);
random_genes = init_pop_size - shuffled_simples_genes;
length_of_input = length(input_array);
num_jobs = length_of_input - 1;
num_machines = input_array(length_of_input);

% Shuffled - initiate shuffled with some random element swapped
simple_genes_mat = zeros(shuffled_simples_genes, num_jobs);
for i = 1:shuffled_simples_genes
    % OPTIMISE THIS FN FOR OUR PURPOSES
    tmp = initialise_simple(input_array, num_jobs, num_machines);
    % Keep in the 'input_array' order
    
    simple_genes_mat(i,:) = tmp(:,2)';
end

% Random - initiate random initialisation
random_genes_mat = zeros(random_genes, num_jobs);
for i = 1:random_genes
    % OPTIMISE THIS FN FOR OUR PURPOSES
    tmp = initialise_random(input_array, num_jobs, num_machines);
    % Keep in the 'input_array' order
    
    random_genes_mat(i,:) = tmp(:,2)';
end

pop_mat = [simple_genes_mat; random_genes_mat];
    
end