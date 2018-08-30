% Simple initialisation: (initial jobs -> machines f'n)
%
% Very basic idea:
% Sort all the jobs from highest to lowest cost
% Then assigns the job with the highest remaing cost to emtpiest machine
% until all jobs are assigned.

function init_alloc = initialise_simple2(inputData, num_jobs, num_machines)
    job_costs = inputData(1:num_jobs);
    sorted_job_costs = sort(job_costs ,'descend');

    % Pre-allocate for speed
    init_alloc = zeros(num_jobs,2);

    %Stores the current cost per machine.
    machine_costs = [zeros(num_machines,1),(1:num_machines)'];

    % First round allocation
    init_alloc(1:num_machines,:) = ...
            [sorted_job_costs(1:num_machines)',(1:num_machines)'];
    machine_costs(1:num_machines, 1) = sorted_job_costs(1:num_machines);
    
    %Keeps assigning the rest of the jobs until done
    for i = num_machines+1:num_jobs
        %Place the next smallest job into the emptiest machine.
        init_alloc(i,:) = [sorted_job_costs(i), machine_costs(1,2)]; 
        %Place the cost of the next job into the emptiest machine
        machine_costs(1,1) = machine_costs(1,1) + sorted_job_costs(i);
        %TODO: Use a struct which maintains order instead of resorting
        machine_costs = sortrows(machine_costs,1,'ascend');
    end

end