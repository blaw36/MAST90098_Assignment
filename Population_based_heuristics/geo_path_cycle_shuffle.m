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
    k, jobs_array_aug)

    cycle_prob = 0.75;
    stop_prob = 0.5;
    %tries to scale k to make this method more comparable to other
    %mutations
    k = ceil(k*stop_prob-1*cycle_prob);
    
    % Pick k distinct initial jobs
    jobs = randperm(num_jobs,k); % without replacement
    % and log their current machines
    jobs_curr_machines = indiv_array(jobs);
    start_machines = jobs_curr_machines;
    %Record these jobs as being changed
    jobs_shuffled = [jobs];
    machines_shuffled = [];
    
    %Set the number of paths_cycles that are currently being moved along
    still_changing = k;
    while still_changing > 0
        % Pick k distinct jobs
        next_jobs = randperm(num_jobs,still_changing); % without replacement
        %Record these jobs as being changed
        jobs_shuffled = [jobs_shuffled,next_jobs];

        % Log their machines
        jobs_next_machines = indiv_array(next_jobs);
    
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
            ending_with_cycle_indices = (1+still_changing):(1+still_changing+num_cycles-1);
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
    
    if nargin == 4
        % if no jobs_array, don't return costs of shuffled (save some time)
        costs_shuffled = [];
        return
    end
    
    costs_shuffled = jobs_array_aug(jobs_shuffled)';
end
