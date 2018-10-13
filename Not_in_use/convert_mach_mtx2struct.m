%% convert_mach_mtx2struct.m

% convert our population arrays to population matrices in a struct to
% quickly calculate makespan.
% Matrices are m x n 0/1s (rows are machines, columns are jobs,
% corresponding to the initial sorted job array). m_ij = 1 if machine i is
% allocated to job j, and 0 otherwise. Each row should sum to the number of
% jobs each machine has, each column should sum to 1 (allocate to one
% machine only).

function [pop_struct] = convert_mach_mtx2struct(pop_mat, num_jobs, ...
    num_machines)

    % Array
    pop_struct = zeros(num_machines, num_jobs, size(pop_mat,1));
    for i = 1:size(pop_mat,1)
        for j = 1:num_jobs
            pop_struct(pop_mat(i,j),j,i) = 1;
        end
    end

%     % Struct
%     pop_struct(size(pop_mat,1)).mach_mat = zeros(num_machines, num_jobs);
%     for i = 1:size(pop_mat,1)
%         pop_struct(i).mach_mat = zeros(num_machines, num_jobs);
%         for j = 1:num_jobs
%             pop_struct(i).mach_mat(pop_mat(i,j),j) = 1;
%         end
%     end
    
end