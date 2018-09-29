%% gls.m
% A function which solves the makespan problem using a Greedy Local Search
% (GLS)
%% Input:
    % input_array: n+1 length vector of job costs, and n+1th element is # of
        % machines
    % k: specifies the k exchange
    % init_algo: A string specifying how to pick an initial feasible sol'n:
        % 'simple', 'random', 'naive'
%% Output:
    % makespan:
        % max, across all machines, of sum of jobs for a given machines
    % time_taken:
        % the time taken for the algorithm to run to completion
    % init_makespan:
        % the makespan after initiation
    % output_array:
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_no, unique job_id
    % num_exchanges:
        % number of exchanges performed
    % time_taken:
        % time taken for algorithm to run
%%
function [makespan, time_taken, init_makespan, output_array, ...
                num_exchanges] = gls(input_array, k, init_algo, k2_opt)                   
    start_time = tic;
    if ~exist('k2_opt','var') || k ~= 2
        k2_opt=false;
    end 
    % Extract important information from input, and initialise a sol'n
    [num_jobs, num_machines, output_array, done] = ...
                                process_input(input_array, k, init_algo);
                                        
    % Note: Although it is a little messy passing this many parameters
    % about, using structures (or objects) incurrs an overhead cost
    [program_costs,machine_start_indices,M,machine_costs,makespan,L] ...
                    = initialise_supporting_structs(...
                                    output_array, num_machines, num_jobs);
    
    %Can be expensive, so don't want to do it if don't have to
    if ~done && ~k2_opt
        [selected_machines, machine_orders]  ...
                    = initialise_combinatoric_structs(num_machines, k);
    end
    
    %Record makespan after Initialisation
    init_makespan = makespan;
    
    % Initialise number of exchanges counter
    num_exchanges = 0;
    %A flag passed down to indicate greedy
    greedy_flag = true;
    
    while done == false
        % Early Termination as no greedy changes will have any effect.
        % The exchange must interact with all loaded machines to decrease
        % the makespan. => length(L) <= k for progress to be made.
        % However if length(L) == k then the only exchange that can make a
        % difference must choose all loaded machines, and switching jobs
        % between machines of equal machine cost cannot result in them all
        % having a lower cost. => length(L) < k for progress to be made.
        if length(L) >= k
            done = true;
            continue
        end
        % Generate and test neighbourhood
        if k2_opt
            % Function optimised for k = 2
            [best_neighbour, best_neighbour_makespan] = k2_generate_and_test(...
                makespan, L, M, num_machines, ...
                machine_costs, machine_start_indices, program_costs, ...
                greedy_flag);
        else
            % General function for all k
            [best_neighbour, best_neighbour_makespan] = generate_and_test(...
                k, makespan, L, M, ...
                machine_costs, machine_start_indices, program_costs,...
                selected_machines, machine_orders, greedy_flag);
        end
        
        % Set termination flag to true if no improvement from new iteration
        if makespan <= best_neighbour_makespan
            done = true;
        else
            % Update to new instance
            makespan = best_neighbour_makespan;
            output_array = make_move(output_array, machine_start_indices,...
                                                best_neighbour);
                                            
            [program_costs, machine_start_indices, M, machine_costs, L] ...
                    = update_supporting_structs(...
                                                best_neighbour, ...
                                                output_array, ...
                                                num_machines,...
                                                program_costs, ...
                                                machine_start_indices, ...
                                                M, ...
                                                machine_costs, ...
                                                makespan);
            
            % Update number of exchanges counter
            num_exchanges = num_exchanges + 1;
        end
    end
    time_taken = toc(start_time);
end