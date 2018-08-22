function [nbour_results, time_taken_eval] = evaluate_neighbours(job_alloc, ...
    nbour_combos, k_exch, num_machines, cost_pm_matrix)

% Time each evaluation step and accumulate in the solver script to see
% how long we're spending on evaluation nbours
start = tic;
nbour_results = [];

[max_val, loaded_mach] = max(cost_pm_matrix(:,2));

% Again, have not decided how i'll make things work for K > 1 exchange

for i = 1:length(nbour_combos)
    % Incremental analysis on current cost matrix
    overlay = [(1:num_machines)', zeros(num_machines,1)];
    job_size = job_alloc(nbour_combos(i,1),1);

    % We can condense the net effect of multiple path movements here in
    % the overlay

    overlay = [overlay; nbour_combos(i,2:3)', [-job_size, job_size]'];

    % Only bother to input if loaded_mach goes down (there is only the
    % possibility of a decreased makespan if there is net reduction in
    % loaded_mach)
    if sum(overlay(overlay(:,1) == loaded_mach,2)) < 0
        makespan = max(cost_pm_matrix(:,2) + accumarray(overlay(:,1), overlay(:,2)));
        nbour_results = [nbour_results; ...
            [nbour_combos(i,4) makespan]];
    end

end

% if no feasible nbours, just output first row (to give our script
% something to go by)

if size(nbour_results,1) == 0
    nbour_results = [nbour_results; nbour_combos(1,1) max_val];
end


% OLD loop
%     for i = 1:length(nbour_combos)
%         % Swap to new
%         job_alloc(nbour_combos(i,1),2) = nbour_combos(i,3);
%         % Evaluate
%         [costs,makespan] = evaluate_makespan(job_alloc, num_machines);
%         nbour_results = [nbour_results; ...
%             [nbour_combos(i,4) makespan]];
%         % Swap back to old
%         job_alloc(nbour_combos(i,1),2) = nbour_combos(i,2);
%     end

time_taken_eval = toc(start);

end