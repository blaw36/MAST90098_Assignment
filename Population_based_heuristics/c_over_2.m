%% c_over_2.m
% Same general idea as in c_over_1 but do it faster.


function child_array = c_over_1(parent_pair, parent_genes, ...
                    parent_fitness, parent_machine_cost, jobs_array_aug,...
                    num_jobs, num_machines)

    child_array = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);
    
    all_jobs = 1:num_jobs;
    un_assigned_jobs = 1:num_jobs;
    
    %Pick an initial random subset of machines from both parents, could do
    %this based off fitness, but some fixed frac of each would also do.
    prop_1 = 1/3;
    prop_2 = 1/3;
    
    ordered_m_parents = [randperm(num_machines,ceil(prop_1*num_machines));
                         randperm(num_machines,ceil(prop_2*num_machines))];
                     
    %Find all jobs in each parent subset
    p1_job_vec = ismember(parent_genes(1,:),ordered_m_parents(1,:));
    p2_job_vec = ismember(parent_genes(2,:),ordered_m_parents(2,:));
    
    collisions = p1_job_vec.*p2_job_vec;
    
    %Then want to pick the least fit parent and remove all of the machines
    %from the least fit parent that are involved in a collision
    [~, least_fit_parent] = min(parent_fitness); 
    
    %parent_genes(least_fit_parent,:)
    %This also includes zero, but can just ignore this
    least_fit_parent_collision_machines = ...
        unique(collisions.*parent_genes(least_fit_parent,:));
    
    non_col_machines = ordered_m_parents(least_fit_parent,...
            ~ismember(ordered_m_parents(least_fit_parent,:),...
                      least_fit_parent_collision_machines));
                  
    if 1 == least_fit_parent
        p1_machines = non_col_machines;
        p2_machines = ordered_m_parents(2,:);
    else
        p1_machines =  ordered_m_parents(1,:);
        p2_machines = non_col_machines;
    end
    
    %Assign the collision free parent machines to child
    for parent_machine = p1_machines
        parent_machine_jobs =  all_jobs(...
            parent_genes(1,:)==parent_machine);
        child_array(parent_machine_jobs) = parent_machine;
        child_machine_cost(parent_machine) = ...
                    parent_machine_cost(1, parent_machine);
    end
    
    for parent_machine = p2_machines
        parent_machine_jobs =  all_jobs(...
            parent_genes(1,:)==parent_machine);
        child_array(parent_machine_jobs) = parent_machine;
        child_machine_cost(parent_machine) = ...
                    parent_machine_cost(2, parent_machine);
    end
    
%     child_array
%     child_machine_cost
    
    % Assign the remaining jobs
    % Leaving it as is corresponds to greedy,(due to how jobs have been 
    % sorted) seems the best
    
    %Shuffle had alright performance (could be better)
    %un_assigned_jobs = un_assigned_jobs(randperm(length(un_assigned_jobs)));
    
    for job = un_assigned_jobs
        [cost, loc] = min(child_machine_cost);
        child_array(job) = loc;
        child_machine_cost(loc) = cost + jobs_array_aug(job); 
    end
end