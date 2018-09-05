% Author: Brendan Law
% Date: 19th August 2018

% Random initialisation:  (initial jobs -> machines f'n)
    % Each job is randomly allocated to a machine

function init_alloc = initialise_random(inputData, num_jobs, num_machines)

input_data_jobs = inputData(1:num_jobs);

% Pre-allocate for speed
init_alloc = zeros(num_jobs,2);

init_alloc(:,1) = input_data_jobs';
init_alloc(:,2) = randi(num_machines,num_jobs,1);

end