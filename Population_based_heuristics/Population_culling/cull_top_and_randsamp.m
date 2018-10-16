%% cull_top_n_rand_perm.m
% Keeps a fixed proportion of the best population and randomly samples from
% the rest.

%% Input:
    % pop_mat: An init_pop_size x num_jobs matrix encoding the
        % job locations of each individual
    % makespan_mat:  An init_pop_size vector encoding the makespan of each
        % individual
    % init_pop_size: the number of members in the population
    % top_prop: the propotion guaranteed to be kept
%% Output:
    % indivs_to_keep: the pop_mat of the kept individuals
%%

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
