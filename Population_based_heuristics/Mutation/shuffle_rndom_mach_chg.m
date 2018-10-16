%% shuffle_rndom_mach_chg.m
% generate new machines for k jobs
%% Input:
    % indiv_array: a 1 x num_jobs vector encoding the job locations
    % num_machines: the number of machines
    % num_jobs: the number of jobs
    % machine_cost_mat :a 1 x num_machines vec encoding the machine costs
    % job_costs: the cost of each job
    % k: the number of jobs to move
%% Output:
    % indiv_array: a 1 x num_jobs vector encoding the job locations
    % machine_cost_mat :a 1 x num_machines vec encoding the machine costs
%%

function [indiv_array, machine_cost_mat] = ...
    shuffle_rndom_mach_chg(indiv_array, num_machines, num_jobs, ...
                           machine_cost_mat, job_costs, k)
    
    % Pick k distinct jobs
    jobs_shuffled = randperm(num_jobs,k); % without replacement
    
    % Log current machines
    current_assign = indiv_array(jobs_shuffled);
    
    % Reassign machines make sure each is assigned to a new machine
    new_assign = randi(num_machines,1,k);
    matches = find(new_assign == current_assign);
    while size(matches,2) > 0
        new_assign(matches) = randi(num_machines,1,size(matches,2));
        matches = find(new_assign == current_assign);
    end
    % Make the change
    indiv_array(jobs_shuffled) = new_assign;
    
    % Log the changes
    machines_shuffled = [current_assign', new_assign'];
    
    if nargin == 4
        % if no jobs_array, don't return costs of shuffled (save some time)
        costs_shuffled = [];
        return
    end
    
    costs_shuffled = job_costs(jobs_shuffled)';
    
    % Update Costs
    changes = zeros(size(costs_shuffled,1),num_machines);
        for j = 1:size(machines_shuffled,1)
            changes(j,machines_shuffled(j,:)) = ...
                [-costs_shuffled(j,:), costs_shuffled(j,:)];
        end
    changes = sum(changes, 1);
    machine_cost_mat = machine_cost_mat + changes;
end
