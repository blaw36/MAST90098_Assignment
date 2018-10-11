%% shuffle_rndom_mach_chg_load
% like the rndom_mach_chg, but now:

% Do it such that more loaded machines are more likely to have stuff
% removed, less loaded more likely to have stuff allocated

function [indiv_array, costs_shuffled, machines_shuffled] = ...
    shuffle_rndom_mach_chg_load(indiv_array, num_machines, num_jobs, ...
    k, indiv_costs, jobs_array_aug)
    
    % Pick k distinct jobs - higher cost, higher prob
    increasing_probs = fitness_negexp(indiv_costs, true);
    % Alter the indiv_costs array so they reflect probs of the machine
    % numbers
    indiv_array_inc_probs = increasing_probs(indiv_array);
    % Hard to incorporate probs without replacement, so incl for now
    % Also means we could pick several 
    jobs_shuffled = randsample(1:num_jobs,k,true,indiv_array_inc_probs);
    
    % Log current machines
    current_assign = indiv_array(jobs_shuffled);
    
    % Reassign machines make sure each is assigned to a new machine
    % Probabilities go the other way this time
    decreasing_probs = fitness_negexp(indiv_costs, false);
    new_assign = randsample(1:num_machines,k,true,decreasing_probs);
    
    % Preventing matches here may be difficult - disregard
%     matches = find(new_assign == current_assign);
%     while size(matches,2) > 0
%         new_assign(matches) = randi(num_machines,1,size(matches,2));
%         matches = find(new_assign == current_assign);
%     end
    
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
