%% process_input.m
% A script which processes the input string, outputs how many jobs and 
% machines there are, as well as providing an initial allocation.
%% Input:
    % input_array: n+1 length vector of job costs, and n+1th element is 
        % # of machines
    % init_algo: A string specifying how to pick an initial feasible sol'n
    % k: specifies the k exchange
    % fix_moved: Indicates whether the 4th col of output_array ('movable')
        % should exist and whether moved programs should be flagged as 
        % being moved. FALSE for GLS, TRUE for VDS.

%% Output:
    % num_jobs: the number of jobs
    % num_machines: the number of machines
    % output_array: Assumed to be sorted by machine_num, (then movable)
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_num, unique job_id, (movable)
    % done: A flag indicating whether done or not
%%
function [num_jobs, num_machines, output_array, done] = process_input(...
                                input_array, k, init_algo, fix_moved)
    
    % Should the 'movable' column exist
    if ~exist('fix_moved','var')
        fix_moved=false;
    end                        
                            
    % Key instance information
    length_of_input = length(input_array);
    num_jobs = length_of_input - 1;
    num_machines = input_array(length_of_input);
    done = false;

    % Variable checking
    if k > num_machines
        error("Number of exchanges cannot exceed number of machines")
    end
    allowed_init_algos = ["simple", "random", "naive"];
    if sum(strcmp(allowed_init_algos,init_algo)) == 0
        error("'Init_algo' parameter must be one of: '%s' \n", ...
                                    strjoin(allowed_init_algos,"', '"));
    end

    % Initialise the output_array
    output_array = zeros(num_jobs,3+fix_moved);

    if (num_jobs <= num_machines)
        % If we happen to get less jobs than machines, makespan
        % is just cost of most expensive job
        output_array = [input_array(1:num_jobs)', (1:num_jobs)', (1:num_jobs)'];
        done = true;

    elseif (num_machines == 1)
        % If one machine, everything allocated to that machine
        % Makespan is just the max
        output_array(:,1:2) = initialise_naive(input_array, num_jobs);
        output_array(:,3) = (1:length(output_array))';
        done = true;
    else
        % Otherwise, start by initialising a solution
        if init_algo == "simple"
            output_array(:,1:2) = initialise_simple(input_array, num_jobs, num_machines);
        elseif init_algo == "random"
            output_array(:,1:2) = initialise_random(input_array, num_jobs, num_machines);
        elseif init_algo == "naive"
            output_array(:,1:2) = initialise_naive(input_array, num_jobs);
        end

        % Assign unique job_id to each job
        output_array(:,3) = (1:num_jobs)';
        
        % If need to fix_moved add a column storing the movable state
        if fix_moved
            output_array(:,4) = ones(num_jobs,1);
        end
        
        % Sort output_array by machine #
        output_array = sortrows(output_array, 2);
    end             
end