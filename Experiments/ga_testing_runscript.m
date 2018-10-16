%% ga_testing_runscript.m
% A script for performing rough experiments on the genetic algorithm.
%%

% Clear environment
clear;
clc;
% Add everything in the runscript.m directory
addpath(genpath('.\'));
% Remove 'not_in_use' folder from path. This only has archived code
rmpath('Not_in_use');

%% Set seed
rng(10);

%% Problem Parameters
n = 1000; % # jobs
m = 400; % # machines
hard = false;
a = generate_ms_instances(n, m, hard); % Generate makespan input vector
%% GLS and VDS parameters
k = 2; % # of exchanges (k-exch)
k2_opt = true;
init_method_GLS = "simple";
init_method_VDS = "random";
%%

profile on
[outputMakespan, time_taken, init_makespan, outputArray, ...
    best_gen_num, generations, diags_array]...
            = genetic_alg_outer(a, ...
                 100, "init_rand_greedy", 0.02, 0.6, 20, ... %inits
                "neg_exp", 2, 1, ... %selection
                1, "c_over_2_all", ...
                1/2, 1/3, 0.1, ... %crossover
                "all_genes_rndom_shuffle", 0.4, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                5, 200, ...  %termination
                true, ... %verbose/diagnose
                true, 4); %parallelisation

profile off
profile viewer

outputMakespan
time_taken

% diags
% Columns: Generation#, Best makespan in gen, Best makespan,
% AvgFit, NumParentsSurvive, NumChildrenSurvive

% plots
plot(diags_array(:,1),diags_array(:,2), ... % Best makespan in gen
    diags_array(:,1),diags_array(:,3), ... % Best makespan overall
    diags_array(:,1),diags_array(:,4) ... % Avg makespan
    )
title(['Makespan: ' num2str(outputMakespan)])
xlabel('Generation #') % x-axis label
ylabel('Job cost') % y-axis label
legend('Best makespan in gen','Best makespan overall','Avg makespan')

% min and max m/span
plot(diags_array(:,1),diags_array(:,5), ... % Best makespan overall
    diags_array(:,1),diags_array(:,6) ... % Avg makespan
    )
title(['Makespan: ' num2str(outputMakespan)])
xlabel('Generation #') % x-axis label
ylabel('Job cost') % y-axis label
legend('Min makespan in gen','Max makespan in gen')

% parents survived vs children survived
survival_pcts = [diags_array(:,1), ...
    diags_array(:,7)./(diags_array(:,7)+diags_array(:,8)), ...
    diags_array(:,8)./(diags_array(:,7)+diags_array(:,8))];
p = bar(survival_pcts(:,1), survival_pcts(:,2:3), 'stacked')
title(['Makespan: ' num2str(outputMakespan)])
xlabel('Generation #') % x-axis label
ylabel('Survival %') % y-axis label
legend(p, {'parent surv','child surv'}, 'Location','Best')

return

%% Batch experiments
results = [];
diagnostics = {};
machine_prop = 0.4;
for n = [300, 600]
    m = floor(n*machine_prop);
    fprintf("Num jobs: %d, num_machines : %d\n", n,m);
    for j = 1:10
        % Set the seed so that the same test cases are repeated between 
        % script runs
        rng(mod(m*n + j,2^32));
        fprintf("\n");
        a = generate_ms_instances(n, m, hard);
        
        [outputMakespan, time_taken, init_makespan, outputArray, ...
            best_gen_num, generations, diags_array]...
            = genetic_alg_outer(a, ...
                100, "init_rand_greedy", 0.0825, 0.85, 20, ... %inits
                "neg_exp", 2, 1, ... %selection
                1, "c_over_2_all", ...
                0.75, 1/3, 0.1, ... %crossover
                "all_genes_rndom_shuffle", 0.275, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                5, 1000, ...  %termination
                false, ... %verbose/diagnose
                true, 4); %parallelisation
            
        fprintf("Genetic: %d, %f\n", outputMakespan, time_taken)
        
        [outputMakespan_b, time_taken_b, init_makespan_b, outputArray, ...
            best_gen_num, generations_b, diags_array]...
            = genetic_alg_outer(a, ...
                 100, "init_rand_greedy", 0.27, 0.85, 20, ... %inits
                "neg_exp", 7, 0.5, ... %selection
                0.5, "c_over_2_all", ...
                1, 1/3, 0.1, ... %crossover
                "all_genes_rndom_shuffle", 0.65, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                10, 200, ...  %termination
                false, ... %verbose/diagnose
                true, 4); %parallelisation            
        
        fprintf("Genetic 2: %d, %f\n", outputMakespan_b, time_taken_b)
        
        [outputMakespan_c, time_taken_c, init_makespan_c, outputArray, ...
            best_gen_num, generations_c, diags_array]...
            = genetic_alg_outer(a, ...
                 598, "init_rand_greedy", 0.27, 0.85, 20, ... %inits
                "neg_exp", 7, 0.5, ... %selection
                4, "c_over_2_all", ...
                1, 1/3, 0.1, ... %crossover
                "all_genes_rndom_shuffle", 0.65, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                12, 204, ...  %termination
                false, ... %verbose/diagnose
                true, 4); %parallelisation            
        
        fprintf("Genetic 3: %d, %f\n", outputMakespan_c, time_taken_c)        
                
        [outputMakespan_gls, time_taken_gls, init_makespan_gls, outputArray, num_exchanges] = ...
            gls(a, k, init_method_GLS, true);
        fprintf("gls: %d, %f\n", outputMakespan_gls, time_taken_gls)
        
        [outputMakespan_vds, time_taken_vds, init_makespan_vds, outputArray, num_exchanges, ...
            num_transformations] = vds(a, k, init_method_VDS, true);
        fprintf("vds: %d, %f\n", outputMakespan_vds, time_taken_vds)
        
        lower_bound = lower_bound_makespan(a);
        fprintf("lb: %2.4f\n", lower_bound)
        
        results = [results; [...
            outputMakespan, init_makespan, time_taken, generations, ...
            outputMakespan_b, init_makespan_b, time_taken_b, generations_b, ...
            outputMakespan_c, init_makespan_c, time_taken_c, generations_c, ...
            n, m, ...
            outputMakespan_vds, init_makespan_vds, time_taken_vds, ...
            lower_bound]];
    end
end