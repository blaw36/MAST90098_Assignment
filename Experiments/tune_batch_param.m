% A script used to choose the batch size param
x0 = 2.15*10^6;
options = optimset('Display','iter','PlotFcns',@optimplotfval);
handler = @(x) tuning_function(x);
best_batch_param = fminsearch(handler, x0, options)

function cost = tuning_function(batch_div_param)
    global BATCH_DIV_PARAM;
    BATCH_DIV_PARAM = batch_div_param;
    
    %Other fixed params----------------------------------------------------
    gen_method = @(num_programs, num_machines) generate_ms_instances(num_programs, num_machines);
    programs_range = 100:100:400;
    num_trials = 3;

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
