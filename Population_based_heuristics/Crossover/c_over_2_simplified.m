%% c_over_2_simplified.m

% like c_over_2, but picks from least fit machine first (parameterised 
% proportion) and then all remaining non colliding from most fit machine

function [child_array, child_machine_cost] = c_over_2_simplified(parent_genes, ...
                    parent_fitness, parent_machine_cost, jobs_array_aug,...
                    num_jobs, num_machines, less_fit_c_over_machs)

    
    %Least fit parent is on left
    least_fit_parent = 1;
    
    %Inject a little bit of noise
    if rand<0.1
        least_fit_parent = 2;
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
    child_array = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);
    child_machine = 1;
    all_jobs = 1:num_jobs;
    
    %Can move this somewhere else later
    p_machines = zeros(2, num_machines);
    p_machines(1,p1_machines) = 1;
    p_machines(2,p2_machines) = 1;
    
    for p = 1:2
        for m = 1:num_machines
            if ~p_machines(p,m)
                continue
            end

            child_array(parent_genes(p,:)==m) = child_machine;
            child_machine_cost(child_machine) = parent_machine_cost(p, m);
            child_machine = child_machine + 1;
            
            if child_machine>num_machines
                break
            end
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