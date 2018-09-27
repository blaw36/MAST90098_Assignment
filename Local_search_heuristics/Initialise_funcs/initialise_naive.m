%% initialise_naive.m
% A script which initialises a solution by allocating all jobs to machine
% number 1.

%% Input:
    % input_array: n+1 length vector of job costs, and n+1th element is # of
        % machines
    % num_jobs: the number of jobs
    
%% Output:
    % init_alloc: left two columns of output_array
        % rows - a job allocated to a position in a machine
        % columns - job_cost, machine_no
%%

function init_alloc = initialise_naive(input_array, num_jobs)

input_data_jobs = input_array(1:num_jobs);

% Pre-allocate for speed
init_alloc = zeros(num_jobs,2);

init_alloc(:,1) = input_data_jobs';
init_alloc(:,2) = 1;

end