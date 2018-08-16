% Author: Brendan Law
% Date: 16th August 2018

% Function to initialise job allocations

% Very basic idea:
% Sort all the jobs from highest to lowest cost
% Allocate first round randomly
% Then allocate highest to lowest based on max(cost) - cost_i
% A given machine's 'relative capacity' to the most utilised machine

function init_alloc = initialise_simple(inputData)

input_data_jobs = inputData(1:(end-1));
input_data_jobs_sorted = sort(input_data_jobs ,'descend');

% First round allocation (and shorten the sorted jobs list simultaneously)
    for i = 1:inputData(end)
        init_alloc(i,:) = [input_data_jobs_sorted(1), i, 1];
        input_data_jobs_sorted(1) = [];
    end

    while isempty(input_data_jobs_sorted) ~= 1
        [cap_ordered,sort_indx] = evaluate_capacity(init_alloc);
%         init_alloc = init_alloc(sort_indx);
        init_alloc(end+1,:) = [input_data_jobs_sorted(1), sort_indx(1), 1];
        % Need to then add job ids to each.
        input_data_jobs_sorted(1) = []; 
    end

end