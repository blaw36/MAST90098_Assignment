%% vds.m
% Performs a variable depth search on the passed makespan problem
%% Input:
    % input_array: n+1 length vector of job costs, and n+1th element is # of
        % machines
    % k: specifies which exchange is being used
    % init_algo: initialisation algorithm:
        % 'simple' = Costliest job allocated to machine with most 'capacity'
        % relative to most utilised machine at the time
        % 'random' = Random allocation (random number generated for machine)
        % 'naive' = All jobs placed into machine 1
%% Output:
    % output_array:
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_no, unique job_id , movable
    % makespan:
        % max, across all machines, of sum of jobs for a given machines
    % num_exchanges:
        % number of exchanges performed
    % num_transformations:
        % number of times a new best of sequence is chosen
%%
function [output_array, makespan, num_exchanges, num_transformations] = ...
                            vds(input_array, k, init_algo, k2_opt)
    if ~exist('k2_opt','var') || k ~= 2
        k2_opt=false;
    end   
    
    %Indicates need to keep track of moved
    fix_moved = true;                    
            
    [num_jobs, num_machines, output_array, done] ...
                =  process_input(input_array, k, init_algo, fix_moved);
                                        
    %Note: Althought it is a little messy passing this many parameters
    %about, using structures (or objects) incurrs an overhead cost
    [program_costs,machine_start_indices,M,machine_costs,makespan,L] ...
                = initialise_supporting_structs(...
                        output_array, num_machines, num_jobs);

    [selected_machines, machine_orders]  ...
                = initialise_combinatoric_structs(num_machines, k);
                
%     fprintf("Relative Error to LB after init %f\n",...
%        makespan/lower_bound_makespan(input_array)...
%        );
    
    num_transformations = 0;
    num_exchanges = 0;
    
    %Start Main Loop
    while done == false
        %Start Inner Loop on restricted sequence
        inner_done = false;
        
        %Make a copy of items to be used in inner loop
        i_output_array = output_array;
        i_L = L;
        i_M = M;
        i_machine_costs = machine_costs;
        i_machine_start_indices = machine_start_indices;
        i_program_costs = program_costs;
        
        best_seq_makespan = inf;
        best_output_array = [];
        
        while inner_done == false
            %Generate and test neighbourhood
            if k2_opt
            [best_inner, best_inner_makespan] = k2_generate_and_test(...
                i_L, i_M, num_machines,...
                i_machine_costs, i_machine_start_indices, i_program_costs);
            else
            [best_inner, best_inner_makespan] = generate_and_test(...
                k, i_L, i_M, ...
                i_machine_costs, i_machine_start_indices, i_program_costs,...
                selected_machines, machine_orders);
            end
            
            %Update to best_inner
            i_output_array = make_move(i_output_array,...
                        i_machine_start_indices, best_inner, fix_moved);
                                            
            [i_program_costs, i_machine_start_indices, ...
                                            i_M, i_machine_costs, i_L] ...
                    = update_supporting_structs(...
                                            best_inner, ...
                                            i_output_array, ...
                                            num_machines,...
                                            i_program_costs, ...
                                            i_machine_start_indices, ...
                                            i_M, ...
                                            i_machine_costs, ...
                                            best_inner_makespan,...
                                            fix_moved);
            
            %Checks if at new best, if so records the supporting structures
            if best_seq_makespan > best_inner_makespan
                best_seq_makespan = best_inner_makespan;
                
                %Note: Can't set makespan and output_array as may need to
                %return these if no improvement, and can't set M as the
                %movable programs will get reset at next sequence.
                program_costs = i_program_costs;
                machine_start_indices = i_machine_start_indices;
                machine_costs = i_machine_costs;
                L = i_L;
                
                best_output_array = i_output_array;
            end
            
            %Update Bookkeeping values
            num_exchanges = num_exchanges + 1;
            
            %Checks if any of the loaded machines have no moveable programs
            %in which case, any further actions can only increase costs. So
            %can terminate here.
            if any(i_M(i_L) == 0)
                inner_done = true;
            end
        end
             
        % Evaluate termination flag, only if new is better
        if makespan <= best_seq_makespan
            done = true;
        else
            % Update, to new best (supporting structs already updated)
            output_array = best_output_array;
            makespan = best_seq_makespan;
            
            %Allow all jobs to be moved again,
            output_array(:,4) = ones(num_jobs,1);
            % and update M to reflect this
            non_empty_machines = 1:num_machines;
            non_empty_machines(machine_start_indices==0) = [];    
            non_empty_start_indices = machine_start_indices(non_empty_machines);
            padded = [non_empty_start_indices, num_jobs+1];

            M = zeros(1, num_machines);
            M(non_empty_machines) = diff(padded);
            
            %Update Bookkeeping values
            num_transformations = num_transformations + 1;
        end
    end
end