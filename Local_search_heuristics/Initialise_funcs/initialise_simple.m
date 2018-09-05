% Author: Brendan Law
% Date: 16th August 2018

% Simple initialisation: (initial jobs -> machines f'n)

% Very basic idea:
% Sort all the jobs from highest to lowest cost
% Allocate first round randomly
% Then allocate highest to lowest based on max(cost) - cost_i
% A given machine's 'relative capacity' to the most utilised machine

function init_alloc = initialise_simple(inputData, num_jobs, num_machines)

input_data_jobs = inputData(1:num_jobs);
input_data_jobs_sorted = sort(input_data_jobs ,'descend');

% Pre-allocate for speed
init_alloc = zeros(num_jobs,2);

% First round allocation (and shorten the sorted jobs list simultaneously)
jobs_allocated = 0;
for i = 1:num_machines
    init_alloc(i,:) = [input_data_jobs_sorted(1), i];
    input_data_jobs_sorted(1) = [];
    jobs_allocated = jobs_allocated + 1;
end

while isempty(input_data_jobs_sorted) ~= 1
    % Evaluate capacity of the allocated rows
    [cap_ordered,sort_indx] = evaluate_capacity(init_alloc(1:jobs_allocated,:), num_machines);
    init_alloc(jobs_allocated + 1,:) = [input_data_jobs_sorted(1), sort_indx(1)];
    input_data_jobs_sorted(1) = [];
    jobs_allocated = jobs_allocated + 1;
end

end