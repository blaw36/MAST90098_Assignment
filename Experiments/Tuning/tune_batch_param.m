% A script used to give a rough estimate of the batch size param.
% This is pretty rough for a number of reasons,
% 1. check = (num_new_valid*max(M(L)))^2/BATCH_DIV_PARAM;
    % is not a perfect way to estimate the size of the problem
% 2. check determines two things batch size and when to parallelalise, in a
    % perfect world this would be done with two params
% 3. Exact value of tuned parameter will depend on the computer running,
    % the script, maybe even the version of matlab (if there are 
    % alterations to parallel computing
%%

%x0 was found on last run
x0 = 6.4*10^7;
lb = 10^5;
ub = 10^12;
handler = @(x) tuning_function(x);

options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
x = patternsearch(handler,x0,[],[],[],[],lb,ub,[],options)

function cost = tuning_function(batch_div_param)
    global BATCH_DIV_PARAM;
    BATCH_DIV_PARAM = batch_div_param;
    
    %Other fixed params----------------------------------------------------
    hard = false;
    gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);
    %Want to look over a collection of instances that ideally would be
    %solved with a mixture of parallel and non-parallel, but don't want the
    %problems to be too hard ie take too long so can more quickly optimize.
    programs_range = 2000:2000:6000;
    num_trials = 2;

    alg1 = @(input_array, args) vds(input_array, args{:});
    alg1_args = {2, "simple", true};
    algs = {alg1};
    algs_args = {alg1_args};
    
    machines_denom_iterator = 1;
    machines_proportion = 0.4;
    %Other fixed params----------------------------------------------------
    
    results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
    % Set Cost to be the sum of average times across the program range
    % Probably Not perfect, but allows us to be in the ballpark
    %1 alg, 1 machine prop, 1 metric (time)
    cost = sum(results(1,:,1,1));
end
