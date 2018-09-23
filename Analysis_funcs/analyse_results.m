%% analyse_results.m
% Constructs 3 plots of average [time, makespan, relative_error]
% If the plot is too "busy" can call this function mutiple times, 
% specifying subsets of the algs and programs to be displayed.
%% Input:
    % results: stores the average [time, makespan, relative_error]
        % across the algs, and gen_args\
        % has dims |algs|x|programs_range|x(machines_denom_iterator)x3
    % alg_subset: Specifies a subset of algorithms to plot
        % iterate across
    % num_programs_subset: Specifies a subset of the programs_range to 
        % iterate across
    % programs_range: a vector of num_programs to vary across
    % alg_names: Identifying names for algs used in the legend.
%%

function analyse_results(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_denom_iterator, ...
                        alg_names)

    subset = zeros(size(alg_subset,2), size(num_programs_subset,2), ...
                      size(results,3), size(results,4));
    varying_m = 1/machines_denom_iterator:1/machines_denom_iterator:1;
    
    for a_i = alg_subset
        for n_j = num_programs_subset
            subset(a_i, n_j, :, :) = results(a_i, n_j, :, :);            
        end
    end
    
    %Information to format the axis
    y_axises = ["Average Time", "Average Makespan", "Average Relative Error"];
    x_axis = "Proportion of machines to jobs";
    %Construct the legend
    %Makes each entry look like ({alg_name})-Jobs:n
    legend_suffix = "-Jobs: ";
    legend_algs = "("+ alg_names(alg_subset) + ")" + legend_suffix;
    %The order these are added to the legend reflects the loops below,
    %Algs are sequentially iterated through, varying the number of programs
    %for each alg.
    repeated_algs = repelem(legend_algs, length(num_programs_subset));
    repeated_programs = repmat(programs_range(num_programs_subset), 1,length(alg_names));
    legend_entries = repeated_algs+repeated_programs;
    
    for i = 1:3
        %Clears the current axis
        cla();
        %Sets the plot to store all new information
        hold on;
        for a_i = alg_subset
            for n_j = num_programs_subset
                data = subset(a_i,n_j,:,i);
                vector = data(:);
                plot(varying_m,vector);
            end
        end
        xlabel(x_axis) 
        ylabel(y_axises(i))
        legend(legend_entries,'Location','northeast')
        
        disp('Press a key for next graphic')
        pause;
    end
end

