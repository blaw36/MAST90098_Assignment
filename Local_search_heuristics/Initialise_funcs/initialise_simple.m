% Places the biggest program into the emptiest machine until done
%% initialise_simple.m
% A script which initialises a solution by allocating costliest job from
% machine 1 through to m. Once each machine has one job, it then allocates
% costliest job to machine with lowest current total cost.
%% Input:
    % input_array: n+1 length vector of job costs, and n+1th element is 
        % # of machines
    % num_jobs: the number of jobs
    % num_machines: the number of machines   
%% Output:
    % init_alloc: left two columns of output_array
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_no
%%

function init_alloc = initialise_simple(input_array, num_jobs, num_machines)
    
    % Sorts the jobs biggest to smallest
    job_costs = input_array(1:num_jobs);
    sorted_job_costs = sort(job_costs, 'descend');

    % Pre-allocate for speed
    init_alloc = zeros(num_jobs,2);

    % Stores the current cost per machine.
    machine_costs = [zeros(num_machines,1),(1:num_machines)'];

    % First round allocation
    init_alloc(1:num_machines,:) = ...
            [sorted_job_costs(1:num_machines)',(1:num_machines)'];
    machine_costs(1:num_machines, 1) = sorted_job_costs(1:num_machines);
    
    %Keeps assigning the rest of the jobs until done
    for i = num_machines+1:num_jobs
        [cost, loc] = min(machine_costs(:,1));
        init_alloc(i,:) = [sorted_job_costs(i), loc];
        machine_costs(loc,1) = cost + sorted_job_costs(i);
    end
end