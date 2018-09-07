% Places the biggest program into the emptiest machine until done
%
% Uses a binary heap for large num_machines, as better theoretical runtime,
%   ( O(n*logm) vs O(n*m) where n is num_programs, m num_machines )
% however matlab is optimized for vector based actions, so isn't worth it
% for smaller numbers of machines.
%
% TODO: If could use an underlying priority queue c imp like
%       https://au.mathworks.com/matlabcentral/fileexchange/24238-ataiya-pq
%       then that would be ideal but probs 'cheating'
%% Input:
%   %inputData:
%   %num_jobs: the number of jobs
%   %num_machines: the number of machines
%% Ouput:
%   %init_alloc:
%%

function init_alloc = initialise_simple(inputData, num_jobs, num_machines)
    
    %Uses a binary heap for large num_machines
    %TODO: work out an approx cutoff, 50000 just a random large guess
    %TODO: remove heap?, not going to be working on anything that big
    %anyway
    use_heap = false;
    if num_machines >= 50000
        use_heap = true;
    end

    job_costs = inputData(1:num_jobs);
    sorted_job_costs = sort(job_costs ,'descend');

    % Pre-allocate for speed
    init_alloc = zeros(num_jobs,2);

    %Stores the current cost per machine.
    machine_costs = [zeros(num_machines,1),(1:num_machines)'];

    % First round allocation
    init_alloc(1:num_machines,:) = ...
            [sorted_job_costs(1:num_machines)',(1:num_machines)'];
    machine_costs(1:num_machines, 1) = sorted_job_costs(1:num_machines);
    
    %Use heap as priority queue
    if use_heap
        h = MaxHeap(num_machines,-1*machine_costs(:,1)',machine_costs(:,2)');
        i = num_machines+1;
        %While still jobs unassigned
        while i<=num_jobs
            %Get emptiest machine
            [neg_cost, index] = h.ExtractMax();
            init_alloc(i,:) = [sorted_job_costs(i), index];
            cost = (-1*neg_cost)+sorted_job_costs(i);
            h.Insert(-1*cost, index);
            i = i+1;
        end
    else
        %Keeps assigning the rest of the jobs until done
        for i = num_machines+1:num_jobs
            [cost, loc] = min(machine_costs(:,1));
            init_alloc(i,:) = [sorted_job_costs(i), loc];
            machine_costs(loc,1) = cost + sorted_job_costs(i);
        end
    end
end