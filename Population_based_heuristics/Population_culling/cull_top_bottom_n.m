%% cull_top_bottom_n.m
% Draws the surviving population out of the best and the worst members of
% the population, 
%% Input:
    % pop_mat: An init_pop_size x num_jobs matrix encoding the
        % job locations of each individual
    % makespan_mat:  An init_pop_size vector encoding the makespan of each
        % individual
    % init_pop_size: the number of members in the population
    % top_prop: the proportion of survivors to be drawn from the best.
%% Output:
    % indivs_to_keep: the pop_mat of the kept individuals
%%


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