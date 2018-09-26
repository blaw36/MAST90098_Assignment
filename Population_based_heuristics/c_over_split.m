%% c_over_split.m

% basic crossover by cutting over at parent 1, and filling the rest with
% parent 2.
% Note that because each parent's gene consists of a sequence of machines
% over a sorted array of jobs (at the start), the ith position in both
% parents represents the machine they have allocated to the ith job, where
% the ith job is the same for both.

% Hence our crossover is taking machine allocations for jobs 1:cut from 
% parent 1, and then allocations for jobs (cut+1):end from parent 2.

function child_array = c_over_split(parent_pair, parent_genes, ...
    parent_fitness, num_jobs)

    child_array = zeros(1,num_jobs);
    
    % Crossover can either be counted from the start, or counted from the
    % end. Randomly choose (50/50 chance) between each.
    
    % 1 denotes count crossover from END of parent 1, 0 denotes from START 
    % of parent 1
    start_or_end = round(rand(1));

    % Determine crossover weight - parent with lower makespan gets more
    % elements to the crossover, so use (1 - wt) to allocate crossover
    % position.
    % NOTE: this weighting doesn't actually give much differencing between
    % the two parents in a lot of cases
    p1_wt = parent_fitness(1)/(parent_fitness(1) + parent_fitness(2));
    p1_crossover = ceil(num_jobs*(1-p1_wt));
    if start_or_end == 1
        cross_point = num_jobs - p1_crossover;
        child_array = ...
            [parent_genes(2,1:cross_point), ...
            parent_genes(1,(cross_point + 1):num_jobs)];
    elseif start_or_end == 0
        cross_point = p1_crossover;
        child_array = ...
            [parent_genes(1,1:cross_point), ...
            parent_genes(2,(cross_point + 1):num_jobs)];
    end

end