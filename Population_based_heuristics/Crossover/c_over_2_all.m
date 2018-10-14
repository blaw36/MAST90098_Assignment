%% c_over_2_all.m
% Performs c_over_2 on all crossovers at once

function [children, children_machine_cost] = c_over_2_all(...
                            num_children, num_machines, num_jobs, ...
                            parent_mat, pop_mat, machine_cost_mat,...
                            makespan_mat, jobs_array_aug)
    
    % Store all of the parents to be crossed 'side' by side
    % Retrieve and store all the parent information in a comparable data
    % structure, 
    % TODO: flow of data might be able to be optimised further
    
    %Inject a little bit of noise
    switch_indices = rand(1,num_children)<0.1;

    %parents_genes = zeros(num_children, num_jobs, 2);
    %parents_machine_cost = zeros(num_children, num_machines, 2);
    
    %Retrieve the parent genes
    parents_genes(:,:,2) = pop_mat(parent_mat(:,2),:);
    parents_genes(:,:,1) = pop_mat(parent_mat(:,1),:);
    
    %Make it so parent 1 is the least fit parent
    tmp = parents_genes(switch_indices,:,1);
    parents_genes(switch_indices,:,1) = parents_genes(switch_indices,:,2);
    parents_genes(switch_indices,:,2) = tmp;
    
    %Retrieve the parent costs
    parents_machine_cost(:,:,2) = machine_cost_mat(parent_mat(:,2),:);
    parents_machine_cost(:,:,1) = machine_cost_mat(parent_mat(:,1),:);
    
    %Make it so parent 1 is the least fit parent
    tmp = parents_machine_cost(switch_indices,:,1);
    parents_machine_cost(switch_indices,:,1) = parents_machine_cost(switch_indices,:,2);
    parents_machine_cost(switch_indices,:,2) = tmp;
    
    %----------------------------------------------------------------------
    %p_machines = zeros(num_children, num_machines, 2);
    
    %Over-allocate to least fit parent, as remove from it later
    p_machines(:,:,2) = rand(num_children, num_machines)<1/3;
    p_machines(:,:,1) = rand(num_children, num_machines)<1/2;
    
    %Find all of the jobs which are carried by these machines
    %job_inclusion_matrix = zeros(num_children, num_jobs,2);    
    %Idea from 
    %https://au.mathworks.com/matlabcentral/answers/333359-using-a-matrix-as-an-index-to-another-matrix
    job_inclusion_matrix = zeros(num_children, num_jobs,2);
    for p = 1:2
        for c = 1:num_children
            job_inclusion_matrix(c, :, p) = ...
                                p_machines(c, parents_genes(c,:,p), p);
        end
    end
    
    %Compute the collisions    
    
    %First find all jobs collisions
    jobs_collision_matrix = job_inclusion_matrix(:,:,1).*...
                            job_inclusion_matrix(:,:,2);
    
    %Next find which machines in the least fit machine cause these
    %collisions
    tmp = sort(jobs_collision_matrix.*parents_genes(:,:,1),2);
    
    least_fit_machines_collision_matrix = zeros(num_children, num_machines);
    for c = 1:num_children
        row_tmp = tmp(c,[true,diff(tmp(c,:))>0]);
        row_tmp(row_tmp==0) = [];
        least_fit_machines_collision_matrix(c, row_tmp) = 1;
    end

    %Remove the collision machines from the least fit machine
    p_machines(:,:,1) = p_machines(:,:,1)-least_fit_machines_collision_matrix;
    
    %Update the job_inclusion_matrix
    for c = 1:num_children
        job_inclusion_matrix(c, :, 1) = p_machines(c, parents_genes(c,:,1), 1);
    end
    
    %Now we proceed to add every machine we can from the most fit parent 
    %such that no collisions are produced.
    
    %Find all jobs that are currently covered, 
    %   no collisions so can just add
    union_jobs = job_inclusion_matrix(:,:,1)+job_inclusion_matrix(:,:,2);
    %a = all machines from most fit parent with at least one job not in the
    %union
    a = (1-union_jobs).*parents_genes(:,:,2);
    
    %b = all machines from most fit parent with at least one job in the
    %union
    b = sort(union_jobs.*parents_genes(:,:,2),2);
    for c = 1:num_children
        row_b = b(c, [true,diff(b(c,:))>0]);
        %Find all the machines we could add without collisions (this
        %operation includes 0, so need >)
        can_add = a(c,(~ismembc(a(c,:),row_b)));
        p_machines(c,can_add(can_add>0),2) = 1;
    end
    
    %Use the derived information to form the children    
    children = zeros(num_children,num_jobs);
    children_machine_cost = zeros(num_children,num_machines);    
	all_jobs = 1:num_jobs;
    
    %Computes the cost of each child individually using the function below,
    %even with reshape cost, faster this way then indexing through the
    %children in the larger structures.
    for c = 1:num_children
        [children(c,:), children_machine_cost(c,:)] = ...
           compute_child(num_machines, num_jobs,...
                reshape(parents_genes(c,:,:),num_jobs,2),...
                reshape(p_machines(c,:,:),num_machines,2),...
                reshape(parents_machine_cost(c,:,:),num_machines,2),...
                jobs_array_aug, all_jobs);
    end          
end

function [child, child_machine_cost] = compute_child(num_machines, num_jobs, ...
                    parent_genes, parent_machines, parent_machine_cost, ...
                    jobs_array_aug, all_jobs)
    child_machine = 1;
    child = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);
    for p = 1:2
        for m = 1:num_machines
            if ~parent_machines(m,p)
                continue
            end
            child(parent_genes(:,p)==m) = child_machine;
            child_machine_cost(child_machine) = parent_machine_cost(m, p);
            child_machine = child_machine + 1; 

            if child_machine>num_machines
                break
            end
        end
    end
    
    %Check which jobs still need to be assigned
    un_assigned_jobs = all_jobs(~child);

    % Assign the remaining jobs
    % Leaving it as is corresponds to greedy,(due to how jobs have been 
    % sorted) seems the best    
    for job = un_assigned_jobs
        [cost, loc] = min(child_machine_cost(:));
        child(job) = loc;
        child_machine_cost(loc) = cost + jobs_array_aug(job); 
    end
end