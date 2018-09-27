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
    total_rel_init_ratio = 0;
    total_rel_lb_ratio = 0;
    
    %Generate all the instances first, this allows a seed to be set just
    %before calling this function for consistent test cases.
    %Has to be generated before any of the algs are called incase they use
    %random methods which could mess with the seed.
    gen_instances(num_trials).a = [];
    for i = 1:num_trials
        gen_instances(i).a = gen_method(num_programs, num_machines);
    end
    for i = 1:num_trials
        %Retrieve instance
        a = gen_instances(i).a;
        %Run tria
        [makespan, time_taken, init_makespan] = alg(a, alg_args);
        total_time = total_time + time_taken;
        total_rel_init_ratio = total_rel_init_ratio + makespan/init_makespan;
        lb = lower_bound_makespan(a);
        total_rel_lb_ratio = total_rel_lb_ratio + makespan/lb;
    end
    
    %Get the average results accross the trials
    results = 1/num_trials * [total_time, total_rel_init_ratio, total_rel_lb_ratio];
end