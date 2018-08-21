function [cost_pm,makespan] = evaluate_makespan(allocation, num_machines)

    % Sort the allocation vector by machine for this to work
    [sort_order, sort_indx] = sort(allocation(:,2));
    allocation = allocation(sort_indx,:);
    cost_pm = zeros(num_machines,2);
    cost_pm(:,1) = (1:num_machines)';
    
    % Sum by machine
    cost_pm(:,2) = [accumarray(allocation(:,2),allocation(:,1)); ...
            zeros(num_machines - max(allocation(:,2)), 1)];
    
    makespan = max(cost_pm(:,2));

end