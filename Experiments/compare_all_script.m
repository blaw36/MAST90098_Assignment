rng(1);

%% Testing Parameters
%TODO: Setup up different gen cases
gen_method = @(num_programs, num_machines) generate_ms_instances(num_programs, num_machines);

programs_range = 20:20:100;
machines_denom_iterator = 10;
num_trials = 20;

%% Algorithms:
alg_names = ["GLS,k=2,opt", "VDS,k=2,opt"];

alg1 = @(input_array, args) gls(input_array, args{:});
alg1_args = {2, "simple", true};

alg2 = @(input_array, args) vds(input_array, args{:});
alg2_args = {2, "simple", true};

%Example of how you could test for higher k
%alg3 = @(input_array, args) gls(input_array, args{:});
%alg3_args = {3, "simple", false};

algs = {alg1, alg2};
algs_args = {alg1_args, alg2_args};

%% Testing
results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials);
%% Analysis
alg_subset = [1,2];
num_programs_subset = 1:length(programs_range);
analyse_results(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator,...
                        alg_names);
%Could do this multiple times on different subsets ...