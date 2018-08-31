%% ISSUES:
%%% Put in some case for when # machines = 1;
    % should be done with 'naive' initialisation method
    % there are some issues with this at the moment (# of machines looks
    % like 1)
%% SCRIPT
clear;
clc;

rng(10)

n = 10; % # jobs
m = 5; % # machines
a = generate_ms_instances(n, m);

% Initialisation algorithm:
    % 'simple' = Costliest job allocated to machine with most 'capacity'
        % relative to most utilised machine at the time
    % 'random' = Random allocation (random number generated for machine)
    % 'naive' = All jobs placed into machine 1
init_method = "simple";
k = 2; % # of exchanges (k-exch)

[outputArray, outputMakespan, num_exchanges] = ...
    ms_solver_gls_v2(a, k, init_method)

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

% outputMakespan
% lower_bound = lower_bound_makespan(a)
% return

% % Stress testing
results = [];
machine_range = [2500,10000];
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

