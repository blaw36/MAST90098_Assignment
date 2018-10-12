%% cull_top_n_rand_perm.m
% Basic culling to some proportion of top, then rand perm to 'distribute'
% the rest
% output should be some array of rows to grab from the large pop_mat.



function indivs_to_keep = cull_top_and_randsamp(pop_mat, makespan_mat, ...
    init_pop_size, top_prop)

    [pop_sort, pop_sort_indx] = sortrows(makespan_mat);
    top_n_to_keep = floor(init_pop_size*top_prop);
    rest_to_keep = init_pop_size - top_n_to_keep;
    
    top_indivs_to_keep = pop_sort_indx(1:top_n_to_keep);    
    rest_to_keep = pop_sort_indx(randsample(...
        (top_n_to_keep+1):size(pop_sort_indx,1), rest_to_keep , false));
    
    indivs_to_keep = [top_indivs_to_keep; rest_to_keep];

end
