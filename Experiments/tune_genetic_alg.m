% A script used to tune the parameters of the genetic alg for given fixed
% sub algorithms
%%
[outputMakespan, time_taken, init_makespan, outputArray, ...
    best_gen_num, generations, diags_array]...
        = genetic_alg_outer(a, ...
        100, "init_rand_greedy", 0.02, 0.4, ... %inits
        "neg_exp", ... %selection
        8, "c_over_2_all", ...
        1/2, 1/3, ... %crossover
        "all_genes_rndom_shuffle", floor(0.4*(size(a,2)-1)), ... %mutation
        "top_and_randsamp", 0.8, ... %culling
        10, 200, ...  %termination
        true, ... %verbose/diagnose
        false); %parallelisation

%TODO: Fixed algorithms
init_alg = "init_rand_greedy";
selection_method = "neg_exp";
cross_over_method = "c_over_2_all";
mutation_method = "all_genes_rndom_shuffle";
culling_method = "top_and_randsamp";

%TODO: x0
x0=[100, ... %pop_size
    0.02, ... %simple_prop
    0.04, ... %init_k
    8, ... %parent_ratio
    1/2, ... %least_fit_proportion
    1/3, ... %most_fit_proportion
    floor(0.4*(size(a,2)-1)), ... %mutate_num_shuffles do 0.4 param -> 
    0.8, ... %cull_prop
    10, ...  %max_gen_no improv
    200 %max_gens_allowed
]
%TODO: Upper and lower bounds for each param
lb = [];
ub = [];
%TODO: Constraints, has to beat/equal vds's lower bound on the same range
% so run vds once on the same range (test instances stay constant between
% runs) to get bounds

%or just <1.05 with penalty?

handler = @(x) tuning_function(x);

%TODO: Optimisation function
options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
x = patternsearch(handler,x0,[],[],[],[],lb,ub,[],options)

function cost = tuning_function(x)

    %Other fixed params----------------------------------------------------
    hard = false;
    gen_method = @(num_programs, num_machines) ...
                generate_ms_instances(num_programs, num_machines, hard);
    
    %Define a suitable range
    programs_range = 200:200:1000;
    num_trials = 5;
    %Just do it on a fixed proportion
    machines_denom_iterator = 1;
    machines_proportion = 0.4;

    alg1 = @(input_array, args) genetic_outer(input_array, args{:});
    
    %Process x and the function args above into a suitable format 
    alg1_args = {
        x(1), "init_rand_greedy", 0.02, 0.4, ... %inits
        "neg_exp", ... %selection
        8, "c_over_2_all", ...
        1/2, 1/3, ... %crossover
        "all_genes_rndom_shuffle", floor(0.4*(size(a,2)-1)), ... %mutation
        "top_and_randsamp", 0.8, ... %culling
        10, 200, ...  %termination
        true, ... %verbose/diagnose
        true... %parallel
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
    
    %1 alg, 1 machine prop, 1 metric (time)
    cost = sum(results(1,:,1,1));
end
