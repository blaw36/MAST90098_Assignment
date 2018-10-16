% Testing between GA algos
figure_save_path = "Figures/";
table_save_path = "Tables/";

%% Testing Parameters
%Compare algorithms sets the seed based on num_machines*num_programs prior
%to generating all of the test instances. So by making sure that all
%algorithms are using the same programs_range (and same machines
%proportion) we can ensure they are using the same test cases.

% GA
% base_cases_machines_vary = [100:100:300];

% machines_proportion = 0.4;
machines_denom_iterator = 10;
num_trials = 10;

hard = false;
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);

%% Algorithms:
all_alg_names = ["Genetic, iteration 4", "Genetic, iteration 5", "Genetic, iteration 6"];

alg1 = @(input_array, args) genetic_alg_outer(input_array, args{:});
alg1_args = {   100, "init_mix_shuff_rand", 0.1, 0.85, 20, ... %inits
                "neg_exp", 3, 3, ... %selection
                4, "c_over_2_all", ...
                1/2, 1/3, 0.1, ... %crossover
                "all_genes_rndom_shuffle", 0.2, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                10, 100, ...  %termination
                false, ... %verbose/diagnose
                true, 4}; %termination

alg2 = @(input_array, args) genetic_alg_outer(input_array, args{:});
alg2_args = {   100, "init_rand_greedy", 0.1, 0.85, 20, ... %inits
                "neg_exp", 3, 3, ... %selection
                4, "c_over_2_all", ...
                1/2, 1/3, 0.1, ... %crossover
                "all_genes_rndom_shuffle", 0.2, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                10, 100, ...  %termination
                false, ... %verbose/diagnose
                true, 4}; %termination
            
alg3 = @(input_array, args) genetic_alg_outer(input_array, args{:});
alg3_args = {   100, "init_rand_greedy", 0.1, 0.85, 20, ... %inits
                "neg_exp", 3, 3, ... %selection
                4, "c_over_2_all", ...
                1/2, 1/3, 0.1, ... %crossover
                "mutate_greedy", 0.2, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                10, 100, ...  %termination
                false, ... %verbose/diagnose
                true, 4}; %termination

all_algs = {alg1, alg2, alg3};
all_algs_args = {alg1_args, alg2_args, alg3_args};

% Section 1.d.

%Find the cases to be plotted
programs_range = [100:100:200];%300];
num_programs_subset = [1:length(programs_range)];

%% Testing - Varying machines proportion
algs = all_algs;
algs_args = all_algs_args;

% results = compare_algorithms(algs, algs_args, gen_method, ...
%                             programs_range, machines_denom_iterator, ...
%                             num_trials);
%% Analysis - Varying machines proportion
alg_subset = 2:3;
save_name = "GA-its-5-and-6";
alg_names = all_alg_names(alg_subset);

alg_subset = 1:length(alg_names);

% alg_subset = 1:2;
analyse_varying_m(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator,...
                        alg_names, figure_save_path, save_name);
                    
construct_results_table(results, alg_names, alg_subset, ...
                        programs_range, machines_denom_iterator, ...
                        table_save_path, save_name)
