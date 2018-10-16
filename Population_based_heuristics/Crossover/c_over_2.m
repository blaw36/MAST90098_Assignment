%% c_over_2.m
% Produces a child from 2 parents, using information on how the parents
% pack entire machines.
% Pick an initial proportion of machines of both parents,
% find all collisions of jobs between those machines,
% remove the machines from the least fit parent that cause the collisions,
% add as many machines as you can from the most fit parent that do not
%   cause new collisions
% Greedily place the remaining jobs
%
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
    % least_fit_proportion: the initial proportion of machines assigned to
        % the child from the least fit parent
    % most_fit_proportion: the initial proportion of machines assigned to
        % the child from the most fit parent
    % prob_switch_parent_fitness: the probability of switching which parent
        % considered the least fit.
%
%% Outputs:
    % child_array: a vector encoding which machine each job is in
    % child_machine_cost: a vector encoding the cost of each machine of the
        % child
%%
function [child_array, child_machine_cost] = c_over_2(parent_genes, ...
                    parent_fitness, parent_machine_cost, job_costs,...
                    num_jobs, num_machines, ...
                    least_fit_proportion, most_fit_proportion,...
                    prop_switch_parent_fitness)
    
    %Least fit parent is on left
    least_fit_parent = 1;
    %Inject a little bit of noise
    if rand<prop_switch_parent_fitness
        least_fit_parent = 2;
    end
    most_fit_parent = 1 + mod(least_fit_parent,2);
    
    %Set proportions
    props = [most_fit_proportion,most_fit_proportion];
    props(least_fit_parent) = least_fit_proportion;
    
    %Randomly pick machines from each parent.
    p1_machines = sort(randperm(num_machines,ceil(props(1)*num_machines)));
    p2_machines = sort(randperm(num_machines,ceil(props(2)*num_machines)));
    
    if least_fit_parent == 1
        least_fit_machines = p1_machines;
    else
        least_fit_machines = p2_machines;
    end
    
    %Find all jobs in each parent subset
    p1_job_vec = double(ismembc(parent_genes(1,:),p1_machines));
    p2_job_vec = double(ismembc(parent_genes(2,:),p2_machines));
    
    %Find job collisions
    collisions = p1_job_vec.*p2_job_vec; 
    
    % Fast way to find unique collisions stemming from
    % https://stackoverflow.com/questions/8174578/faster-way-to-achieve-unique-in-matlab-if-assumed-1d-pre-sorted-vector
    tmp = sort(collisions.*parent_genes(least_fit_parent,:));
    least_fit_parent_collision_machines = tmp([true;diff(tmp(:))>0]);
    
    %Find all of the machines in the subset of the least fit parents
    %machines that are not involved in collisions
    non_col_machines = least_fit_machines(...
        ~ismembc(least_fit_machines, least_fit_parent_collision_machines));
    
    %Update stored machines
    if 1 == least_fit_parent
        p1_machines = sort(non_col_machines);
        p1_job_vec = double(ismembc(parent_genes(1,:),p1_machines));
    else
        p2_machines = sort(non_col_machines);
        p2_job_vec = double(ismembc(parent_genes(2,:),p2_machines));
    end
    
    %Add back in all the machines from most fit parent, that don't
    %make any new collisions
    
    %no collisions so can just add
    union_jobs = p1_job_vec + p2_job_vec;
    
    %a = all machines from most fit parent with at least one job not in the
    %union
    a = ((1-union_jobs).*parent_genes(most_fit_parent,:));

    %b = all machines from most fit parent with at least one job in the
    %union
    tmp = sort(union_jobs.*parent_genes(most_fit_parent,:));
    b = tmp([true;diff(tmp(:))>0]);
    % once again making use of 
    % https://stackoverflow.com/questions/8174578/faster-way-to-achieve-unique-in-matlab-if-assumed-1d-pre-sorted-vector
    tmp = sort(a(~ismembc(a,b)));
    if ~isempty(tmp)
        added_machines = tmp([true;diff(tmp(:))>0]);
    else
        added_machines = [];
    end

    %Update the most fit parent
    if most_fit_parent == 1
        p1_machines = sort([p1_machines,added_machines]);
    else
        p2_machines = sort([p2_machines,added_machines]);
    end
    
    child_array = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);
    %Shuffle the order of the assigned machine numbers of the child
    child_machine = 1;
    child_machine_indices = randperm(num_machines,num_machines);
    
    %Construct an indicator matrix indicating which machines are being used
    p_machines = zeros(2, num_machines);
    p_machines(1,p1_machines) = 1;
    p_machines(2,p2_machines) = 1;
    
    for p = 1:2
        for m = 1:num_machines
            if ~p_machines(p,m)
                continue
            end
            
            %If we encounter a machine with no jobs in it don't add it
            if ~parent_machine_cost(p, m)
                continue
            end
            
            % Assign all of the jobs of the parent machine to the next
            % child machine
            child_array(parent_genes(p,:)==m) = child_machine_indices(child_machine);
            child_machine_cost(child_machine_indices(child_machine)) = parent_machine_cost(p, m);
            child_machine = child_machine + 1;
            
            if child_machine>num_machines
                break
            end
        end
    end
    
    %Check which jobs still need to be assigned
    all_jobs = 1:num_jobs;
    un_assigned_jobs = all_jobs(~child_array);
                      
    % Assign the remaining jobs,
    % As the jobs are ordered by costs, this corresponds to putting the
    % highest cost job into the emptiest machine.
    for job = un_assigned_jobs
        [cost, loc] = min(child_machine_cost);
        child_array(job) = loc;
        child_machine_cost(loc) = cost + job_costs(job); 
    end
end