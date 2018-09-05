%% Generating instances
clear;
clc;

simple_res = zeros(100,5);
random_res = zeros(100,5);
naive_res = zeros(100,5);

row = 1;

for i = 10:10:100
    
    for j = 1:10
        
    n = i;% # jobs
    m = 5; % # machines
    a = generate_ms_instances(n, m);
    k = 1; % # of exchanges (k-exch)

    % Initialisation algorithm:
        % 'simple' = Costliest job allocated to machine with most 'capacity'
            % relative to most utilised machine at the time
        % 'random' = Random allocation (random number generated for machine)
        % 'naive' = All jobs placed into machine 1
    init_method = "simple";
    [outputArray, outputMakespan, num_exchanges, ...
        time_taken, nbour_taken] = ms_solver_gls_v1(a, k, init_method);
    simple_res(row,:) = [n, outputMakespan, num_exchanges, time_taken, nbour_taken];
    
    init_method = "random";
    [outputArray, outputMakespan, num_exchanges, ...
        time_taken, nbour_taken] = ms_solver_gls_v1(a, k, init_method);
    random_res(row,:) = [n, outputMakespan, num_exchanges, time_taken, nbour_taken];
    
    init_method = "naive";
    [outputArray, outputMakespan, num_exchanges, ...
        time_taken, nbour_taken] = ms_solver_gls_v1(a, k, init_method);
    naive_res(row,:) = [n, outputMakespan, num_exchanges, time_taken, nbour_taken];
    
    row = row + 1;
    
    end
end

simple_res_2 = [unique(simple_res(:,1)), grpstats(simple_res(:,2:5),simple_res(:,1))];
random_res_2 = [unique(random_res(:,1)), grpstats(random_res(:,2:5),random_res(:,1))];
naive_res_2 = [unique(naive_res(:,1)), grpstats(naive_res(:,2:5),naive_res(:,1))];

linspace(1,1000,100)
plot(simple_res_2(:,1),simple_res_2(:,2),...
    random_res_2(:,1),random_res_2(:,2),...
    naive_res_2(:,1),naive_res_2(:,2))
title('Avg makespan (of 10 runs) vs # of jobs')
xlabel('# of jobs')
ylabel('Makespan')
legend('simple','random','naive')

plot(simple_res_2(:,1),simple_res_2(:,3),...
    random_res_2(:,1),random_res_2(:,3),...
    naive_res_2(:,1),naive_res_2(:,3))
title('Avg # exchanges (of 10 runs) vs # of jobs')
xlabel('# of jobs')
ylabel('# exchanges')
legend('simple','random','naive')

plot(simple_res_2(:,1),simple_res_2(:,4),...
    random_res_2(:,1),random_res_2(:,4),...
    naive_res_2(:,1),naive_res_2(:,4))
title('Avg runtime (of 10 runs) vs # of jobs')
xlabel('# of jobs')
ylabel('runtime')
legend('simple','random','naive')