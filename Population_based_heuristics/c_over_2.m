%% c_over_2.m
% Same general idea as in c_over_1 but do it faster.


function child_array = c_over_2(parent_pair, parent_genes, ...
                    parent_fitness, parent_machine_cost, jobs_array_aug,...
                    num_jobs, num_machines)

    child_array = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);
    
    all_jobs = 1:num_jobs;
    un_assigned_jobs = 1:num_jobs;
    
    [~, least_fit_parent] = min(parent_fitness);
    
    %Pick an initial random subset of machines from both parents, could do
    %this based off fitness, but some fixed frac of each would also do.
    
    %Over-allocate to prop to least fit parent
    props = [1/3,1/3];
    props(least_fit_parent) = 1/2;
    
    p1_machines = randperm(num_machines,ceil(props(1)*num_machines));
    p2_machines = randperm(num_machines,ceil(props(2)*num_machines));
    
    if least_fit_parent == 1
        least_fit_machines = p1_machines;
    else
        least_fit_machines = p2_machines;
    end
    %Find all jobs in each parent subset
    % Hard to use ismembc here as sorting would disrupt things...
    p1_job_vec = ismember(parent_genes(1,:),p1_machines);
    p2_job_vec = ismember(parent_genes(2,:),p2_machines);
    
    collisions = p1_job_vec.*p2_job_vec; 
    
    %parent_genes(least_fit_parent,:)
    %This also includes zero, but can just ignore this
    least_fit_parent_collision_machines = ...
        unique(collisions.*parent_genes(least_fit_parent,:));
    
    % Can use ismembc here! unique sorts
    % least_fit_parent_collision_machines
    % We just need to sort least_fit_machines, which isn't a problem, as it
    % is just giving us a set of machines - the order won't mean anything.
    least_fit_machines = sort(least_fit_machines);
    non_col_machines = least_fit_machines(...
        ~ismembc(least_fit_machines,...
                  least_fit_parent_collision_machines));

%     non_col_machines = least_fit_machines(...
%             ~ismember(least_fit_machines,...
%                       least_fit_parent_collision_machines));
                  
    if 1 == least_fit_parent
        p1_machines = non_col_machines;
    else
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