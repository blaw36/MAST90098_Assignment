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
    % outputArray:
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_no, unique job_id
    % outputMakespan:
        % max, across all machines, of sum of jobs for a given machine
    % num_exchanges:
        % number of (k-)exchanges performed
    % time_taken:
        % in seconds, for execution (not CPU time)

function [outputArray, outputMakespan, num_exchanges,...
    time_taken] = ms_solver_gls_v2(inputArray, k_exch, init_algo)

% Start time
startTime = tic;

% Variable checking
allowed_init_algos = ["simple", "random", "naive"];
if sum(strcmp(allowed_init_algos,init_algo)) == 0
    error("'Init_algo' parameter must be one of: '%s' \n", strjoin(allowed_init_algos,"', '"))
end

% Initialisation
length_of_input = length(inputArray);
number_of_jobs = length_of_input - 1;
number_of_machines = inputArray(length_of_input);
jobs_to_sort = inputArray(1:(length_of_input-1));
outputArray = zeros(number_of_jobs,3);

% Print some stuff to screen
fprintf("input_length: %d \n", length_of_input);
fprintf("num_jobs: %d \n", number_of_jobs);
fprintf("number_of_machines: %d \n", number_of_machines);

if (number_of_jobs <= number_of_machines)
    % If we happen to get less jobs than machines, makespan
    % is just time of most expensive job
    outputArray = [inputArray(1:number_of_jobs)', (1:number_of_jobs)', ...
        (1:number_of_jobs)'];
    outputMakespan = max(outputArray(:,1));
    num_exchanges = 0;
    
elseif (number_of_machines == 1)
    % If one machine, everything allocated to that machine
    % Makespan is just the max
    outputArray(:,1:2) = initialise_naive(inputArray, number_of_jobs);
    outputArray(:,3) = (1:length(outputArray))';
    outputMakespan = sum(outputArray(:,1));
    num_exchanges = 0;
    
else
    
    % Otherwise, we need an initialise function for an initial solution
    if init_algo == "simple"
        outputArray(:,1:2) = initialise_simple(inputArray, number_of_jobs, number_of_machines);
    elseif init_algo == "random"
        outputArray(:,1:2) = initialise_random(inputArray, number_of_jobs, number_of_machines);
    elseif init_algo == "naive"
        outputArray(:,1:2) = initialise_naive(inputArray, number_of_jobs);
    end
    
    % Assign unique job_id to each job
    outputArray(:,3) = (1:length(outputArray))';
    update = true;
    num_exchanges = 0;
    
    [costs, outputMakespan, L] = evaluate_makespan(outputArray, number_of_machines);
    
    %More succint way to store costs if first col is 1:m anyway
    costs = costs(:,2)';

    while update == true
        
        fprintf("Exchanges: %d\n", num_exchanges);
        fprintf("Makespan: %d\n", outputMakespan);
        
        %Sorts outputArray by machine, then cost        
        outputArray = sortrows(outputArray,1);
        outputArray = sortrows(outputArray,2);
        
        %Find where the machine first appears in table (if at all)
        %Todo: Better way
        machine_start_indices = zeros(1,number_of_machines);
        for i = 1:number_of_jobs
            machine_start_indices(outputArray(number_of_jobs+1-i,2)) = number_of_jobs-i+1;
        end
        %Find M
        %Todo: Better way
        M = zeros(1,number_of_machines);
        for i = 1:number_of_machines
            M(i) = sum(outputArray(:,2)==i);
        end
        
        %Generate neighbours
        g = NeighbourhoodGenerator3(k_exch, L, M);
        
        best_neighbour = {};
        best_neighbour_costs = costs;
        best_neighbour_makespan = outputMakespan;
        best_L = [];
        while g.done == false
            for i = 1:g.programs_end
                %TODO: Want to be able to process all of the program
                %neighbour instances in one 'batch' for speed
                % => need best_neigh = f(g.order, g.programs, ...
                %                        information about cost of progs)
                % i.e. instead of iterative operate on matrix.
                
                p = g.programs(i,:);
                %Evaluate the neighbour
                [new_costs, new_makespan, new_L] = evaluate_neighbour( ...
                        g.order, p, ...
                        outputArray, costs, machine_start_indices);
                if new_makespan < best_neighbour_makespan
                    best_neighbour_costs = new_costs;
                    best_neighbour_makespan = new_makespan;
                    best_L = new_L;
                    best_neighbour = {g.order, p};
                end
            end
            %Retrieve next
            g.next();
        end
        
        % Evaluate termination flag, only if new is better
        if outputMakespan <= best_neighbour_makespan
            update = false;
        else
            % Update to new instance
            outputArray = make_move(outputArray, machine_start_indices,...
                                                best_neighbour);
            
            costs = best_neighbour_costs;
            outputMakespan = best_neighbour_makespan;
            L = best_L;
            num_exchanges = num_exchanges + 1;
        end
    end
end

% Finish
time_taken = toc(startTime);
sprintf("Finished")

end
