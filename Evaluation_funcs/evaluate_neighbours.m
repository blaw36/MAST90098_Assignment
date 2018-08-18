function nbour_results = evaluate_neighbours(job_alloc, nbour_combos, k_exch, num_machines)

    nbour_results = [];

    % Again, have not decided how i'll make things work for K > 1 exchange
    for i = 1:length(nbour_combos)
        % Swap to new
        job_alloc(nbour_combos(i,1),2) = nbour_combos(i,3);
        % Evaluate
        [costs,makespan] = evaluate_makespan(job_alloc, num_machines);
        nbour_results = [nbour_results; ...
            [nbour_combos(i,4) makespan]];
        % Swap back to old
        job_alloc(nbour_combos(i,1),2) = nbour_combos(i,2);
    end

end