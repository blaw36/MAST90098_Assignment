%% mutate_greedy_refactor.m
% pick k jobs remove them then add them back in greedily
%

function [indiv_array, machine_cost_mat] = ...
            mutate_greedy_refactor(indiv_array, num_machines, num_jobs, ...
                                    k, machine_cost_mat, jobs_array_aug)

    % Pick k distinct jobs
    jobs = randperm(num_jobs,k);
    [~,jobs] = sort(jobs_array_aug(jobs));
    
    %Remove them from their current machines
    for i = 1:k
        machine_cost_mat(indiv_array(jobs(i))) = ...
            machine_cost_mat(indiv_array(jobs(i)))-jobs_array_aug(jobs(i));
    end
    
    %Assign jobs to their new machines
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
    end
end