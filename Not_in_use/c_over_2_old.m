%% c_over_2_old.m

%% As of night of Saturday 13th, Oct 2018

% Pick an initial proportion of machines of both parents,
% find all collisions of jobs between those machines,
% remove the machines from the least fit parent that cause the collisions,
% add as many machines as you can from the most fit parent that do not
    % cause new collisions
% Greedily place the remaining jobs

% Feels like it should be improveable
% largest point of difficulty is that p1_machines and p2_machines are of
% different sizes
    % I tried, using partially empty matrices padded with 0s to store them, 
        % but slicing by their true sizes, generated too much overhead.
            % --Maybe if better way of getting values that some how ignored
            % certain values (0s or some other flag) instead of slicing
     % I tried, using structs eg p{2}.machines, p{1}.machines
        % but too much overhead.
    % Maybe the way it is written currently although it appears double the 
        % length is actually fastest, if messy?
% section in ---   --- also might have an easier way not sure
% Also have some magic numbers floating around in props and rand, not sure
    % if more sensible strats there

function [child_array, child_machine_cost] = c_over_2_old(parent_genes, ...
                    parent_fitness, parent_machine_cost, jobs_array_aug,...
                    num_jobs, num_machines)
                
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
    
    % https://stackoverflow.com/questions/8174578/faster-way-to-achieve-unique-in-matlab-if-assumed-1d-pre-sorted-vector
    tmp = sort(collisions.*parent_genes(least_fit_parent,:));
    least_fit_parent_collision_machines = tmp([true;diff(tmp(:))>0]);
%     least_fit_parent_collision_machines = ...
%         unique(collisions.*parent_genes(least_fit_parent,:));
    
    %Find all of the machines in the subset of the least fit parents
    %machines that are not involved in collisions
    non_col_machines = least_fit_machines(...
        ~ismembc(least_fit_machines, least_fit_parent_collision_machines));
                  
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
    %make any new collisions
    
    %no collisions so can just add
    union_jobs = p1_job_vec + p2_job_vec;
    parent_genes(most_fit_parent,:);
    
    %a = all machines from most fit parent with at least one job not in the
    %union
    a = ((1-union_jobs).*parent_genes(most_fit_parent,:));
%     a = (double(~union_jobs).*parent_genes(most_fit_parent,:));
    %b = all machines from most fit parent with at least one job in the
    %union
    tmp = sort(union_jobs.*parent_genes(most_fit_parent,:));
    b = tmp([true;diff(tmp(:))>0]);
%     b = unique(union_jobs.*parent_genes(most_fit_parent,:));
    tmp = sort(a(~ismembc(a,b)));
    if ~isempty(tmp)
        added_machines = tmp([true;diff(tmp(:))>0]);
    else
        added_machines = [];
    end
    
%     added_machines = unique(a(~ismembc(a,b)));
    
    if most_fit_parent == 1
        p1_machines = sort([p1_machines,added_machines]);
    else
        p2_machines = sort([p2_machines,added_machines]);
    end
    
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    %Can move this somewhere else later
    p_machines = zeros(2, num_machines);
    p_machines(1,p1_machines) = 1;
    p_machines(2,p2_machines) = 1;
    
    for j = 1:2
        for i = 1:num_machines
            if child_machine>num_machines
                break
            end
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