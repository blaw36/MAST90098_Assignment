%% test_algorithm.m
% Tests the algorithm for the given arguments across a variety of instances
%% Input:
    % alg: a function handle of the alg to be test,
        % the handle must be of the form 
        % alg = @(input_array, args) f(input_array, args{:}
    % alg_args: the other args to be passed excluding input array
    % gen_method: a handle used to initialise the input array each trial
        % the handle must be of the form
        % gen_method = @(num_programs, num_machines) ...
        %                           gen_method(num_programs, num_machines);
    % num_programs: the number of programs for these trials
    % num_machines: the number of machines for these trials
    % num_trials: the number of trials to be done on the alg.
%% Output:
    % results: a vector of the average [time, makespan, relative_error]
%%

function results = test_algorithm(alg, alg_args, ...
                        gen_method, num_programs, num_machines, num_trials)
    total_time = 0;
    total_makespan = 0;
    total_rel_error = 0;

    for i = 1:num_trials
        a = gen_method(num_programs, num_machines);
        %Run trial
        startTime = tic;
        %TODO: Check format consistent with genetic, maybe refactor so makespan
        %first
        [~,makespan] = alg(a, alg_args);
        total_time = total_time + toc(startTime);
        total_makespan = total_makespan + makespan;
        lb = lower_bound_makespan(a);
        total_rel_error = total_rel_error + makespan/lb;
    end
    
    %Get the average results accross the trials
    results = 1/num_trials * [total_time, total_makespan, total_rel_error];
end