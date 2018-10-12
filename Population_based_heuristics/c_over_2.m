%% c_over_2.m
% Same general idea as in c_over_1 but do it faster.

% Can be vectorized better and inside --- probably improvable by a fair chunk---
% p1_machines and p2_machines different sizes, maybe a partially empty
% array is the best choice?...


function [child_array, child_machine_cost] = c_over_2(parent_genes, ...
                    parent_fitness, parent_machine_cost, jobs_array_aug,...
                    num_jobs, num_machines)
                
    child_array = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);
    child_machine = 1;
    child_indices = randperm(num_machines,num_machines);
    
    all_jobs = 1:num_jobs;
    un_assigned_jobs = all_jobs;
    
    [~, least_fit_parent] = min(parent_fitness);
    if rand<0.1
        least_fit_parent = 1 + mod(least_fit_parent,2);
    end
    most_fit_parent = 1 + mod(least_fit_parent,2);
    
    
    %Pick an initial random subset of machines from both parents, could do
    %this based off fitness, but some fixed frac of each would also do.
    
    %Over-allocate to least fit parent, as remove from it later
    props = [1/3,1/3];
    props(least_fit_parent) = 1/2;
    
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
    
    collisions = p1_job_vec.*p2_job_vec; 
    %This also includes zero, but can just ignore this
    least_fit_parent_collision_machines = ...
        unique(collisions.*parent_genes(least_fit_parent,:));
    
    non_col_machines = least_fit_machines(...
            ~ismembc(least_fit_machines,...
                      least_fit_parent_collision_machines));
                  
    if 1 == least_fit_parent
        p1_machines = sort(non_col_machines);
        p1_job_vec = double(ismembc(parent_genes(1,:),p1_machines));
    else
        p2_machines = sort(non_col_machines);
        p2_job_vec = double(ismembc(parent_genes(2,:),p2_machines));
    end
    
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %TODO: Better faster way
    %Add back in all the machines from most fit parent, that don't
    %make any collisions
    
    %no collisions so can just add
    union_jobs = p1_job_vec + p2_job_vec;
    
    %a = all machines from most fit parent with at least one job not in the
    %union
    a = (double(~union_jobs).*parent_genes(most_fit_parent,:));
    %b = all machines from most fit parent with at least one job in the
    %union
    b = unique(union_jobs.*parent_genes(most_fit_parent,:));
    added_machines = unique(a(~ismembc(a,b)));
    
    if most_fit_parent == 1
        p1_machines = sort([p1_machines,added_machines]);
    else
        p2_machines = sort([p2_machines,added_machines]);
    end
    
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    %Assign the collision free parent machines to child
    for i = 1:length(p1_machines)
        parent_machine = p1_machines(i);
        parent_machine_jobs = sort(all_jobs(parent_genes(1,:)==parent_machine));
        if isempty(parent_machine_jobs)
            continue
        end
        
        child_array(parent_machine_jobs) = child_indices(child_machine);
        child_machine_cost(child_indices(child_machine)) = ...
                    parent_machine_cost(1, parent_machine);
        child_machine = child_machine + 1;
        
        un_assigned_jobs = un_assigned_jobs(...
                        ~ismembc(un_assigned_jobs,parent_machine_jobs));
    end
    
    for i = 1:length(p2_machines)
        if child_machine > num_machines
            break
        end
        
        parent_machine = p2_machines(i);
        parent_machine_jobs = sort(all_jobs(parent_genes(2,:)==parent_machine));
        if isempty(parent_machine_jobs)
            continue
        end
        
        child_array(parent_machine_jobs) = child_indices(child_machine);
        child_machine_cost(child_indices(child_machine)) = ...
                    parent_machine_cost(2, parent_machine);
        child_machine = child_machine + 1;
        
       un_assigned_jobs = un_assigned_jobs(...
                        ~ismembc(un_assigned_jobs,parent_machine_jobs));
    end
    
    % Assign the remaining jobs
    % Leaving it as is corresponds to greedy,(due to how jobs have been 
    % sorted) seems the best    
    for job = un_assigned_jobs
        [cost, loc] = min(child_machine_cost);
        child_array(job) = loc;
        child_machine_cost(loc) = cost + jobs_array_aug(job); 
    end
end