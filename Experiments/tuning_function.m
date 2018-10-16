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
        max_gens_allowed, ...
        ] = x_cells{:}
    
    %Approximating int problem
    pop_size = floor(pop_size);
    pop_size = pop_size - mod(pop_size,2);%make sure divisble by 2 for par
    num_inner = floor(num_inner);
    num_inner_gen_no_improve = floor(num_inner_gen_no_improve);
    max_gens_allowed = floor(max_gens_allowed);
    
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
    
    % Original
%     lb_ratio_penalty = ((average_lb_ratio-1)*10)^3;
    % Less weighting on time, more on performance
    lb_ratio_penalty = ((average_lb_ratio-1))^3;

%     cost = total_average_time*lb_ratio_penalty;
    % Still less weighting on time, even more on performance
    cost = log(1+total_average_time)*(lb_ratio_penalty^10);
    
    %cost = time_cost;
    
    fprintf("Total Average time: %f, Average Ratio to lower Bound: %f\n",...
                total_average_time, average_lb_ratio);
end