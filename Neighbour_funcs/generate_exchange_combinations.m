function combo_matrix = generate_exchange_combinations(job_alloc, k_exch, num_machines)

    % allocate unique ID to each job
    jobs = [job_alloc (1:length(job_alloc))'];
    combo_matrix = [];
    
    % Haven't figured out how to extend this to k properly yet.
    
    for i = 1:length(jobs)
        combo_matrix = [combo_matrix; ...
            repelem(jobs(i,3),num_machines)', ...
            repelem(jobs(i,2),num_machines)', ... 
            (1:num_machines)'];
    end
    
    % Remove any movements to the same machine
    combo_matrix = combo_matrix(combo_matrix(:,2) ~= combo_matrix(:,3),:);
    
    % Label these with 'neighbour IDs'
    combo_matrix = [combo_matrix (1:length(combo_matrix))'];
    
end
