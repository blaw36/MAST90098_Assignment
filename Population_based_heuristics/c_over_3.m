%% c_over_3.m
% Exact same idea as cover_3 but hopefully faster in general
% Treat parents{}.order_m more or less as queues, (would be great to have a
% fast native, queue implementation, cheers matlab)
% Need to test/ opt further but committed to record progress

function child_array = c_over_3(parent_pair, parent_genes, ...
                    parent_fitness, parent_machine_cost, jobs_array_aug,...
                    num_jobs, num_machines)
    
    all_jobs = 1:num_jobs;
    
    child_array = zeros(1,num_jobs);
    child_machine_cost = zeros(1,num_machines);

    parents{2}.ordered_m = randperm(num_machines,num_machines);
    parents{1}.ordered_m = randperm(num_machines,num_machines);
                     
    parent_num_machines = [num_machines, num_machines];
    
    %Pick the most fit parent first
    [~, current_parent] = max(parent_fitness);
    other_parent = 1 + mod(current_parent,2);
    
    while any(parent_num_machines)
        
        last_parent_mach_index = parent_num_machines(current_parent);
    
        if last_parent_mach_index > 0
            %Find the last machine of the parent and all of the jobs in it
            parent_machine = parents{current_parent}.ordered_m(last_parent_mach_index);
            parent_machine_jobs =  all_jobs(...
                parent_genes(current_parent,:)==parent_machine);
            
            %Update the child machine
            child_array(parent_machine_jobs) = parent_machine;
            child_machine_cost(parent_machine) = ...
                    parent_machine_cost(current_parent, parent_machine);
            
            %Find all the machines in the other parent who hold these jobs
            other_parent_col_machines = ...
                    sort(parent_genes(other_parent,parent_machine_jobs));
            
            %Delete these machines from the queue of parent machines being
            %considered
            % Only second element of ismembc must be sorted
            parents{other_parent}.ordered_m(...
                            ismembc(parents{other_parent}.ordered_m, ...
                                    other_parent_col_machines)...
                            ) = [];
            %Delete last from current parent
            %Delete last (not first as faster time complexity
            parents{current_parent}. ...
                ordered_m(parent_num_machines(current_parent)) = [];
            %Update the record of how many parent machines
            parent_num_machines(other_parent) = ...
                                length(parents{other_parent}.ordered_m);
            parent_num_machines(current_parent) =  ...
                                parent_num_machines(current_parent) - 1;
        end
        %Switch parents
        current_parent = other_parent;
        other_parent = 1 + mod(current_parent,2);
    end
    
    % Assign the remaining jobs
    % Leaving it as is corresponds to greedy,(due to how jobs have been 
    % sorted) seems the best
    un_assigned_jobs = all_jobs(child_array==0);
    
    for job = un_assigned_jobs
        [cost, loc] = min(child_machine_cost);
        child_array(job) = loc;
        child_machine_cost(loc) = cost + jobs_array_aug(job); 
    end
end