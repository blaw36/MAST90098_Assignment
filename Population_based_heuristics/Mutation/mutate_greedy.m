%% mutate_greedy.m
% pick k jobs remove them then add them back in greedily
%
% A lot of the cost calcs here are calculated later in mutate population,
% so duplication of effort.
% also wouldn't need current_assign new_assign if doing cost calcs in here
% so time cost of this function isn't as bad as it looks with a bit of a
% refactor

function [indiv_array, costs_shuffled, machines_shuffled] = ...
                mutate_greedy(indiv_array, num_machines, num_jobs, ...
                              k, machine_cost_mat, jobs_array_aug)

    % Pick k distinct jobs
    jobs = randperm(num_jobs,k);
    [~,jobs] = sort(jobs_array_aug(jobs));
    
    % Log current machines
    current_assign = indiv_array(jobs);
    
    %Remove them from their current machines
    for i = 1:k
        machine_cost_mat(current_assign(i)) = ...
            machine_cost_mat(current_assign(i))-jobs_array_aug(jobs(i));
    end
    
    %Assign jobs to their new machines
    new_assign = [];
    for job = jobs
        %Want some degree of noise
        if rand < 0.8
            %Place in emptiest machine
            [cost, loc] = min(machine_cost_mat);
        else
            %Place in random machine
            loc = randi(num_machines,1);
            cost = machine_cost_mat(loc);
        end
        indiv_array(job) = loc;
        machine_cost_mat(loc) = cost + jobs_array_aug(job); 
        
        new_assign = [new_assign,loc];
    end
    
    if nargin == 5
        % if no jobs_array, don't return costs of shuffled (save some time)
        costs_shuffled = [];
        return
    end
    
    % Log the changes
    machines_shuffled = [current_assign', new_assign'];
    costs_shuffled = jobs_array_aug(jobs)';
    
end
