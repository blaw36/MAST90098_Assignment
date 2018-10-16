%% c_over_rndm_split.m

% Crossover amts are proportional to makespan (lower makespan, more of your
% elements make it. 
% We then create array of 0s and 1s, at randomly selected positions, to
% determine which elements get carried over to the children. The number of
% 1s (number of elements carried over) is equal to the parent's allocation.
%% Inputs:
    % parent_genes: a 2 x num_jobs matrix encoding the location of each job
        % of the parents
    % parent_fitness: a vector of length 2 encoding the fitness of the
        % parents
    % parent_machine_cost: a 2 x num_machines matrix encoding the cost of
        % each machine in the parents.
    % job_costs: the cost of each job
    % num_jobs: the number of jobs
    % num_machines: the number of machines
%
%% Outputs:
    % child_array: a vector encoding which machine each job is in
    % child_machine_cost: a vector encoding the cost of each machine of the
        % child
%%

function [child_array, child_machine_cost] = c_over_rndm_split(...
                    parent_genes, parent_fitness,  ...
                    parent_machine_cost, job_costs,...
                    num_jobs, num_machines)

    % Determine crossover weight - parent with lower makespan gets more
    % elements to the crossover, so use (1 - wt) to allocate crossover
    % position.
    p1_wt = parent_fitness(1)/(parent_fitness(1) + parent_fitness(2));
    num_p1_elmts = ceil(num_jobs*(1-p1_wt));
    
    p1_pass_on = zeros(1,num_jobs);
    
    inherit_indx = randperm(num_jobs, num_p1_elmts);
    p1_pass_on(inherit_indx) = 1;
    p2_pass_on = 1 - p1_pass_on;
    
    child_array = ...
        parent_genes(1,:) .* p1_pass_on + ...
        parent_genes(2,:) .* p2_pass_on;
    
    child_machine_cost = calc_machine_costs(job_costs, ...
            child_array, num_machines);

end