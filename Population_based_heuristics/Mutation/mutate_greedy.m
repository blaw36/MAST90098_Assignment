%% mutate_greedy.m
% pick k jobs remove them then add them back in greedily
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
                    mutate_greedy(indiv_array, num_machines, num_jobs, ...
                                  machine_cost_mat, job_costs, k)

    % Pick k distinct jobs
    jobs = randperm(num_jobs,k);
    [~,jobs] = sort(job_costs(jobs));
    
    %Remove them from their current machines
    for i = 1:k
        machine_cost_mat(indiv_array(jobs(i))) = ...
            machine_cost_mat(indiv_array(jobs(i)))-job_costs(jobs(i));
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
        machine_cost_mat(loc) = cost + job_costs(job); 
    end
end