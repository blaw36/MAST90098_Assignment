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
%
% Uses fitness ratio to make it more likely to draw machines from fitter
% parents.


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
    %Measures proportion of fitness each parent carries
    fitness_ratio = parent_fitness/sum(parent_fitness);
    %Normalizes so can treat as prob
    fitness_ratio = fitness_ratio/sum(fitness_ratio);
    
    while any(parent_indices <= num_machines)
        done = false;
        parent_index = parent_indices(current_parent);
        while parent_index <= num_machines && ~done
            parent_machine = ordered_m_parents(current_parent,parent_index);
            
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
            
            % Commented out with %% and % % % were two failed attempts at
            % speedups
            
% %             found_in_parent_loc = ismembc2(parent_machine_jobs,un_assigned_jobs);
% %             if all(found_in_parent_loc)
% % %             a = ismembc(un_assigned_jobs,parent_machine_jobs);
%             if sum(a) == length(parent_machine_jobs)
           if all(ismembc(parent_machine_jobs, un_assigned_jobs))
%                 if so, assign those jobs and mark being done
                done = true;
% %                 un_assigned_jobs(found_in_parent_loc) = [];
                un_assigned_jobs = un_assigned_jobs(...
                        ~ismembc(un_assigned_jobs,parent_machine_jobs));
% % %                 un_assigned_jobs = un_assigned_jobs(~a);
                child_array(parent_machine_jobs) = parent_machine;
                child_machine_cost(parent_machine) = ...
                    parent_machine_cost(current_parent, parent_machine);
           end
            parent_index = parent_index + 1;
        end
        %TODO: Could use fitness here to increase the chance of drawing
        %from the more fit parent
        %Record current index
        parent_indices(current_parent) = parent_index;
        %Switch parent if rand numb exceeds fitness ratio
        if rand > fitness_ratio(current_parent)
            current_parent = 1 + mod(current_parent,2);
        end
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