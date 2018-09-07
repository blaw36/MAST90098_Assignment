%% Input:
    % input_array: n+1 length vector of job costs, and n+1th element is # of
        % machines
    % k_exch: specifies which exchange is being used
    % init_algo: initialisation algorithm:
        % 'simple' = Costliest job allocated to machine with most 'capacity'
        % relative to most utilised machine at the time
        % 'random' = Random allocation (random number generated for machine)
        % 'naive' = All jobs placed into machine 1
%% Output:
    % output_array:
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_no, unique job_id
    % makespan:
        % max, across all machines, of sum of jobs for a given machine
    % num_exchanges:
        % number of exchanges performed
%%
function [output_array, makespan, num_exchanges] = ...
                            gls(input_array, k_exch, init_algo)                   

    % Initialisation
    length_of_input = length(input_array);
    num_jobs = length_of_input - 1;
    num_machines = input_array(length_of_input);
    num_exchanges = 0;

    % Variable checking
    if k_exch > input_array(length_of_input)
        error("Number of exchanges cannot exceed number of machines")
    end

    % Print some stuff to screen
    fprintf("num_jobs: %d \n", num_jobs);
    fprintf("number_of_machines: %d \n", num_machines);

    [output_array, done] = initialise_ouput_array(...
                        init_algo, input_array, num_jobs, num_machines);
                                        
    %TODO: Switch to using ss, and cs structs to tidy things up
    [program_costs, ...
    machine_start_indices, M, machine_costs, makespan, L] ...
    = initialise_supporting_structs(output_array, num_machines, num_jobs);

    [selected_machines, machine_orders, machine_orders_end] = ...
                    initialise_combinatoric_structs(num_machines, k_exch);
                
    fprintf("Relative Error to LB after init %f\n",...
       makespan/lower_bound_makespan(input_array)...
       );
    
    while done == false  
        %Generate and test neighbourhood
        [best_neighbour, best_neighbour_makespan] = generate_and_test(...
                 k_exch, L, M, ...
                 machine_costs, machine_start_indices, program_costs,...
                 selected_machines, machine_orders, machine_orders_end);
        
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
