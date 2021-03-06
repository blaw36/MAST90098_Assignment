%% runscript.m
% A script which generates examples instances, and solves them using
    % GLS (Greedy Local Search)
    % VDS (Variable Depth Search)
    % Genetic (A Genetic Algorithm)
% A graphic is then produced which provides a visualisation of the
% resulting allocation of jobs to machines.

%% Note:
%If you want to test a particular test instance, scroll down to 
%Problem instance creation, and enter you own test case, alternatively can
%just call the algorithms from an external script.

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

%% Test Case Parameters
n = 100; % # jobs
m = 40; % # machines
hard = false;
%% Problem instance creation,
%replace a with a custom input vector if you wish to test that instead eg,
%a = [1,4,2,5,2,7,3,6,2,5,2,2,5,7,2,6,8,4];
a = generate_ms_instances(n, m, hard); % Generate makespan input vector

%% Parameters shared by Multile Algorithms
k = 2; % # of exchanges (k-exch)
k2_opt = true;
method = 'Genetic'; % 'VDS', 'GLS' or 'Genetic'

%% Initialisation algorithm:
    % 'simple' = Costliest job allocated to machine with most 'capacity'
        % relative to most utilised machine at the time
    % 'random' = Random allocation (random number generated for machine)
    % 'naive' = All jobs placed into machine 1
init_method = "simple";

%% Makespan solver
if strcmp(method,'GLS')
    % GLS
    [outputMakespan, time_taken, init_makespan,...
                    outputArray, num_exchanges] = ...
                                            gls(a, k, init_method, k2_opt);
elseif strcmp(method,'VDS')
    % VDS
    [outputMakespan, time_taken, init_makespan,...
                    outputArray, num_exchanges, ...
                    num_transformations] = vds(a, k, init_method, k2_opt);
elseif strcmp(method,'Genetic')
    % Genetic Algorithm
    [outputMakespan, time_taken, init_makespan, outputArray, ...
            best_gen_num, generations, diags_array]...
            = genetic_alg_outer(a, ...
                 100, "init_rand_greedy", 0.27, 0.85, 20, ... %inits
                "neg_exp", 7, 0.49, ... %selection
                0.5, "c_over_2_all", ...
                1, 1/3, 0.1, ... %crossover
                "all_genes_rndom_shuffle", 0.65, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                5, 1000, ...  %termination
                true, ... %verbose/diagnose
                true, 4); %parallelisation
end


% Ratio vs Lower bound Makespan
lower_bound = lower_bound_makespan(a);

ratio_vs_lb = outputMakespan/lower_bound
outputMakespan
time_taken

%% Comment out return to run additional tests and produce graphics
return

%% Graphing and analysis
% Sort the output for presentation
[sorted_col, sorting_idx] = sort(outputArray(:,2));
sorted_output = outputArray(sorting_idx,:);

% Cost per machine
%NOTE: This will throw errors if a machine hasn't been assigned anything
%this can occur if 2 equal max cost machines and only way to improve is to
% to move a prog to the empty (which doesn't max cost)
cost_pm = [(1:m)' accumarray(outputArray(:,2),outputArray(:,1))];

% Bar plot
bar_plot = draw_bar_plot(sorted_output, m);
title(['Makespan: ' num2str(outputMakespan)])
xlabel('Machine #') % x-axis label
ylabel('Job cost') % y-axis label

%% Additional tests
results = [];
n_range = [200,1000];
n_steps = 2;

for num_jobs = n_range(1):diff(n_range)/(n_steps-1):n_range(2)
    num_machines = floor(0.4*num_jobs);
    fprintf("Jobs: %d, Machines : %d \n", num_jobs, num_machines);
    a = generate_ms_instances(num_jobs, num_machines, hard);
    if strcmp(method,'GLS')
        % GLS
        [outputMakespan, time_taken, init_makespan, outputArray, num_exchanges] = ...
            gls(a, k, init_method, k2_opt);
    elseif strcmp(method,'VDS')
        % VDS
        [outputMakespan, time_taken, init_makespan, outputArray, num_exchanges, ...
            num_transformations] = vds(a, k, init_method, k2_opt);
    elseif strcmp(method,'Genetic')
        % Genetic Algorithm
        [outputMakespan, time_taken, init_makespan, outputArray, ...
            best_gen_num, generations, diags_array]...
            = genetic_alg_outer(a, ...
                100, "init_rand_greedy", 0.27, 0.85, 20, ... %inits
                "neg_exp", 7, 0.49, ... %selection
                0.5, "c_over_2_all", ...
                1, 1/3, 0.1, ... %crossover
                "all_genes_rndom_shuffle", 0.65, ... %mutation
                "top_and_randsamp", 0.8, ... %culling
                5, 1000, ...  %termination
                false, ... %verbose/diagnose
                true, 4); %parallelisation
    end 
    lower_bound = lower_bound_makespan(a);
    if strcmp(method,'GLS')
        fprintf("Relative Error to LB of %f, %d exchanges,%f time\n", ...
        outputMakespan/lower_bound, num_exchanges, time_taken);
    elseif strcmp(method,'VDS')
        fprintf("Relative Error to LB of %f, %d exchanges, %d transformations,%f time\n", ...
            outputMakespan/lower_bound, num_exchanges,...
                                        num_transformations, time_taken);
    elseif strcmp(method,'Genetic')
        fprintf("Relative Error to LB of %f, %d generations, %f time\n", ...
                outputMakespan/lower_bound, generations, time_taken);
    end
    
    % Sort the output for presentation
    [sorted_col, sorting_idx] = sort(outputArray(:,2));
    sorted_output = outputArray(sorting_idx,:);
    % Cost per machine
    %NOTE: This will throw errors if a machine hasn't been assigned 
    % anything this can occur if 2 equal max cost machines and only way to 
    % improve is to move a prog to the empty (which doesn't max cost)
    cost_pm = [(1:num_machines)' accumarray(outputArray(:,2),outputArray(:,1))];
    % Bar plot
    bar_plot = draw_bar_plot(sorted_output, num_machines);
    title(['Makespan: ' num2str(outputMakespan)])
    xlabel('Machine #') % x-axis label
    ylabel('Job cost') % y-axis label
end