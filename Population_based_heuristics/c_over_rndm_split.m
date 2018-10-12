%% c_over_rndm_split.m

% Crossover amts are proportional to makespan (lower makespan, more of your
% elements make it.
% We then create array of 0s and 1s, at randomly selected positions, to
% determine which elements get carried over to the children. The number of
% 1s (number of elements carried over) is equal to the parent's allocation.

function child_array = c_over_rndm_split(parent_genes, ...
    parent_fitness, num_jobs)

    child_array = zeros(1,num_jobs);


    % Determine crossover weight - parent with lower makespan gets more
    % elements to the crossover, so use (1 - wt) to allocate crossover
    % position.
    % NOTE: this weighting doesn't actually give much differencing between
    % the two parents in a lot of cases
    p1_wt = parent_fitness(1)/(parent_fitness(1) + parent_fitness(2));
    num_p1_elmts = ceil(num_jobs*(1-p1_wt));
    
    p1_pass_on = zeros(1,num_jobs);
    p2_pass_on = zeros(1,num_jobs);
    
    inherit_indx = randperm(num_jobs, num_p1_elmts);
    p1_pass_on(inherit_indx) = 1;
    p2_pass_on = 1 - p1_pass_on;
    
    child_array = ...
        parent_genes(1,:) .* p1_pass_on + ...
        parent_genes(2,:) .* p2_pass_on;

end