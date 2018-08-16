function [sorted_cap,sort_indx] = evaluate_capacity(allocation)

    [a,~,c] = unique(allocation(:,2)); % group by machines
    cost_per_machine = [a, accumarray(c,allocation(:,1))]; % sum cost by machine
    max_machine = max(cost_per_machine(:,2));
    capacity_per_machine = max_machine - cost_per_machine(:,2);
    [sorted_cap,sort_indx] = sort(capacity_per_machine,'descend');

end