%Extracts results of GLS and VDS from end of compare all and just runs, the
%changed genetic algorithm with the changes.

num_trials = 10;

alg3 = @(input_array, args) genetic_alg_outer(input_array, args{:});
alg3_args = {   100, "init_rand_greedy", 0.27, 0.85, 20, ... %inits
                "neg_exp", 7, 0.49, ... %selection
                0.5, "c_over_2_all", ...
                1, 1/3, 0.1, ... %crossover
                "all_genes_rndom_shuffle", 0.65, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                5, 1000, ...  %termination
                false, ... %verbose/diagnose
                true, 4}; %termination

%Just alg3 by self
algs = {alg3};
algs_args = {alg3_args};

save_name = "Experiment-All-Easy";
alg_names = ["GLS,k=2,simple", "VDS,k=2,random", "Genetic"];
alg_subset = 1:3;

%% Testing - Varying machines proportion
programs_range = base_cases_machines_vary;
results = r1;

%Re-run genetic
results(3,:,:,:) = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials);
%% Analysis - Varying machines proportion
analyse_varying_m(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator,...
                        alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                        programs_range, machines_denom_iterator, ...
                        table_save_path, save_name)
%% Testing - Fixed machines proportion
%all of the range
programs_range = base_cases_fixed_prop;
num_programs_subset = 1:length(programs_range);

%Extract from the reulsts accross all machine proportions, the proportion
%of 0.4, aka the 4th, 
% (results is num_algs x num_programs x num_proprtions x num_metrics)
results = r1(:,:,4,:);

%Re-run genetic
results(3,:,:,:) = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);

%% Analysis - Fixed machines proportion
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                    programs_range, machines_denom_iterator, ...
                    table_save_path, save_name, machines_proportion)

save_name = "Experiment-All-Hard";
hard = true;
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);

%% Testing - Varying machines proportion
programs_range = base_cases_machines_vary;
results = r3;

%Re-run genetic
results(3,:,:,:) = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials);
%% Analysis - Varying machines proportion
num_programs_subset = [find(programs_range==50), ...
                        find(programs_range==500)];
analyse_varying_m(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator,...
                        alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                        programs_range, machines_denom_iterator, ...
                        table_save_path, save_name)
% %% Testing - Fixed machines proportion
programs_range = base_cases_fixed_prop;
num_programs_subset = 1:length(programs_range);

%Extract from the reulsts accross all machine proportions, the proportion
%of 0.4, aka the 4th, 
% (results is num_algs x num_programs x num_proprtions x num_metrics)
results = r3(:,:,4,:);

%Re-run genetic
results(3,:,:,:) = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
%% Analysis - Fixed machines proportion
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                    programs_range, machines_denom_iterator, ...
                    table_save_path, save_name, machines_proportion)
                