function [sorted_cap,sort_indx] = evaluate_capacity(allocation, number_of_machines)

    [cost_per_machine,max_machine]= evaluate_makespan(allocation, number_of_machines);
    cost_per_machine = max_machine - cost_per_machine(:,2);
    [sorted_cap,sort_indx] = sort(cost_per_machine,'descend');

end