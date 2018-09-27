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


%% Testing Parameters
hard = false;
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);

programs_range = 5000:5000:15000;
machines_denom_iterator = 5;
num_trials = 3;

%% Algorithms:
alg_names = ["GLS,k=2,optimised", "GLS,k=2"];

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, "simple", true};

alg2 = @(input_array, args) gls(input_array, args{:});
alg2_args = {2, "simple", false};

algs = {alg1, alg2};
algs_args = {alg1_args, alg2_args};

%% Testing - Varying machines proportion
results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials);
%% Analysis - Varying machines proportion
alg_subset = 1:length(algs);
num_programs_subset = 1:length(programs_range);
analyse_varying_m(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator,...
                        alg_names);
%% Testing - Fixed machines proportion
machines_proportion = 0.4;
programs_range = 5000:5000:25000;

results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
%% Analysis - Fixed machines proportion
alg_subset = 1:length(algs);
num_programs_subset = 1:length(programs_range);
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names);