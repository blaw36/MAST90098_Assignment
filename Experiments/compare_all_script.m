%This script runs the experiments for 1.d, 2.c and 3.
%Vary init_method for question 2
%Vary hard for question 3

%% Testing Parameters
%Should at least do a hard test here
hard = false;
init_method = "simple";
%init_method = "random";
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);

%Compare algorithms sets the seed based on num_machines*num_programs prior
%to generating all of the test instances. So by making sure that all
%algorithms are using the same programs_range (and same machines
%proportion) we can ensure they are using the same test cases.

%Different algorithms may have significantly different run times so may
%want to have additional larger cases for some algs, can just take these in
%on the end.

base_cases = 50:50:150;
%GLS
programs_ranges(1).program_range = [base_cases, 200:50:300];
%GLS+VDS
programs_ranges(2).program_range = [base_cases];
%GLS+VDS+Genetic
programs_ranges(3).program_range = [base_cases];

machines_proportion = 0.4;
machines_denom_iterator = 5;
num_trials = 1;

%% Algorithms:
%"Genetic" just k=3 for now
all_alg_names = ["GLS,k=2", "VDS,k=2", "GLS,k=3"];

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, init_method, true};

alg2 = @(input_array, args) vds(input_array, args{:});
alg2_args = {2, init_method, true};

alg3 = @(input_array, args) gls(input_array, args{:});
alg3_args = {3, init_method, false};

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

figure_save_path = "Figures/experiment_GLS";
table_save_path = "Tables/experiment_GLS";

alg_subset = 1;
alg_names = all_alg_names(alg_subset);
algs = all_algs(alg_subset);
algs_args = all_algs_args(alg_subset);
programs_range = programs_ranges(1).program_range;
% 
% %% Testing - Varying machines proportion
% results = compare_algorithms(algs, algs_args, gen_method, ...
%                             programs_range, machines_denom_iterator, ...
%                             num_trials);
% %% Analysis - Varying machines proportion
% num_programs_subset = 1:length(programs_range);
% % analyse_varying_m(results, alg_subset, num_programs_subset, ...
% %                         programs_range, machines_denom_iterator,...
% %                         alg_names, figure_save_path);
%                     
% construct_results_table(results, alg_names, alg_subset, num_programs_subset, ...
%                         programs_range, machines_denom_iterator, table_save_path)                     
% 
% %% Testing - Fixed machines proportion
% results = compare_algorithms(algs, algs_args, gen_method, ...
%                             programs_range, machines_denom_iterator, ...
%                             num_trials, machines_proportion);
% %% Analysis - Fixed machines proportion
% num_programs_subset = 1:length(programs_range);
% analyse_varying_n(results, alg_subset, ...
%                          programs_range, machines_proportion,...
%                          alg_names, figure_save_path);
                     
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

figure_save_path = "Figures/experiment_GLS_and_VDS";
table_save_path = "Tables/experiment_GLS_and_VDS";

alg_subset = 1:2;
alg_names = all_alg_names(alg_subset);
algs = all_algs(alg_subset);
algs_args = all_algs_args(alg_subset);
programs_range = programs_ranges(2).program_range;

%% Testing - Varying machines proportion
results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials);
construct_results_table(results, alg_names, alg_subset, ...
programs_range, machines_denom_iterator, table_save_path)    
return
%% Analysis - Varying machines proportion
num_programs_subset = 1:length(programs_range);
analyse_varying_m(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator,...
                        alg_names, figure_save_path);
%% Testing - Fixed machines proportion
results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
%% Analysis - Fixed machines proportion
num_programs_subset = 1:length(programs_range);
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names, figure_save_path);
                     
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

figure_save_path = "Figures/experiment_all";

alg_subset = 1:3;
alg_names = all_alg_names(alg_subset);
algs = all_algs(alg_subset);
algs_args = all_algs_args(alg_subset);
programs_range = programs_ranges(3).program_range;