%This script runs pairwise comparisons between the GA to justify choice of
%free parameters for section 3.
figure_save_path = "Figures/";
table_save_path = "Tables/";

%% Testing Parameters
% For GA, two types of tests.
    % 1) Testing behaviour of parameters in new operations.
        % a) Rate of convergence (limit pop'n to 20) - or glean performance
        % after 20 gen
        % b) Optimality of outcomes (limit pop'n to 200)
    % 2) Testing algos with new functionality vs previous

%GLS+VDS+Genetic
base_cases_machines_vary = [100:100:300];

machines_proportion = 0.4;
machines_denom_iterator = 10;
num_trials = 1;

hard = false;
gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);

%% Pairwise GA tests            
            
            
%% Algorithms:
all_alg_names = ["GLS,k=2", "VDS,k=2", "Genetic,v2"];

alg3 = @(input_array, args) genetic_alg_v2(input_array, args{:});
alg3_args = {3000, 0.1, "minMaxLinear", 5, "cutover_split", ...
                        "minMaxLinear", "shuffle", ...
                        "top", ...
                        10};

all_algs = {alg1, alg2, alg3};
all_algs_args = {alg1_args, alg2_args, alg3_args};

%% Section 1.d.
save_name = "Experiment-GLS";

alg_subset = 1;
alg_names = all_alg_names(alg_subset);
algs = all_algs(alg_subset);
algs_args = all_algs_args(alg_subset);
programs_range = gls_extended_machine_vary;

%Find the cases to be plotted
num_programs_subset = [find(programs_range==100), ...
                        find(programs_range==500), ...
                        find(programs_range==1000), ...
                        find(programs_range==5000), ...
                        find(programs_range==10000), ...
                        find(programs_range==100000)];

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
%all of the range
programs_range = gls_extended_fixed_prop;
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
%% Section 2.c
save_name = "Experiment-GLS-and-VDS-Simple";

alg_subset = 1:2;
alg_names = all_alg_names(alg_subset);
algs = all_algs(alg_subset);
algs_args = all_algs_args(alg_subset);
programs_range = base_cases_machines_vary;

num_programs_subset = [find(programs_range==50), ...
                        find(programs_range==500), ...
                        find(programs_range==1000)];

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