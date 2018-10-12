%% calc_machine_costs

function [machine_cost_mat] = calc_machine_costs(jobs_array_aug, pop_mat, ...
    num_machines)

    jobs_array_transpose = jobs_array_aug';
    machine_cost_mat = zeros(size(pop_mat,1), num_machines);
    for j = 1:num_machines
        indicator_mat = double((pop_mat == j));
        machine_cost_mat(:,j) = indicator_mat * jobs_array_transpose;
    end
end
