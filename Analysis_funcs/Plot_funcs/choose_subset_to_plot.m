%% choose_subset_to_plot.m
%% Input:
    % num_lines: The number of lines we want to plot
    % num_algs: The number of algorithms sharing the plot
    % num_dif_programs: The number of different numbers of programs
%% Output:
    %subset: a vector of elements between 1 and num_programs specifying
        %which subset of programs will be plotted
%%

function subset = choose_subset_to_plot(num_lines, num_algs, num_dif_programs)
    
    size_prog_subset = num_lines/num_algs;
    iterator = 1/(size_prog_subset-1);
    subset = round(quantile(1:num_dif_programs, 0:iterator:1));
end

