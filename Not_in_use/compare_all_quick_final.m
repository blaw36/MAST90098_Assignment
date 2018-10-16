%Extracts and processes the results saved at the end of compare all script.

base_cases_machines_vary = [50:10:90,100:100:500];
base_cases_fixed_prop = [50:10:90,100:100:500];
save_name = "Experiment-All-Easy";
alg_names = ["GLS,k=2,simple", "VDS,k=2,random", "Genetic"];
all_alg_names = alg_names;

%% Testing - Varying machines proportion
programs_range = base_cases_machines_vary;
results = r1;
%% Analysis - Varying machines proportion
analyse_varying_m(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator,...
                        alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                        programs_range, machines_denom_iterator, ...
                        table_save_path, save_name)
%% Testing - Fixed machines proportion
%all of the range
programs_range = base_cases_fixed_prop;
num_programs_subset = 1:length(programs_range);

%Extract from the reulsts accross all machine proportions, the proportion
%of 0.4, aka the 4th, 
% (results is num_algs x num_programs x num_proprtions x num_metrics)
results = r1(:,:,4,:);

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

%% Testing - Varying machines proportion
programs_range = base_cases_machines_vary;
results = r3;
%% Analysis - Varying machines proportion
num_programs_subset = [find(programs_range==50), ...
                        find(programs_range==500)];
analyse_varying_m(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator,...
                        alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                        programs_range, machines_denom_iterator, ...
                        table_save_path, save_name)
% %% Testing - Fixed machines proportion
programs_range = base_cases_fixed_prop;
num_programs_subset = 1:length(programs_range);

%Extract from the reulsts accross all machine proportions, the proportion
%of 0.4, aka the 4th, 
% (results is num_algs x num_programs x num_proprtions x num_metrics)
results = r3(:,:,4,:);
%% Analysis - Fixed machines proportion
analyse_varying_n(results, alg_subset, num_programs_subset, ...
                         programs_range, machines_proportion,...
                         alg_names, figure_save_path, save_name);
construct_results_table(results, alg_names, alg_subset, ...
                    programs_range, machines_denom_iterator, ...
                    table_save_path, save_name, machines_proportion)
                