%% convert_mach_struct2mtx.m
% reverse of 'convert_mach_mtx2struct.m'

% convert our individual matrices in a population struct to population
% arrays (rows of the matrix) to quickly calculate makespan, as more
% efficient at everything else except makespan calculation.
% Each row represents individual i of the population, A[j] is the machine
% number allocated to job j (consistent with the sorted job array at start
% of the algorithm).

function [pop_mat] = convert_mach_struct2mtx(pop_struct, num_jobs, ...
    num_machines)

    current_pop_size = size(pop_struct,2);
    pop_mat = zeros(current_pop_size, num_jobs);
    machine_num_array = 1:num_machines;
    
    for i = 1:current_pop_size
        pop_mat(i,:) = machine_num_array  * pop_struct(i).mach_mat;
    end
    
end