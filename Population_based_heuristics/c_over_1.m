%% c_over_1.m
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
% then just assign them with some sensible method (probably greedy)


function child_array = c_over_1(parent_pair, parent_genes, ...
                    parent_fitness, parent_machine_cost, jobs_array_aug,...
                    num_jobs, num_machines)

    child_array = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);
    
    all_jobs = 1:num_jobs;
    un_assigned_jobs = 1:num_jobs;
    ordered_m_parents = [randperm(num_machines,num_machines);
                         randperm(num_machines,num_machines)];
    
    parent_indices = [1,1];
    
    %Pick the most fit parent first
    [~, current_parent] = max(parent_fitness); 
    
    while any(parent_indices <= num_machines)
        done = false;
        parent_index = parent_indices(current_parent);
        while parent_index <= num_machines && ~done
            parent_machine = ordered_m_parents(current_parent,parent_index);
%             parent_machine_jobs =  all_jobs(...
%                 parent_genes(current_parent,:)==parent_machine);
            
            % ismembc is a faster (debated? but seems faster here) version
            % of ismember. Requires perhaps both arrays to be sorted
            % though. This might work for us as un_assigned_jobs is sorted,
            % and parent_machine_jobs can be pre-sorted with no issue.
            % https://undocumentedmatlab.com/blog/ismembc-undocumented-helper-function
            % https://stackoverflow.com/questions/17714487/is-there-a-function-like-ismember-but-more-efficient
            % There is another function, 'ismembc2', which returns the
            % indices of membership rather than a logical.
            parent_machine_jobs =  sort(all_jobs(...
                parent_genes(current_parent,:)==parent_machine));

            
            %Check if all these jobs in the parent machine are currently
            %un_assigned
%             if all(ismember(parent_machine_jobs, un_assigned_jobs))
            if all(ismembc(parent_machine_jobs, un_assigned_jobs))
                %if so, assign those jobs and mark being done
                done = true;
%                 un_assigned_jobs(...
%                     ismember(un_assigned_jobs,parent_machine_jobs)) = [];
                un_assigned_jobs(...
                    ismembc(un_assigned_jobs,parent_machine_jobs)) = [];
                child_array(parent_machine_jobs) = parent_machine;
                child_machine_cost(parent_machine) = ...
                    parent_machine_cost(current_parent, parent_machine);
            end
            %TODO: Could use fitness here to increase the chance of drawing
            %from the more fit parent
            parent_index = parent_index + 1;
        end
        %Record current index and switch parent
        parent_indices(current_parent) = parent_index;
        current_parent = 1 + mod(current_parent,2);               
    end
    
    %Assign the remaining jobs
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