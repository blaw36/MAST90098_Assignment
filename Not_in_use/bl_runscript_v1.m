%% ISSUES:
%%% Put in some case for when # machines = 1;
    % should be done with 'naive' initialisation method
    % there are some issues with this at the moment (# of machines looks
    % like 1)
%% SCRIPT
clear;
clc;

n = 1000; % # jobs
m = 500; % # machines
a = generate_ms_instances(n, m);

% Initialisation algorithm:
    % 'simple' = Costliest job allocated to machine with most 'capacity'
        % relative to most utilised machine at the time
    % 'random' = Random allocation (random number generated for machine)
    % 'naive' = All jobs placed into machine 1
init_method = "random";
k = 1; % # of exchanges (k-exch)

[outputArray, outputMakespan, num_exchanges, ...
    time_taken, time_gen_nbours, time_eval_nbours] = ms_solver_gls_v1(a, k, init_method);

% Sort the output for presentation
[sorted_col, sorting_idx] = sort(outputArray(:,2));
sorted_output = outputArray(sorting_idx,:);
% Cost per machine
cost_pm = [(1:m)' accumarray(outputArray(:,2),outputArray(:,1))];
% Bar plot
bar_plot = draw_bar_plot(sorted_output, m);
title(['Makespan: ' num2str(outputMakespan)])
xlabel('Machine #') % x-axis label
ylabel('Job cost') % y-axis label

% % Stress testing
% results = [];
% for i = 2:400
%     fprintf("Machines: %d \n", i);
%     a = generate_ms_instances(10*i,i);
%     [outputArray, outputMakespan, num_exchanges, time_taken] = ms_solver_gls_v1(a);
%     results = [results ; [i 10*i time_taken]];
% end

