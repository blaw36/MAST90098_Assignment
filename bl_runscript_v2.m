%% SCRIPT
clear;
clc;
%% Set seed
rng(10)
%% Parameters
n = 100; % # jobs
m = 20; % # machines
a = generate_ms_instances(n, m);
k = 2; % # of exchanges (k-exch)

%% Initialisation algorithm:
    % 'simple' = Costliest job allocated to machine with most 'capacity'
        % relative to most utilised machine at the time
    % 'random' = Random allocation (random number generated for machine)
    % 'naive' = All jobs placed into machine 1
init_method = "random";

%% Makespan solver
[outputArray, outputMakespan, num_exchanges] = ...
    ms_solver_gls_v2(a, k, init_method);

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
% outputMakespan
lower_bound = lower_bound_makespan(a);
ratio_vs_lb = outputMakespan/lower_bound
% return

%% Stress tests
results = [];
machine_range = [200,800];
machine_steps = 3;
for i = machine_range(1):diff(machine_range)/machine_steps:machine_range(2)
    fprintf("Machines: %d  : ", i);
    a = generate_ms_instances(10*i,i);
    startTime = tic;
    [outputArray, outputMakespan, num_exchanges] = ...
        ms_solver_gls_v2(a, k, init_method);
    t = toc(startTime);
    lower_bound = lower_bound_makespan(a);
    fprintf("Relative Error to LB of %f, %d exchanges, %f time\n", ...
        outputMakespan/lower_bound, num_exchanges, t);
    
    % Sort the output for presentation
    [sorted_col, sorting_idx] = sort(outputArray(:,2));
    sorted_output = outputArray(sorting_idx,:);
    % Cost per machine
    %NOTE: This will throw errors if a machine hasn't been assigned anything
    %this can occur if 2 equal max cost machines and only way to improve is to
    % to move a prog to the empty (which doesn't max cost)
    cost_pm = [(1:i)' accumarray(outputArray(:,2),outputArray(:,1))];
    % Bar plot
    bar_plot = draw_bar_plot(sorted_output, i);
    title(['Makespan: ' num2str(outputMakespan)])
    xlabel('Machine #') % x-axis label
    ylabel('Job cost') % y-axis label
    
end

