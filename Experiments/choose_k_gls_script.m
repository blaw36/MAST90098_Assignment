%% Testing Parameters
%TODO: Setup up different gen cases
gen_method = @(num_programs, num_machines) generate_ms_instances(num_programs, num_machines);

%There are 5 different colored lines by default and 30/10 = 3
% -> reason for initial params, can alter later.
programs_range = 30:30:150;
machines_denom_iterator = 10;
num_trials = 20;

%Set false to disable and use iterator as above.
machines_proportion = false;
machines_proportion = 0.4;

%% Algorithms:
alg_names = ["GLS,k=2", "GLS,k=3"];

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, "simple", false};

alg2 = @(input_array, args) gls(input_array, args{:});
alg2_args = {3, "simple", false};

% alg3 = @(input_array, args) gls(input_array, args{:});
% alg3_args = {4, "simple", false};

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
results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
%% Analysis - Fixed machines proportion
alg_subset = 1:length(algs);
num_programs_subset = 1:length(programs_range);
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names);