%% cull_top_n.m
% Basic culling based on top n makespans, to req'd size n (usually is the 
% init_pop_size)
% output should be some array of rows to grab from the large pop_mat.



function genes_to_keep = cull_top_n(pop_mat, makespan_mat, ...
    init_pop_size)

    [pop_sort, pop_sort_indx] = sortrows(makespan_mat);
    genes_to_keep = pop_sort_indx(1:init_pop_size);

end
