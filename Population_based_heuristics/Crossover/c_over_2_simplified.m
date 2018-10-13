%% c_over_2_simplified.m

% like c_over_2, but picks from least fit machine first (parameterised 
% proportion) and then all remaining non colliding from most fit machine

function [child_array, child_machine_cost] = c_over_2_simplified(parent_genes, ...
                    parent_fitness, parent_machine_cost, jobs_array_aug,...
                    num_jobs, num_machines, less_fit_c_over_machs)

    child_array = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);
    child_machine = 1;
    child_indices = randperm(num_machines,num_machines);
    
    all_jobs = 1:num_jobs;
    un_assigned_jobs = all_jobs;
    
    %Find and record the least_fit_parent, occasionaly switch which parent
    %is treated as which, for the sake of noise (Might be a better way to
    %inject noise, or maybe shouldn't even be here)
    
     % Faster than 'min' function in this case, for two parents
    if parent_fitness(1) < parent_fitness(2)
        least_fit_parent = 1;
    else
        least_fit_parent = 2;
    end
%     [~, least_fit_parent] = min(parent_fitness);

    if rand<0.1
        least_fit_parent = 1 + mod(least_fit_parent,2);
    end
    most_fit_parent = 1 + mod(least_fit_parent,2);
    
    % Allocate some arbitrary amount to least fit parent first, then
    % allocate all non-collisions to the most fit out of the remaining
    % machines
    props = [1/3,1/3];
    props(least_fit_parent) = less_fit_c_over_machs;
    props(most_fit_parent) = 1;
    
    most_fit_machines = sort(randperm(num_machines,...
        ceil(props(most_fit_parent)*num_machines)));
    least_fit_machines = sort(randperm(num_machines,...
        ceil(props(least_fit_parent)*num_machines)));
    
    % if least_fit_parent == 1
    %     most_fit_machines = p2_machines;
    % else
    %     most_fit_machines = p1_machines;
    % end
    
    %Find all jobs in each parent subset
    most_fit_job_vec = double(ismembc(parent_genes(most_fit_parent,:),most_fit_machines));
    least_fit_job_vec = double(ismembc(parent_genes(least_fit_parent,:),least_fit_machines));
    
    collisions = most_fit_job_vec.*least_fit_job_vec; 
    %This also includes zero, but can just ignore this
    
    % https://stackoverflow.com/questions/8174578/faster-way-to-achieve-unique-in-matlab-if-assumed-1d-pre-sorted-vector
    tmp = sort(collisions.*parent_genes(most_fit_parent,:));
    most_fit_parent_collision_machines = tmp([true;diff(tmp(:))>0]);
    
    % Find all of the machines in the subset of the most fit parents
    % machines that are not involved in collisions
    non_col_machines = most_fit_machines(...
        ~ismembc(most_fit_machines, most_fit_parent_collision_machines));

    if 1 == least_fit_parent
        p2_machines = sort(non_col_machines);
        p1_machines = least_fit_machines;
%         p1_job_vec = double(ismembc(parent_genes(1,:),p1_machines));
    else
        p1_machines = sort(non_col_machines);
        p2_machines = least_fit_machines;
%         p2_job_vec = double(ismembc(parent_genes(2,:),p2_machines));
    end

    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    %Can move this somewhere else later
    p_machines = zeros(2, num_machines);
    p_machines(1,p1_machines) = 1;
    p_machines(2,p2_machines) = 1;
    
    for j = 1:2
        for i = 1:num_machines
            if ~p_machines(j,i)
                continue
            end
            parent_machine = i;
            parent_machine_jobs = sort(all_jobs(parent_genes(j,:)==parent_machine));
            if isempty(parent_machine_jobs)
                continue
            end

            child_array(parent_machine_jobs) = child_indices(child_machine);
            child_machine_cost(child_indices(child_machine)) = ...
                        parent_machine_cost(j, parent_machine);
            child_machine = child_machine + 1;
        end
    end
    %Check which jobs still need to be assigned
    un_assigned_jobs = all_jobs(~child_array);
                      
    % Assign the remaining jobs
    % Leaving it as is corresponds to greedy,(due to how jobs have been 
    % sorted) seems the best    
    for job = un_assigned_jobs
        [cost, loc] = min(child_machine_cost);
        child_array(job) = loc;
        child_machine_cost(loc) = cost + jobs_array_aug(job); 
    end              
                
end