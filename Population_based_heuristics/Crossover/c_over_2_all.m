%% c_over_2_all.m
% Performs c_over_2 on all crossovers at once

function [children, children_machine_cost] = c_over_2_all(...
                            num_children, num_machines, num_jobs, ...
                            parent_mat, pop_mat, machine_cost_mat,...
                            makespan_mat, jobs_array_aug...
                            )%Extra args
    
    % Store all of the parents to be crossed 'side' by side
    % Retrieve and store all the parent information in a comparable data
    % structure, 
    % TODO: flow of data might be able to be optimised further
    % TODO: Don't need to do temp switching, can pass parent mat to
    % crossover ordered by fitness
    
    %parents_fitness = zeros(num_children, 2);
    parents_fitness = makespan_mat(parent_mat);
    %Find the least_fit_parents
    [~, least_fit_parents] = max(parents_fitness,[],2);
    %TODO: Inject some NOISE
    
    %TODO: Do this via vector bases addition
    [~, most_fit_parents] = max(parents_fitness,[],2);
    
    %parents_genes = zeros(num_children, num_jobs, 2);
    %parents_machine_cost = zeros(num_children, num_machines, 2);
    
    %Retrieve the parent genes
    parents_genes(:,:,2) = pop_mat(parent_mat(:,2),:);
    parents_genes(:,:,1) = pop_mat(parent_mat(:,1),:);
    
    %Make it so parent 1 is the least fit parent
    tmp = parents_genes(least_fit_parents~=1,:,1);
    parents_genes(least_fit_parents~=1,:,1) = parents_genes(least_fit_parents~=1,:,2);
    parents_genes(least_fit_parents~=1,:,2) = tmp;
    
    %Retrieve the parent costs
    parents_machine_cost(:,:,2) = machine_cost_mat(parent_mat(:,2),:);
    parents_machine_cost(:,:,1) = machine_cost_mat(parent_mat(:,1),:);
    
    %Make it so parent 1 is the least fit parent
    tmp = parents_machine_cost(least_fit_parents~=1,:,1);
    parents_machine_cost(least_fit_parents~=1,:,1) = parents_machine_cost(least_fit_parents~=1,:,2);
    parents_machine_cost(least_fit_parents~=1,:,2) = tmp;
    %----------------------------------------------------------------------
    %p_machines = zeros(num_children, num_machines, 2);
    
    %Over-allocate to least fit parent, as remove from it later
    p_machines(:,:,2) = rand(num_children, num_machines)<1/3;
    p_machines(:,:,1) = rand(num_children, num_machines)<1/2;
    
    %job_inclusion_matrix = zeros(num_children, num_jobs,2);    
    %From 
    %https://au.mathworks.com/matlabcentral/answers/333359-using-a-matrix-as-an-index-to-another-matrix
    job_inclusion_matrix = zeros(num_children, num_jobs,2);
    for p = 1:2
        for r = 1:num_children
            job_inclusion_matrix(r, :, p) = p_machines(r, parents_genes(r,:,p), p);
        end
    end
    
%     p_machines
%     parents_genes
%     job_inclusion_matrix
%     
%     parents_genes(1,:,1)
%     p_machines(1,:,1)
%     p_machines(1,3,1)
%     job_inclusion_matrix(1,:,1)
%     
%     p_machines(1,parents_genes(1,:,1),1)
    
    %Compute the collisions
    
    
    %First find all jobs collisions
    job_inclusion_matrix;
    jobs_collision_matrix = job_inclusion_matrix(:,:,1).*job_inclusion_matrix(:,:,2);
    
    %Next find which machines in the least fit machine cause these
    %collisions
    % https://stackoverflow.com/questions/8174578/faster-way-to-achieve-unique-in-matlab-if-assumed-1d-pre-sorted-vector
    tmp = sort(jobs_collision_matrix.*parents_genes(:,:,1),2);
    
    least_fit_machines_collision_matrix = zeros(num_children, num_machines);
    for r = 1:num_children
        row_tmp = tmp(r,[true,diff(tmp(r,:))>0]);
        row_tmp(row_tmp==0) = [];
        least_fit_machines_collision_matrix(r, row_tmp) = 1;
    end
    
    %Remove the collision machines from the least fit machine
    p_machines(:,:,1) = p_machines(:,:,1)-least_fit_machines_collision_matrix;
    
    %Update the job_inclusion_matrix
    for r = 1:num_children
        job_inclusion_matrix(r, :, 1) = p_machines(r, parents_genes(r,:,1), 1);
    end
    
    %----------------------------------------------------------------------
    
%     %----------------------------------------------------------------------
%     %----------------------------------------------------------------------
%     %TODO: Better faster way
%     
%     %Add back in all the machines from most fit parent, that don't
%     %make any new collisions
%     
%     %no collisions so can just add
%     union_jobs = p1_job_vec + p2_job_vec;
%     parent_genes(most_fit_parent,:);
%     
%     %a = all machines from most fit parent with at least one job not in the
%     %union
%     a = ((1-union_jobs).*parent_genes(most_fit_parent,:));
% %     a = (double(~union_jobs).*parent_genes(most_fit_parent,:));
%     %b = all machines from most fit parent with at least one job in the
%     %union
%     tmp = sort(union_jobs.*parent_genes(most_fit_parent,:));
%     b = tmp([true;diff(tmp(:))>0]);
% %     b = unique(union_jobs.*parent_genes(most_fit_parent,:));
%     tmp = sort(a(~ismembc(a,b)));
%     if ~isempty(tmp)
%         added_machines = tmp([true;diff(tmp(:))>0]);
%     else
%         added_machines = [];
%     end
%     
% %     added_machines = unique(a(~ismembc(a,b)));
%     
%     if most_fit_parent == 1
%         p1_machines = sort([p1_machines,added_machines]);
%     else
%         p2_machines = sort([p2_machines,added_machines]);
%     end
    
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
                    
    children = zeros(num_children,num_jobs);
    children_machine_cost = zeros(num_children,num_machines);
    children_machine = ones(1, num_children); %Probs don't need if doing correctly
    %children_indices = randperm(num_machines,num_machines);
    [~, temp] = sort(rand(num_machines, num_children));
    children_indices = temp';
    
    all_jobs = 1:num_jobs;
    
    for c = 1:num_children
        for p = 1:2
            for k = 1:num_machines
                if children_machine(c)>num_machines
                    break
                end
                if ~p_machines(c,k,p)
                    continue
                end
                parent_machine = k;
                parent_machine_jobs = sort(all_jobs(parents_genes(c,:,p)==parent_machine));
                if isempty(parent_machine_jobs)
                    continue
                end

                children(c,parent_machine_jobs) = children_indices(c,(children_machine(c)));
                children_machine_cost(c, children_indices(c,(children_machine(c)))) = ...
                            parents_machine_cost(c, parent_machine, p);
                children_machine(c) = children_machine(c) + 1;
            end
        end
        %Check which jobs still need to be assigned
        un_assigned_jobs = all_jobs(~children(c,:));

        % Assign the remaining jobs
        % Leaving it as is corresponds to greedy,(due to how jobs have been 
        % sorted) seems the best    
        for job = un_assigned_jobs
            [cost, loc] = min(children_machine_cost(c));
            children(c,job) = loc;
            children_machine_cost(c, loc) = cost + jobs_array_aug(job); 
        end
    end
    
    
    function y = helper(x)
        y = x([true;diff(x(:))>0]);
    end
end
