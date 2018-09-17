%% gls.m
% A script which solves the makespan problem using a Greedy Local Search
% (GLS)
%% Input:
    % input_array: n+1 length vector of job costs, and n+1th element is # of
        % machines
    % k: specifies the k exchange
    % init_algo: A string specifying how to pick an initial feasible sol'n:
        % 'simple', 'random', 'naive'
%% Output:
    % output_array:
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_no, unique job_id
    % makespan:
        % max, across all machines, of sum of job costs for a given machine
    % num_exchanges:
        % number of exchanges performed
%%
function [output_array, makespan, num_exchanges] = ...
                            gls(input_array, k, init_algo)                   
    
    % Extract important information from input, and initialise a sol'n
    [num_jobs, num_machines, output_array, done] = ...
                                process_input(input_array, k, init_algo);
                                        
    % Note: Although it is a little messy passing this many parameters
    % about, using structures (or objects) incurrs an overhead cost
    [program_costs,machine_start_indices,M,machine_costs,makespan,L] ...
                    = initialise_supporting_structs(...
                                    output_array, num_machines, num_jobs);

    [selected_machines, machine_orders]  ...
                    = initialise_combinatoric_structs(num_machines, k);
                
    fprintf("Relative Error to LB after init %f\n",...
       makespan/lower_bound_makespan(input_array)...
       );
    
    num_exchanges = 0;
    while done == false  
        %Generate and test neighbourhood
        if k==2
        [best_neighbour, best_neighbour_makespan] = k2_generate_and_test(...
             L, M, ...
             machine_costs, machine_start_indices, program_costs);
        else
        [best_neighbour, best_neighbour_makespan] = par_generate_and_test(...
                 k, L, M, ...
                 machine_costs, machine_start_indices, program_costs,...
                 selected_machines, machine_orders);
        end
        % Evaluate termination flag, only if new is better
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
            
            %Update Bookkeeping values
            num_exchanges = num_exchanges + 1;
        end
    end
end