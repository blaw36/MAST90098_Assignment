clear;
clc;

a = generate_ms_instances(1000,900);
[outputArray, outputMakespan, num_exchanges, time_taken] = ms_solver_gls_v1(a);

% % Stress testing
% results = [];
% for i = 2:400
%     fprintf("Machines: %d \n", i);
%     a = generate_ms_instances(10*i,i);
%     [outputArray, outputMakespan, num_exchanges, time_taken] = ms_solver_gls_v1(a);
%     results = [results ; [i 10*i time_taken]];
% end

%%% Put in some case for when # machines = 1;