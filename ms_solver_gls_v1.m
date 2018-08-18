% Author: Brendan Law
% Date: 15th August 2018

% Output array should have, for each m machine
    % The optimal order of the jobs
% As well as the (m+1)th cell containing the makespan of the problem
    % ie. the total time of longest running machine

% a = generate_ms_instances(10,5)

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

function [outputArray, outputMakespan, num_exchanges, time_taken] = ms_solver_gls_v1(inputArray)

    % Start time
    startTime = tic;

    length_of_input = length(inputArray);
    number_of_jobs = length_of_input - 1;
    number_of_machines = inputArray(length_of_input);
    jobs_to_sort = inputArray(1:(length_of_input-1));
    
    outputArray = zeros(number_of_jobs,3);
    
    fprintf("input_length: %d \n", length_of_input);
    fprintf("num_jobs: %d \n", number_of_jobs);
    fprintf("number_of_machines: %d \n", number_of_machines);
    
    % If we happen to get less jobs than machines, makespan
    % is just time of most expensive job
    if (number_of_jobs <= number_of_machines)
        for i = 1:number_of_jobs
            outputArray(i,:) = [inputArray(i),i,1];
        end
        outputMakespan = max(outputArray(:,1));
   
    else
            
    % Otherwise, we need an initialise function for an initial solution
    outputArray = initialise_simple(inputArray, number_of_machines);
    % Assign unique job_id to each job
    outputArray = [outputArray (1:length(outputArray))'];
    [cost, outputMakespan] = evaluate_makespan(outputArray, number_of_machines);
    update = true;
    
    num_exchanges = 0;
    
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

    end
    
    % Finish
    time_taken = toc(startTime);
    
end
