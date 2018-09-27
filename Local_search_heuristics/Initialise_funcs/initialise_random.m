%% initialise_random.m
% A script which initialises a solution by randomly allocating jobs to
% machines.

%% Input:
    % input_array: n+1 length vector of job costs, and n+1th element is # of
        % machines
    % num_jobs: the number of jobs
    % num_machines: the number of machines
    
%% Output:
    % init_alloc: left two columns of output_array
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_no
%%

function init_alloc = initialise_random(input_array, num_jobs, num_machines)

input_data_jobs = input_array (1:num_jobs);

% Pre-allocate for speed
init_alloc = zeros(num_jobs,2);

init_alloc(:,1) = input_data_jobs';
init_alloc(:,2) = randi(num_machines,num_jobs,1);

end