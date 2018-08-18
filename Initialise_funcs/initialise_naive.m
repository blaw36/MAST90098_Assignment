% Author: Brendan Law
% Date: 19th August 2018

% Naive initialisation:  (initial jobs -> machines f'n)
    % All jobs go to machine 1

function init_alloc = initialise_naive(inputData, num_jobs)

input_data_jobs = inputData(1:num_jobs);

% Pre-allocate for speed
init_alloc = zeros(num_jobs,2);

init_alloc(:,1) = input_data_jobs';
init_alloc(:,2) = 1;

end