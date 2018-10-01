%A script to measure the performance gain of k2_generate_and_test
%over the standard generate_and_test. (This should just be for GLS)

% Desired Output:
%   Graphs:
%       Varying machines
%           Log_10 Time 
%           Relative_error
%           -> Use these to establish using machine proportion of 0.4
%       Varying just num_programs with machine_proportion of 0.4
%           Log_10 Time
%   Tables: All to appendix  
figure_save_path = "Figures/";
table_save_path = "Tables/";
save_name = "Experiment-k2-opt";

%% Testing Parameters
hard = false;
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);

programs_range = 5000:5000:35000;
machines_denom_iterator = 10;
num_trials = 20;

%% Algorithms:
alg_names = ["GLS,k=2,opt", "GLS,k=2"];

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, "simple", true};

alg2 = @(input_array, args) gls(input_array, args{:});
alg2_args = {2, "simple", false};

algs = {alg1, alg2};
algs_args = {alg1_args, alg2_args};
%all algs
alg_subset = 1:length(algs);

%all of the range
%num_programs_subset = 1:length(programs_range);
%Only display 6 lines
num_lines = 6;
num_algs = length(algs);
num_dif_programs = length(programs_range);
num_programs_subset = choose_subset_to_plot(num_lines, num_algs,...
                                            num_dif_programs);

%% Testing - Varying machines proportion
results = compare_algorithms(algs, algs_args, gen_method, ...
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
machines_proportion = 0.4;
programs_range = [200:200:800,1000:1000:4000,5000:5000:35000];
%all of the range
num_programs_subset = 1:length(programs_range);

results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
%% Analysis - Fixed machines proportion
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                    programs_range, machines_denom_iterator, ...
                    table_save_path, save_name, machines_proportion)