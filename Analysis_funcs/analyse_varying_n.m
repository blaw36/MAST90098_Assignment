%% analyse_varying_n.m
% Constructs 3 plots of average [time, makespan, relative_error] varying
% the number of programs for a fixed proportion of machines
% 
% If the plot is too "busy" can call this function mutiple times, 
% specifying subsets of the algs and programs to be displayed.
%% Input:
    % results: stores the average [time, makespan, relative_error]
        % across the algs, and gen_args\
        % has dims |algs|x|programs_range|x1x3
    % alg_subset: Specifies a subset of algorithms to plot
        % iterate across
    % num_programs_subset: Specifies a subset of the programs_range to 
        % iterate across
    % programs_range: a vector of num_programs to vary across
    % machines_proportion: the proportion of machines to jobs
    % alg_names: Identifying names for algs used in the legend.
%%

function analyse_varying_n(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_proportion, ...
                        alg_names)
    if size(results,3) ~= 1
        size(results,3)
        error("The proportion of machines is being varied");
    end

    subset = zeros(size(alg_subset,2), size(num_programs_subset,2), ...
                      size(results,3), size(results,4));
    
    for a_i = alg_subset
        for n_j = num_programs_subset
            subset(a_i, n_j, :, :) = results(a_i, n_j, :, :);            
        end
    end
    
    %Information to format the axis
    
    y_axises = ["Average Time", "Average Makespan", "Average Relative Error"];
    x_axis = "Number of Jobs";
    %Construct the legend
    legend_entries = alg_names(alg_subset);
    
    for i = 1:3
        %Clears the current axis
        cla();
        %Sets the plot to store all new information
        hold on;
        for a_i = alg_subset
            for n_j = num_programs_subset
                data = subset(a_i,:,1,i);
                vector = data(:);
                plot(programs_range,vector);
            end
        end
        title("Machine Proportion = "+machines_proportion);
        xlabel(x_axis) 
        ylabel(y_axises(i))
        legend(legend_entries,'Location','northeast')
        
        disp('Press a key for next graphic')
        pause;
    end
end