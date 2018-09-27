% A script used to experimentally justify our choice of k for GLS.
% Vary over init method as well
% Desired Output:
%   Graphs:
%       Varying machines
%           Log_10 Time 
%           Relative_error
%           -> Use these to establish using machine proportion of 0.4
%       Varying just num_programs with machine_proportion of 0.4
%           vary_init_method
%               Log_10 Time 
%               Relative_error
%               Makespan relative to init
%       -> Use these all to establish choice of k
%   Tables: All to appendix    

%% Testing Parameters
hard = false;
init_method = "simple";
%init_method = "random";
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);
%30/10 = 3
programs_range = 50:50:150;
machines_denom_iterator = 10;
num_trials = 3;

%% Algorithms:
alg_names = ["GLS,k=2", "GLS,k=3"];

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, init_method, false};

alg2 = @(input_array, args) gls(input_array, args{:});
alg2_args = {3, init_method, false};

% alg3 = @(input_array, args) gls(input_array, args{:});
% alg3_args = {4, init_method, false};

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
programs_range = 50:50:250;

results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
%% Analysis - Fixed machines proportion
alg_subset = 1:length(algs);
num_programs_subset = 1:length(programs_range);
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names);