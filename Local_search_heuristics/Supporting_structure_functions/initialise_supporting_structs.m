% Initialises the supporting structures (Not optimal but only called once)
%% Input:
%   %output_array: Assumed to be sorted by machine_num, (then movable)
%       rows - a job allocated to a position in a machine
%       columns - job_cost, machine_num, unique job_id, (movable)
%   %num_machines: the number of machines
%   %num_jobs: the number of jobs
%   %fix_moved: Indicates whether the 4th col of output_array exists and
%       whether moved programs should be flagged as being moved.
%% Ouput:
%   %machine_start_indices: The ith value indicates which row of the
%       output_array the ith machine first appears
%   %M: The number of (movable) programs in each machine
%   %machine_costs: The costs of all machines
%   %makespan: The cost of the most loaded machine(s)
%   %L: The machine numbers of all the loaded machines
%%
function [program_costs, ...
    machine_start_indices, M, machine_costs, makespan, L] ...
    = initialise_supporting_structs(output_array, num_machines, num_jobs)
                                
    program_costs = output_array(:,1);

    %Find where each machine first appears in table (if at all)
    machine_start_indices = zeros(1, num_machines);
    for i = num_jobs:-1:1
        machine = output_array(i, 2);
        machine_start_indices(machine) = i;
    end
    
    %Find M 
    non_empty_machines = 1:num_machines;
    non_empty_machines(machine_start_indices==0) = [];    
    non_empty_start_indices = machine_start_indices(non_empty_machines);
    padded = [non_empty_start_indices, num_jobs+1];
    
    M = zeros(1,num_machines);
    M(non_empty_machines) = diff(padded);
    
    %Find machine_costs
    machine_costs = zeros(1,num_machines);
    for i = 1:(length(padded)-1)
        start = padded(i);
        finish = padded(i+1) - 1;
        machine_costs(non_empty_machines(i)) = sum(output_array(start:finish,1));
    end

    makespan = max(machine_costs);
    L = find(machine_costs==makespan);
end