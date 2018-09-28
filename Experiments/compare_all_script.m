%This script runs the experiments for 1.d, 2.c and 3.
figure_save_path = "Figures/";
table_save_path = "Tables/";

%% Testing Parameters
%Compare algorithms sets the seed based on num_machines*num_programs prior
%to generating all of the test instances. So by making sure that all
%algorithms are using the same programs_range (and same machines
%proportion) we can ensure they are using the same test cases.

%Different algorithms may have significantly different run times so may
%want to have additional larger cases for some algs, can just take these in
%on the end.

base_cases = 50:10:70;
%GLS
programs_ranges(1).program_range = [base_cases, 200:50:300];
%GLS+VDS
programs_ranges(2).program_range = [base_cases];
%GLS+VDS+Genetic
programs_ranges(3).program_range = [base_cases];

machines_proportion = 0.4;
machines_denom_iterator = 10;
num_trials = 1;

hard = false;
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);

%% Algorithms:
%"Genetic" just k=3 for now
all_alg_names = ["GLS,k=2", "VDS,k=2", "Genetic,v2"];

init_method = "simple";

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, init_method, true};

alg2 = @(input_array, args) vds(input_array, args{:});
alg2_args = {2, init_method, true};

alg3 = @(input_array, args) genetic_alg_v2(input_array, args{:});
alg3_args = {3000, 0.1, "minMaxLinear", 5, "cutover_split", ...
                        "minMaxLinear", "shuffle", ...
                        "top", ...
                        10};

all_algs = {alg1, alg2, alg3};
all_algs_args = {alg1_args, alg2_args, alg3_args};

%% Section 1.d.
%Just testing GLS,k=2
% Desired Output:
%   Graphs:
%       Varying machines
%           Log_10 Time 
%           Relative_error
%           -> Use these to establish using machine proportion of 0.4
%       Varying just num_programs with machine_proportion of 0.4
%           Log_10 Time
%           Relative_error
%   Tables: All to appendix  

save_name = "Experiment-GLS";

alg_subset = 1;
alg_names = all_alg_names(alg_subset);
algs = all_algs(alg_subset);
algs_args = all_algs_args(alg_subset);
programs_range = programs_ranges(1).program_range;

%% Testing - Varying machines proportion
results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials);
%% Analysis - Varying machines proportion
num_programs_subset = 1:length(programs_range);
analyse_varying_m(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator,...
                        alg_names, figure_save_path, save_name);
                    
construct_results_table(results, alg_names, alg_subset, ...
                        programs_range, machines_denom_iterator, ...
                        table_save_path, save_name)
%% Testing - Fixed machines proportion
results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
%% Analysis - Fixed machines proportion
num_programs_subset = 1:length(programs_range);
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                    programs_range, machines_denom_iterator, ...
                    table_save_path, save_name, machines_proportion)
%% Section 2.c
%Testing GLS,k=2 and VDS, k=2
% Desired Output:
%   Graphs:
%       Varying machines
%           Log_10 Time 
%           Ratio to Initiation
%           Ratio to LowerBound
%           -> Use these to establish using machine proportion of 0.4
%       Varying just num_programs with machine_proportion of 0.4
%           Log_10 Time
%           Ratio to Initiation
%           Ratio to LowerBound
%       Varying just num_programs machine_proportion of 0.4 Random Init
%           Log_10 Time
%           Ratio to Initiation
%           Ratio to LowerBound
%   Tables: All to appendix

save_name = "Experiment-GLS-and-VDS-Simple";

alg_subset = 1:2;
alg_names = all_alg_names(alg_subset);
algs = all_algs(alg_subset);
algs_args = all_algs_args(alg_subset);
programs_range = programs_ranges(2).program_range;
num_programs_subset = 1:length(programs_range);

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
save_name = "Experiment-GLS-and-VDS-Random";

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, init_method, true};

alg2 = @(input_array, args) vds(input_array, args{:});
alg2_args = {3, init_method, true};

algs = {alg1, alg2};
algs_args = {alg1_args, alg2_args};
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
%% Section 3. ...
%Testing GLS,k=2, VDS,k=2 and Genetic
% Desired Output:
%   Graphs:
%       Varying machines
%           Log_10 Time 
%           Ratio to Initiation
%           Ratio to LowerBound
%           -> Use these to establish using machine proportion of 0.4
%       Varying just num_programs with machine_proportion of 0.4
%           Log_10 Time
%           Ratio to Initiation
%           Ratio to LowerBound
%       Same again on hard test case
%   Tables: All to appendix

save_name = "Experiment-All-Easy";

alg_subset = 1:3;
alg_names = all_alg_names(alg_subset);
algs = all_algs(alg_subset);
algs_args = all_algs_args(alg_subset);
programs_range = programs_ranges(3).program_range;
num_programs_subset = 1:length(programs_range);

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

save_name = "Experiment-All-Hard";
hard = true;
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);

alg_subset = 1:3;
alg_names = all_alg_names(alg_subset);
algs = all_algs(alg_subset);
algs_args = all_algs_args(alg_subset);
programs_range = programs_ranges(3).program_range;
num_programs_subset = 1:length(programs_range);

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