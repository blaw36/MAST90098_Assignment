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
    
    %Find M and machine_costs
    M = zeros(1,num_machines);
    machine_costs = zeros(1,num_machines);
    for i = 1:num_machines
        M(i) = sum(output_array(:,2)==i);
        machine_costs(i) = sum((output_array(:,2)==i) .*output_array(:,1));
    end
    
    makespan = max(machine_costs);
    L = find(machine_costs==makespan);
end