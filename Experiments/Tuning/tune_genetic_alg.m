% A script used to tune the parameters of the genetic alg for given fixed
% sub algorithms
%%

%x0

%These were found on last run, terminated the search early so no means a
%complete search of the
x0= [100, ... %pop_size
    0.27, ... %simple_prop
    0.85, ... %init_prop_random
    7, ... %alpha_parent
    0.5, ... %alpha_mutation
    0.5, ... %parent_ratio
    1, ... %least_fit_proportion
    1/3, ... %most_fit_proportion
    0.1, ... %parent_switch_prob
    0.65, ... %mutation proportion
    0.8, ... %keep_prop
    4, ... %num_inner
    10, ... %num gens no improve
    200 ... % num gens max
];
%Upper and lower bounds for each param

lb = [10, ... %pop_size
    0.005, ... %simple_prop
    0.1, ... %init_prop_random
    0.01, ... %alpha_parent
    0.01, ... %alpha_mutation
    0.5, ... %parent_ratio
    0.1, ... %least_fit_proportion
    0.1, ... %most_fit_proportion
    0.05, ... %parent_switch_prob
    0.05, ... %mutation proportion
    0.5, ... %keep_prop
    2, ... %num_inner;
    5, ... % num gens no improve
    100 ... % num gens max
    ];
ub = [1000, ... %pop_size
    0.5, ... %simple_prop
    0.9, ... %init_prop_random
    50, ... %alpha_parent
    50, ... %alpha_mutation
    50, ... %parent_ratio
    1, ... %least_fit_proportion
    1, ... %most_fit_proportion
    0.95, ... %parent_switch_prob
    0.8, ... %mutation proportion
    0.95, ... %keep_prop
    10, ... %num_inner
    100, ... % num gens no improve
    1000 ... % num gens max
];

handler = @(x) tuning_function(x);

options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
x = patternsearch(handler,x0,[],[],[],[],lb,ub,[],options)

function cost = tuning_function(x)

    %Other fixed params----------------------------------------------------
    hard = false;
    gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);
    
    %Define a suitable range
    programs_range = 100:200:700;
    num_trials = 5;
    %Just do it on a fixed proportion
    machines_denom_iterator = 1;
    machines_proportion = 0.4;

    alg1 = @(input_array, args) genetic_alg_outer(input_array, args{:});
    
    %Process x and the function args above into a suitable format
    init_alg = "init_rand_greedy";
    selection_method = "neg_exp";
    cross_over_method = "c_over_2_all";
    mutation_method = "all_genes_rndom_shuffle";
    culling_method = "top_and_randsamp";

    %Fixed parameters
%     num_inner_gen_no_improve = 5;
%     max_gens_allowed = 500;
    diagnose = false;
    parallel = true;
    num_tiers = 20; %Param not used by methods
    
    %Unpack the varying parameters
    x_cells = num2cell(x);

    [   pop_size,...
        simple_prop, ...
        init_prop_random, ...
        alpha_parent, ...
        alpha_mutation, ...
        parent_ratio, ...
        least_fit_prop, ...
        most_fit_prop, ...
        parent_switch_prob, ...
        mutation_prop, ...
        keep_prop, ...
        num_inner, ...
        num_inner_gen_no_improve, ...
        max_gens_allowed
        ] = x_cells{:}
    
    %Approximating int problem
    pop_size = floor(pop_size);
    pop_size = pop_size - mod(pop_size,2);%make sure divisble by 2 for par
    num_inner = floor(num_inner);
    
    alg1_args = {
            pop_size, init_alg, simple_prop, init_prop_random, num_tiers, ... %inits
            selection_method, alpha_parent, alpha_mutation, ... %selection
            parent_ratio, cross_over_method, ...
            least_fit_prop, most_fit_prop, parent_switch_prob, ... %crossover
            mutation_method, mutation_prop, ... %mutation
            culling_method, keep_prop, ... %culling
            num_inner_gen_no_improve, max_gens_allowed, ...  %termination
            diagnose, ... %verbose/diagnose
            parallel, num_inner %parallelisation
            };
    
    
    algs = {alg1};
    algs_args = {alg1_args};
    
    results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion);
                        
    % Set Cost to be the sum of average times across the program range
    % Probably Not perfect, but allows us to be in the ballpark
    % TODO: actually maybe penalise by ratio to lower bound perhaps
    %       time*ratio_lb^3?
    
    %1 alg, 1 machine prop, 1st metric (time)
    total_average_time = sum(results(1,:,1,1));
    
    %1 alg, 1 machine prop, 3rd metric (ratio to lb)
    average_lb_ratio = mean(results(1,:,1,3));
%     lb_ratio_penalty = ((average_lb_ratio-1)*10)^3;
    lb_ratio_penalty = ((average_lb_ratio-1))^3;
    cost = total_average_time*lb_ratio_penalty;
    
    %cost = time_cost;
    
    fprintf("Total Average time: %f, Average Ratio to lower Bound: %f\n",...
                total_average_time, average_lb_ratio);
end