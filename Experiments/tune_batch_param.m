% A script used to choose the batch size param
%x0 = 2.844*10^5;
%x0 = 5*10^4;
x0 = 2409296;
lb = 10^3;
ub = 10^9;
handler = @(x) tuning_function(x);

%options = optimset('Display','iter','PlotFcns',@optimplotfval);
%best_batch_param = fminsearch(handler, x0, options)


%A global opt method https://au.mathworks.com/help/gads/how-globalsearch-and-multistart-work.html#bsc9eec
% opts = optimoptions(@fmincon,'Algorithm','sqp', 'Display','iter','PlotFcns',@optimplotfval);
% problem = createOptimProblem('fmincon','objective',handler,...
%     'x0',x0,'lb',lb,'ub',ub,'options',opts);
% gs = GlobalSearch;
% [best_batch_param, time] = run(gs,problem)
options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
x = patternsearch(handler,x0,[],[],[],[],lb,ub,[],options)

function cost = tuning_function(batch_div_param)
    global BATCH_DIV_PARAM;
    BATCH_DIV_PARAM = batch_div_param;
    
    %Other fixed params----------------------------------------------------
    hard = false;
    gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);
    programs_range = 1002:1000:4002;
    %programs_range = 5000:10000:45000;
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
