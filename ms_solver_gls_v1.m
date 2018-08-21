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
    time_taken, nbour_time] = ms_solver_gls_v1(inputArray, k_exch, init_algo)

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
    [cost, outputMakespan] = evaluate_makespan(outputArray, number_of_machines);
    update = true;
    
    num_exchanges = 0;
    
    nbour_start = tic;
    while update == true
        
        % A function to encode all the neighbours to a soln (a function of k,
        % the exchange, and perhaps some parameter to describe the
        % exchange operation)
        
        % Structure of 'possible_neighbours':
        % Job ID | Machine_from | Machine_to | n/bour_combo_id
        
        %%%%% Must be equal to k exchanges
        possible_neighbours = generate_exchange_combinations(outputArray,...
            1, number_of_machines);
        
        %%%%% Slightly different arrangement if up to k exchanges allowed
        % (recursion?)
        
        % Evaluate the n/bours generated above, pick the best, and change
        nbour_results = evaluate_neighbours(outputArray, possible_neighbours, 1, number_of_machines);
        [new_makespan, best_nbour] = min(nbour_results(:,2));
        
        % Evaluate termination flag, only if new is better
        if outputMakespan <= new_makespan
            update = false;
        else
            outputArray(possible_neighbours(best_nbour,1),2) = possible_neighbours(best_nbour,3);
            
            % Update old_makespan
            outputMakespan = new_makespan;
            num_exchanges = num_exchanges + 1;
        end
        
    end
    nbour_time = toc(nbour_start);
    
end

% Finish
time_taken = toc(startTime);
sprintf("Finished")

end
