function [cost_pm,makespan] = evaluate_makespan(allocation, num_machines)

    machines = (1:num_machines)';
    cost_pm = [machines, accumarray(allocation(:,2),allocation(:,1))]; % sum cost by machine
    makespan = max(cost_pm(:,2));

end