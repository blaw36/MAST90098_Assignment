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
    % columns - job_cost, machine_no, mach_job_id
% outputMakespan:
    % max, across all machines, of sum of jobs for a given machine

function [outputArray, outputMakespan] = ms_solver_gls_v1(inputArray)

    length_of_input = length(inputArray);
    number_of_jobs = length_of_input - 1;
    number_of_machines = inputArray(length_of_input);
    jobs_to_sort = inputArray(1:(length_of_input-1));
    
    outputArray = zeros(number_of_jobs,3);
    
    fprintf("input_length: %d \n", length_of_input);
    fprintf("num_jobs: %d \n", number_of_jobs);
    fprintf("num_machines: %d \n", number_of_machines);
    fprintf("jobs: %s \n", strjoin(cellstr(num2str(jobs_to_sort))));
    
    % If we happen to get less jobs than machines, makespan
    % is just time of most expensive job
    if (number_of_jobs <= number_of_machines)
        for i = 1:number_of_jobs
            outputArray(i,:) = [inputArray(i),i,1];
        end
        outputMakespan = max(outputArray(:,1));
   
    else
            
    % Otherwise, we need an initialise function for an initial solution
    initialisedArray = initialise_simple(inputArray, number_of_machines);
    
    makespan = evaluate_makespan(initialisedArray);
   
    % A function to find all the neighbours to a soln (a function of k,
    % the exchange, and perhaps some parameter to describe the 
    % exchange operation)

    % Evaluate n/bours and pick optimal n/bour with certain:
        % k exchange,
        % exchange function
    [new_array, new_makespan] = pick_new_nbour(initialisedArray, k, 'swap');
    
    % Continue until optimal n/bour is current arrangement
    
    outputArray;

    end
end
