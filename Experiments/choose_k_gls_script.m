% A script used to experimentally justify our choice of k for GLS.
% Vary over init method as well
% Desired Output:
%   Graphs:
%       Varying machines
%           Log_10 Time 
%           Ratio to Initiation
%           Ratio to LowerBound
%           -> Use these to establish using machine proportion of 0.4
%       Varying just num_programs with machine_proportion of 0.4
%           vary_init_method
%               Log_10 Time 
%               Ratio to Initiation
%               Ratio to LowerBound
%       -> Use these all to establish choice of k
%   Tables: All to appendix    
figure_save_path = "Figures/";
table_save_path = "Tables/";

%% Testing Parameters
machines_denom_iterator = 10;
num_trials = 20;

hard = false;
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);
init_method = "simple";            
save_name = "Experiment-Choose-k-Simple";

%30/10 = 3
programs_range = 50:10:100;

%% Algorithms:
alg_names = ["GLS,k=2", "GLS,k=3", "GLS,k=4"];

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, init_method, false};

alg2 = @(input_array, args) gls(input_array, args{:});
alg2_args = {3, init_method, false};

alg3 = @(input_array, args) gls(input_array, args{:});
alg3_args = {4, init_method, false};

algs = {alg1, alg2, alg3};
algs_args = {alg1_args, alg2_args, alg3_args};
% all algs
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
programs_range = 50:10:100;
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
%% Fixed machines proportion again with Random Init
init_method = "random";            
save_name = "Experiment-Choose-k-Random";

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, init_method, false};

alg2 = @(input_array, args) gls(input_array, args{:});
alg2_args = {3, init_method, false};

alg3 = @(input_array, args) gls(input_array, args{:});
alg3_args = {4, init_method, false};

algs = {alg1, alg2, alg3};
algs_args = {alg1_args, alg2_args, alg3_args};
% all algs
alg_subset = 1:length(algs);

%% Testing - Fixed machines proportion Random Init
results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
%% Analysis - Fixed machines proportion Random Init
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                    programs_range, machines_denom_iterator, ...
                    table_save_path, save_name, machines_proportion)