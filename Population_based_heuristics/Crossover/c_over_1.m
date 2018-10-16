%% c_over_1.m
% Produces a child from 2 parents, using information on how the parents
% pack entire machines.
%
% Idea of this alg was to use the information in the parents more
% effectively. We know when close to optimal that each machine will be more
% or less balanced in terms of cost.
% So in a good parent, each machine assignment will be more or less good.
% So we shuffle all of the machines of each parent, then draw from these
% shuffled machines assigning all of the jobs from each of these drawn
% machines. However we only assign jobs from the parent machine if all of 
% the jobs in the machine haven't been assigned in the child.
%
% Eventually we will get to a state with several unassigned jobs remaining,
% then just assign the costliest job to the least full machine until done.
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

function [child_array, child_machine_cost] = c_over_1(parent_genes, ...
                    parent_fitness, parent_machine_cost, job_costs,...
                    num_jobs, num_machines)

    child_array = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);
    
    all_jobs = 1:num_jobs;
    un_assigned_jobs = 1:num_jobs;
    ordered_m_parents = [randperm(num_machines,num_machines);
                         randperm(num_machines,num_machines)];
    
    %Pick the most fit parent first
    [~, current_parent] = max(parent_fitness);
    %Measures proportion of fitness each parent carries
    fitness_ratio = parent_fitness/sum(parent_fitness);
    %Normalizes so can treat as prob
    fitness_ratio = fitness_ratio/sum(fitness_ratio);
    
    %Shuffle the order of the assigned machine numbers of the child
    child_machine = 1;
    child_indices = randperm(num_machines,num_machines);
    
    parent_indices = [1,1];
    
    while child_machine <= num_machines && any(parent_indices <= num_machines)
        done = false;
        parent_index = parent_indices(current_parent);
        while parent_index <= num_machines && ~done
            
            %Retrieve the parent machine and the jobs in it
            parent_machine = ordered_m_parents(current_parent,parent_index);
            parent_machine_jobs =  sort(all_jobs(...
                parent_genes(current_parent,:)==parent_machine));
            
            %Check if all these jobs in the parent machine are currently
            %un_assigned (and the parent machine is not empty)            
           if ~isempty(parent_machine_jobs) && ...
                all(ismembc(parent_machine_jobs, un_assigned_jobs))
                % if so, assign those jobs and mark being done
                done = true;
                un_assigned_jobs = un_assigned_jobs(...
                        ~ismembc(un_assigned_jobs,parent_machine_jobs));

                %Assign the child all of the jobs in the machine, but
                %re-index the machines
                child_array(parent_machine_jobs) = child_indices(child_machine);
                child_machine_cost(child_indices(child_machine)) = ...
                    parent_machine_cost(current_parent, parent_machine);
                child_machine = child_machine + 1;
           end
           parent_index = parent_index + 1;
        end
        %Record current index
        parent_indices(current_parent) = parent_index;
        %Switch parent if rand numb exceeds fitness ratio
        if rand > fitness_ratio(current_parent)
            current_parent = 1 + mod(current_parent,2);
        end
    end
    
    % Assign the remaining jobs,
    % As the jobs are ordered by costs, this corresponds to putting the
    % highest cost job into the emptiest machine.
    for job = un_assigned_jobs
        [cost, loc] = min(child_machine_cost);
        child_array(job) = loc;
        child_machine_cost(loc) = cost + job_costs(job); 
    end
end