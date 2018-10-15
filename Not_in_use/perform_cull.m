%% perform_cull.m
% culls the population with the selected method



function survivors = perform_cull(pop_mat, makespan_mat, ...
                                    init_pop_size, cull_prop, method)

    % Population culling
    if method == "top"
        survivors = cull_top_n(pop_mat, makespan_mat, init_pop_size);
    elseif method == "top_and_bottom"
        survivors = cull_top_bottom_n(pop_mat, makespan_mat, ...
                                            init_pop_size, cull_prop);
        % Last number is a parameter which states that the top 80% of the new
        % pop'n should be strictly by makespan, the remaining 20% are
        % chosen from the worst individuals.
    elseif method == "top_and_randsamp"
        % Takes the top x%, rand sample from the rest
        survivors = cull_top_and_randsamp(pop_mat, makespan_mat, ...
                                                init_pop_size, cull_prop);
    else
        error("Invalid Culling Method");
    end
end
