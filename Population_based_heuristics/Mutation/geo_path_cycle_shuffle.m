%% geo_path_cycle_shuffle
% creates k paths or cycles which randomly moves programs along them
% generate a new machine number for it

% if required, calculate the updated costs of the shuffled individual
% take a log of the elements chosen, and current machine numbers
% take a log of the new machine numbers allocated
% calculate change in cost array if required

% jobs_shuffled is ID of the jobs which were reassigned
% machines_shuffled is m x 2 array
% costs_shuffled is cost of the jobs which have been shuffled (m x 1)
% where m is the number of shuffles done by this mutation

function [indiv_array, costs_shuffled, machines_shuffled] = ...
    geo_path_cycle_shuffle(indiv_array, num_machines, num_jobs, ...
    k, machine_cost_mat, jobs_array_aug)

    cycle_prob = 0.75;
    stop_prob = 0.5;
    %tries to scale k to make this method more comparable to other
    %mutations
    k = max([ceil(k*stop_prob-1*cycle_prob),1]);
        
%     % Pick k distinct initial jobs
%     jobs = randperm(num_jobs,k); % without replacement
%     % and log their current machines
%     jobs_curr_machines = indiv_array(jobs);
    
    % Or Pick the k most costly machines
    [sorted_costs,indices] = sort(machine_cost_mat,'descend');
    % Restrict k to number of non-empty machines
    num_non_empty_machines = sum(sorted_costs > 0);
    k = min(k, num_non_empty_machines);
    jobs_curr_machines = indices(1:k);
%     machine_cost_mat
%     indiv_array


    %Pick the first job for each of these machines
    %https://au.mathworks.com/matlabcentral/answers/22926-finding-the-indices-of-the-elements-of-one-array-in-another
    jobs = arrayfun(@(x)find(x == indiv_array,1), jobs_curr_machines);

    start_machines = jobs_curr_machines;
    %Record these jobs as being changed
    jobs_shuffled = [jobs];
    machines_shuffled = [];
     
    %Set the number of paths_cycles that are currently being moved along
    still_changing = k;
    while still_changing > 0
        % Pick k distinct jobs
        next_jobs = randperm(num_jobs,still_changing); % without replacement
        % Log their machines
        jobs_next_machines = indiv_array(next_jobs);
        
        %Switch the jobs which are in the same machine
        matches = find(jobs_curr_machines == jobs_next_machines);
        while size(matches,2) > 0
            
            % If we are trying to move 1 job, and there is only its own machine
            % possible (perhaps it's the only non-zero machine)
            %%% INSERT BUG FIX HERE

            next_jobs(matches) = randperm(num_jobs,size(matches,2));
            jobs_next_machines(matches) = indiv_array(next_jobs(matches));
            matches = find(jobs_curr_machines == jobs_next_machines);
        end
        
        %Record these jobs as being changed
        jobs_shuffled = [jobs_shuffled,next_jobs];

        % Assign the current jobs to the next machines
        indiv_array(jobs) = jobs_next_machines;

        % Log the changes
        machines_shuffled = [machines_shuffled;...
                             jobs_curr_machines', jobs_next_machines'];
                         
        %Determine whether to stop each path/cycle 
        stop_count = sum((rand(1,still_changing)<stop_prob));
        %De-increment the number still changing
        still_changing = still_changing-stop_count;
        
        %For the ones who are stopping determine whether or not they're
        %cycles
        num_cycles = sum(rand(1,stop_count) < cycle_prob);
        
        if num_cycles>0
            %assign the next jobs to the starting machine for those cycles
            ending_with_cycle_indices = (1+still_changing):(still_changing+num_cycles);
            start_of_cycle = start_machines(ending_with_cycle_indices);
            end_of_cycle = indiv_array(ending_with_cycle_indices);
            indiv_array(ending_with_cycle_indices) = start_of_cycle;

            % Log the changes
            machines_shuffled = [machines_shuffled;...
                                 end_of_cycle', start_of_cycle'];
        end

        % Increment the jobs and their machines
        jobs = next_jobs(1:still_changing);
        jobs_curr_machines = jobs_next_machines(1:still_changing);
    end
    
    if nargin == 5
        % if no jobs_array, don't return costs of shuffled (save some time)
        costs_shuffled = [];
        return
    end
    
    costs_shuffled = jobs_array_aug(jobs_shuffled)';
end
