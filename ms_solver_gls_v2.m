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
function [outputArray, outputMakespan, num_exchanges] = ...
                            ms_solver_gls_v2(inputArray, k_exch, init_algo)

% Variable checking
allowed_init_algos = ["simple", "random", "naive"];
if sum(strcmp(allowed_init_algos,init_algo)) == 0
    error("'Init_algo' parameter must be one of: '%s' \n", strjoin(allowed_init_algos,"', '"))
end

% Initialisation
length_of_input = length(inputArray);
number_of_jobs = length_of_input - 1;
number_of_machines = inputArray(length_of_input);
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
        outputArray(:,1:2) = initialise_simple2(inputArray, number_of_jobs, number_of_machines);

    elseif init_algo == "random"
        outputArray(:,1:2) = initialise_random(inputArray, number_of_jobs, number_of_machines);
    elseif init_algo == "naive"
        outputArray(:,1:2) = initialise_naive(inputArray, number_of_jobs);
    end
    
    % Assign unique job_id to each job
    outputArray(:,3) = (1:length(outputArray))';
    update = true;
    num_exchanges = 0;
    
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
    
    %TODO: Better Compute/Update new Costs
    %Todo: Better Compute/Update new L
    %for now
    machine_costs = zeros(1,number_of_machines);
    for i = 1:(length(machine_start_indices)-1)
        slice = [machine_start_indices(i), ...
                machine_start_indices(i+1)-1];
        if slice(1)>0 && slice(2)>0
            machine_costs(i) = sum(outputArray(slice(1):slice(2),1));
        elseif slice(1)>0
            machine_costs(i) = sum(...
                outputArray(slice(1):number_of_jobs,1));
        else
            machine_costs(i) = 0;
        end
    end
    %last
    if machine_start_indices(number_of_machines) == 0
        machine_costs(number_of_machines) = 0;
    else
        machine_costs(number_of_machines) = sum(outputArray(...
        machine_start_indices(number_of_machines):number_of_jobs,1));
    end
     
    outputMakespan = max(machine_costs);
    L = find(machine_costs==outputMakespan);

    while update == true
        
%         clc
%         fprintf("Exchanges: %d\n", num_exchanges);
%         fprintf("Makespan: %d\n", outputMakespan);
        
        %Generate neighbours
        g = NeighbourhoodGenerator3(k_exch, L, M);
        
        best_neighbour = {};
        best_neighbour_makespan = outputMakespan;
        
        program_costs = outputArray(:,1);
        while g.done == false            
            [min_neigh_makespan, prog_index] = ...
                find_min_neighbour( g.order, g.programs, ...
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
        if outputMakespan <= best_neighbour_makespan
            update = false;
        else
            % Update to new instance
            % TODO Move should respect order than no need to sort
            outputMakespan = best_neighbour_makespan;
            outputArray = make_move(outputArray, machine_start_indices,...
                                                best_neighbour);
                                            
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
            
            %TODO: Better Compute/Update new Costs
            %Todo: Better Compute/Update new L
            %for now
            for i = 1:(length(machine_start_indices)-1)
                slice = [machine_start_indices(i), ...
                        machine_start_indices(i+1)-1];
                if slice(1)>0 && slice(2)>0
                    machine_costs(i) = sum(outputArray(slice(1):slice(2),1));
                elseif slice(1)>0
                    machine_costs(i) = sum(...
                        outputArray(slice(1):number_of_jobs,1));
                else
                    machine_costs(i) = 0;
                end
            end
            %last
            if machine_start_indices(number_of_machines) == 0
                machine_costs(number_of_machines) = 0;
            else
                machine_costs(number_of_machines) = sum(outputArray(...
                machine_start_indices(number_of_machines):number_of_jobs,1));
            end
            
            
%             machine_start_indices
%             outputArray
%             machine_costs
%             
%             outputMakespan
%             max(machine_costs)
%             
            if outputMakespan ~= max(machine_costs)
                disp("Error: Expected Cost of Move was not achieved")
                return
            end
            
            L = find(machine_costs==outputMakespan);
            
            %Update Bookkeeping values
            num_exchanges = num_exchanges + 1;
        end
    end
end
end
