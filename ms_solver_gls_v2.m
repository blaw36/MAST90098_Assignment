% Author: Brendan Law
% Date: 15th August 2018

% Output array should have, for each m machine
% The optimal order of the jobs
% As well as the (m+1)th cell containing the makespan of the problem
% ie. the total time of longest running machine

% Input:
    % inputArray: n+1 length vector of job costs, and n+1th element is # of
        % machines
    % k_exch: k-value for # of exchanges
    % init_algo: initialisation algorithm:
        % 'simple' = Costliest job allocated to machine with most 'capacity'
        % relative to most utilised machine at the time
        % 'random' = Random allocation (random number generated for machine)
        % 'naive' = All jobs placed into machine 1

% Output:
    % state_array:
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_no, unique job_id
    % makespan:
        % max, across all machines, of sum of jobs for a given machine
    % num_exchanges:
        % number of (k-)exchanges performed
function [state_array, makespan, num_exchanges] = ...
                            ms_solver_gls_v2(inputArray, k_exch, init_algo)

% Variable checking
allowed_init_algos = ["simple", "random", "naive"];
if sum(strcmp(allowed_init_algos,init_algo)) == 0
    error("'Init_algo' parameter must be one of: '%s' \n", strjoin(allowed_init_algos,"', '"))
end

% Initialisation
length_of_input = length(inputArray);
num_jobs = length_of_input - 1;
num_machines = inputArray(length_of_input);
state_array = zeros(num_jobs,3);

% Print some stuff to screen
fprintf("input_length: %d \n", length_of_input);
fprintf("num_jobs: %d \n", num_jobs);
fprintf("number_of_machines: %d \n", num_machines);

if (num_jobs <= num_machines)
    % If we happen to get less jobs than machines, makespan
    % is just time of most expensive job
    state_array = [inputArray(1:num_jobs)', (1:num_jobs)', (1:num_jobs)'];
    makespan = max(state_array(:,1));
    num_exchanges = 0;
    
elseif (num_machines == 1)
    % If one machine, everything allocated to that machine
    % Makespan is just the max
    state_array(:,1:2) = initialise_naive(inputArray, num_jobs);
    state_array(:,3) = (1:length(state_array))';
    makespan = sum(state_array(:,1));
    num_exchanges = 0;

else
    % Otherwise, we need an initialise function for an initial solution
    if init_algo == "simple"
        state_array(:,1:2) = initialise_simple2(inputArray, num_jobs, num_machines);
    elseif init_algo == "random"
        state_array(:,1:2) = initialise_random(inputArray, num_jobs, num_machines);
    elseif init_algo == "naive"
        state_array(:,1:2) = initialise_naive(inputArray, num_jobs);
    end
    
    % Assign unique job_id to each job
    state_array(:,3) = (1:length(state_array))';
    update = true;
    num_exchanges = 0;
    
    [state_array, machine_start_indices, M, machine_costs, makespan, L] ...
        = update_supporting_structs(state_array, num_machines, num_jobs);

    while update == true  
        %Generate for instance
        g = NeighbourhoodGenerator3(k_exch, L, M);
        best_neighbour = {};
        best_neighbour_makespan = makespan;
        
        %Cost of each program
        program_costs = state_array(:,1);
        
        %While still neighbours
        while g.done == false
            %Find the best neighbour in this batch of neighbours
            [min_neigh_makespan, prog_index] = find_min_neighbour(...
                                g.order, g.programs, ...
                                machine_costs, machine_start_indices, ...
                                program_costs);
                                
            if min_neigh_makespan < best_neighbour_makespan
                best_neighbour_makespan = min_neigh_makespan;
                best_neighbour = {g.order, g.programs(prog_index,:)};
            end
            %Retrieve next
            g.next();
        end
        
        % Evaluate termination flag, only if new is better
        if makespan <= best_neighbour_makespan
            update = false;
        else
            % Update to new instance
            makespan = best_neighbour_makespan;
            state_array = make_move(state_array, machine_start_indices,...
                                                best_neighbour);
                                            
            [state_array, machine_start_indices, M, machine_costs, ...
                makespan, L] ...
            = update_supporting_structs(state_array, num_machines, num_jobs);
            
            %Update Bookkeeping values
            num_exchanges = num_exchanges + 1;
        end
    end
end
end
