function [combo_matrix, accum_time] = generate_exchange_combinations(jobs, k_exch, ...
    num_machines, cost_pm_matrix)
    
% Time each generation step and accumulate in the solver script to see
% how long we're spending on generating combos
start_gen = tic;
combo_matrix = [];

% Haven't figured out how to extend this to k properly yet.

% 1) Exchange MUST involve the 'most loaded/expensive' machine, else:
    % Makespan may not change (if swapping between other machines)
    % Makespan cannot decrease (if swapping between other machines, as 
        % makespan will be at least the value of the current makespan
        % as dictated by the 'most loaded/expensive' machine
[max_val, loaded_mach] = max(cost_pm_matrix(:,2));

% Jobs into loaded machine
combo_matrix(:,1:2) = [jobs(jobs(:,2) ~= loaded_mach,3), ...
    jobs(jobs(:,2) ~= loaded_mach,2)];
combo_matrix(:,3) = loaded_mach;

% Jobs out of the loaded machine
jobs_out = jobs(jobs(:,2) == loaded_mach,:);

for i = 1:length(jobs_out)
    combo_matrix = [combo_matrix; ...
        repelem(jobs_out(i,3),num_machines)', ...
        repelem(jobs_out(i,2),num_machines)', ... 
        (1:num_machines)'];
end

% Remove any movements to the same machine
combo_matrix = combo_matrix(combo_matrix(:,2) ~= combo_matrix(:,3),:);

% Label these with 'neighbour IDs'
combo_matrix = [combo_matrix (1:length(combo_matrix))'];

accum_time = toc(start_gen);
end
