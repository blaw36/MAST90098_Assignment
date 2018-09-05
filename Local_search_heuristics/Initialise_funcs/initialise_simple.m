% Places the biggest program into the emptiest machine until done
%
% Uses a binary heap for large num_machines, as better theoretical runtime,
%   ( O(n*logm) vs O(n*m*logm) where n is num_programs, m num_machines )
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

function init_alloc = initialise_simple2(inputData, num_jobs, num_machines)
    
    %Uses a binary heap for large num_machines
    use_heap = false;
    if num_machines >= 500
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
    %Just keep machine_costs sorted instead    
    else
        %Keeps assigning the rest of the jobs until done
        for i = num_machines+1:num_jobs
            %Resort
            machine_costs = sortrows(machine_costs,1,'ascend');
            %Place the next smallest job into the emptiest machine.
            init_alloc(i,:) = [sorted_job_costs(i), machine_costs(1,2)]; 
            %Place the cost of the next job into the emptiest machine
            machine_costs(1,1) = machine_costs(1,1) + sorted_job_costs(i);
        end
    end
end