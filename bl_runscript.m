%% runscript.m
% A script which generates instances, and solves the problem using both:
    % GLS (Greedy Local Search)
    % VDS (Variable Depth Search)

% Clear environment
clear;
clc;
% Add everything in the runscript.m directory
addpath(genpath('.\')); 
% Remove 'not_in_use' folder from path. This only has archived code
rmpath('Not_in_use');

%% Set seed
rng(10);

%% Parameters
n = 100; % # jobs
m = 40; % # machines
hard = true;
a = generate_ms_instances(n, m, hard); % Generate makespan input vector
k = 2; % # of exchanges (k-exch)
method = 'Genetic'; % 'VDS' or 'GLS'
k2_opt = true;


%% Initialisation algorithm:
    % 'simple' = Costliest job allocated to machine with most 'capacity'
        % relative to most utilised machine at the time
    % 'random' = Random allocation (random number generated for machine)
    % 'naive' = All jobs placed into machine 1
init_method = "simple";

%% Makespan solver
if strcmp(method,'GLS')
    % GLS
    [outputArray, outputMakespan, num_exchanges] = ...
        gls(a, k, init_method, k2_opt);
elseif strcmp(method,'VDS')
    % VDS
    [outputArray, outputMakespan, num_exchanges, num_transformations] = ...
        vds(a, k, init_method, k2_opt);
elseif strcmp(method,'Genetic')
    % Genetic Algorithm
    % Note that output is based on sorted input vector, where j1, ... , jn
    % is the array of jobs sorted in descending cost order.
    [outputArray, outputMakespan, best_generation, generations] = ...
                genetic_alg_v2(a, 3000, 0.1, ...
                "minMaxLinear", 5, "cutover_split", ...
                "minMaxLinear", "shuffle", ...
                "top", ...
                50)
end

outputMakespan
num_exchanges

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

% Ratio vs Lower bound Makespan
lower_bound = lower_bound_makespan(a);
ratio_vs_lb = outputMakespan/lower_bound

%% Stress tests
results = [];
n_range = [10000,40000];
n_steps = 4;

global BATCH_DIV_PARAM;
BATCH_DIV_PARAM = 5*10^4;

for num_jobs = n_range(1):diff(n_range)/(n_steps-1):n_range(2)
    num_machines = floor(0.4*num_jobs);
    fprintf("Jobs: %d, Machines : %d \n", num_jobs, num_machines);
    a = generate_ms_instances(num_jobs, num_machines, hard);
    startTime = tic;
    if strcmp(method,'GLS')
        % GLS
        [outputArray, outputMakespan, num_exchanges] = ...
                                                gls(a, k, init_method, k2_opt);
    elseif strcmp(method,'VDS')
        % VDS
        [outputArray, outputMakespan, num_exchanges, ...
                            num_transformations] = vds(a, k, init_method, k2_opt);
    end
    t = toc(startTime);
    lower_bound = lower_bound_makespan(a);
    if strcmp(method,'GLS')
        % GLS
        fprintf("Relative Error to LB of %f, %d exchanges,%f time\n", ...
        outputMakespan/lower_bound, num_exchanges, t);
    elseif strcmp(method,'VDS')
        % VDS
        fprintf("Relative Error to LB of %f, %d exchanges, %d transformations,%f time\n", ...
            outputMakespan/lower_bound, num_exchanges, num_transformations, t);
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