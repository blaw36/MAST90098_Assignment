%% calc_machine_costs.m
% Calcuates the machine_costs of the entire population.

%% Inputs:
    % job_costs: the cost of each job
    % pop_mat: an init_pop_size x num_jobs matrix encoding which machine 
    %   each job of each member of the population is in.
    % num_machines: the number of machines
%% Outputs
    % machine_cost_mat: an init_pop_size x num_machines matrix encoding the
    %   cost of each machine.
%%
function [machine_cost_mat] = calc_machine_costs(job_costs, pop_mat, ...
    num_machines)

    jobs_array_transpose = job_costs';
    machine_cost_mat = zeros(size(pop_mat,1), num_machines);
    for j = 1:num_machines
        %Find the jobs in each machine for each pop member and add their
        %costs
        indicator_mat = double((pop_mat == j));
        machine_cost_mat(:,j) = indicator_mat * jobs_array_transpose;
    end
end