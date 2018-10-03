%% shuffle_rndom_mach_chg
% pick k elements of the machine array
% generate a new machine number for it

% if required, calculate the updated costs of the shuffled individual
% take a log of the elements chosen, and current machine numbers
% take a log of the new machine numbers allocated
% calculate change in cost array if required

% jobs_shuffled is ID of the jobs which were reassigned
% machines_shuffled is k x 2 array, for each of the k re-assignments,
% mentions machine from and machine to.
% costs_shuffled is cost of the jobs which have been shuffled (k x 1)

function [indiv_array, costs_shuffled, machines_shuffled] = ...
    shuffle_rndom_mach_chg(indiv_array, num_machines, num_jobs, ...
    k, jobs_array_aug)
    
    % Pick k distinct jobs
%     jobs_shuffled = randi(num_jobs,1,k);
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
    
    costs_shuffled = jobs_array_aug(jobs_shuffled)';
    
end
