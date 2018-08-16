function makespan = evaluate_makespan(allocation)

    cost_per_machine = cellfun(@sum,allocation);
    makespan = max(cost_per_machine);

end