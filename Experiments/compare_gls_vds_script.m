%A script to compare the performance of the GLS and VDS solvers

%% Testing Parameters
hard = false;
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);
programs_range = 50:50:150;
machines_denom_iterator = 5;
num_trials = 3;

%% Algorithms:
%Note both are optimized
alg_names = ["GLS,k=2", "VDS,k=2"];

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, "simple", true};

alg2 = @(input_array, args) vds(input_array, args{:});
alg2_args = {2, "simple", true};

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