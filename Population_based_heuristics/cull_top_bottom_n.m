%% cull_top_bottom_n.m
% Basic culling based on top n makespans, to req'd size n (usually is the 
% init_pop_size)
% output should be some array of rows to grab from the large pop_mat.



function indivs_to_keep = cull_top_bottom_n(pop_mat, makespan_mat, ...
    init_pop_size, top_prop)

    [pop_sort, pop_sort_indx] = sortrows(makespan_mat);
    top_n_to_keep = floor(init_pop_size*top_prop);
    bottom_n_to_keep = init_pop_size - top_n_to_keep;
    
    top_indivs_to_keep = pop_sort_indx(1:top_n_to_keep);    
    bottom_indivs_to_keep = pop_sort_indx(...
        (end - bottom_n_to_keep + 1):end);
    
    indivs_to_keep = [top_indivs_to_keep; bottom_indivs_to_keep];

end
