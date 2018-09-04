% Updates the supporting structures
%% Input:
%   %output_array: Assumed to be sorted by machine_num, (then movable)
%       rows - a job allocated to a position in a machine
%       columns - job_cost, machine_num, unique job_id, (movable)
%   %num_machines: the number of machines
%   %num_jobs: the number of jobs
%   %fix_moved: Indicates whether the 4th col of output_array exists and
%       whether moved programs should be flagged as being moved.
%% Ouput:
%   %output_array: The altered output_array
%   %machine_start_indices: The ith value indicates which row of the
%       output_array the ith machine first appears
%   %M: The number of (movable) programs in each machine
%   %machine_costs: The costs of all machines
%   %makespan: The cost of the most loaded machine(s)
%   %L: The machine numbers of all the loaded machines
%%

function ...
[output_array, machine_start_indices, M, machine_costs, makespan, L] ...
    = update_supporting_structs(output_array, num_machines, num_jobs, ...
                                fix_moved)
    if nargin == 3
        fix_moved = false;
    end
    
    %Find where each machine first appears in table (if at all)
    machine_start_indices = zeros(1, num_machines);
    for i = num_jobs:-1:1
        machine = output_array(i, 2);
        machine_start_indices(machine) = i;
    end
    
    %Find the number of movable programs in each machine 
    %and the cost_per_machine
    M = zeros(1,num_machines);
    machine_costs = zeros(1,num_machines);
    for i = 1:(num_machines-1)
        %Finds the slice of programs which are in the ith machine
        slice = [machine_start_indices(i), ...
                machine_start_indices(i+1)-1];
        if slice(1)>0 && slice(2)>0
            machine_costs(i) = sum(output_array(slice(1):slice(2),1));
            if fix_moved
                %number movable programs
                M(i) = sum(output_array(slice(1):slice(2),4));
            else
                %number programs
                M(i) = slice(2) - slice(1) + 1;
            end
        %slice(1)>0 and slice(2) == 0 => remaining jobs are in machine i
        elseif slice(1)>0
            machine_costs(i) = sum(output_array(slice(1):num_jobs,1));
            if fix_moved
                %number movable programs
                M(i) = sum(output_array(slice(1):num_jobs,4));
            else
                %number programs
                M(i) = num_jobs;
            end
        %slice(1)==slice(2)==0 => no programs in machine
        else
            M(i) = 0;
            machine_costs(i) = 0;
        end
    end
    %Slices left out last machine, so considering now
    %Has all remaining programs (possibly 0)
    if machine_start_indices(num_machines) == 0
        M(num_machines) = 0;
        machine_costs(num_machines) = 0;
    else
        last_pos = machine_start_indices(num_machines);
        machine_costs(num_machines) = sum(output_array(last_pos:num_jobs,1));
        if fix_moved
            %number movable programs
            M(num_machines) = sum(output_array(last_pos:num_jobs,4));
        else
            %number programs
            M(num_machines) = num_jobs-last_pos + 1;
        end
    end
    
    makespan = max(machine_costs);
    L = find(machine_costs==makespan);
end
