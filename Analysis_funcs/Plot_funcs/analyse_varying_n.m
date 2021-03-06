%% analyse_varying_n.m
% Constructs 3 plots of average [time, makespan, relative_error] varying
% the number of programs for a fixed proportion of machines
% 
% If the plot is too "busy" can call this function mutiple times, 
% specifying subsets of the algs and programs to be displayed.
%% Input:
    % results: stores the average [time, ratio_to_init, ratio_to_lb]
        % across the algs, and gen_args\
        % has dims |algs|x|programs_range|x1x3
    % alg_subset: Specifies a subset of algorithms to plot
        % iterate across
    % num_programs_subset: Specifies a subset of the programs_range to 
        % iterate across
    % programs_range: a vector of num_programs to vary across
    % machines_proportion: the proportion of machines to jobs
    % alg_names: Identifying names for algs used in the legend.
    % save_path: An optional param indicating figures should just be saved
        % to the indicated path
    % save_name: An option param giving the filename of the figure
%%

function analyse_varying_n(results, alg_subset, num_programs_subset, ...
                        programs_range, machines_proportion, ...
                        alg_names, save_path, save_name)
                    
    %Use empty string to signify no save path
    if ~exist('save_path','var')
        save_path = "";
    end
    
    subset = zeros(size(alg_subset,2), size(num_programs_subset,2), ...
                      size(results,3), size(results,4));
    
    for a_i = alg_subset
        for n_j = num_programs_subset
            subset(a_i, n_j, :, :) = results(a_i, n_j, :, :);            
        end
    end
    
    %Information to format the axis
    
    y_axises = ["Log_{10} Average Time",...
                "Average Ratio to Initiation",...
                "Average Ratio to Lower Bound",...
                "Log_{10} Average Time"];
    x_axis = "Number of Jobs";
    %Construct the legend
    legend_entries = alg_names(alg_subset);
    
    for i = 1:4
        %Clears the current axis
        clf('reset')
        if i == 4
            %duplicate the legend to store lines of best fit
            legend_entries = repelem(legend_entries,1,2);
        end
        %Sets the plot to store all new information
        hold on;
        for a_i = alg_subset
            if i<4
                data = subset(a_i,:,1,i);
                vector = data(:);
                if i == 1
                    vector = log10(vector);
                end
                plot(programs_range,vector);
            else
                %log log graph with line of best fit
                data = subset(a_i,:,1,1);
                vector = data(:);
                vector = log10(vector);
                l= polyfit(log10(programs_range),vector',1);
                lbf = polyval(l,log10(programs_range));
                plot(log10(programs_range), vector);
                plot(log10(programs_range), lbf,"--")
                
                desc_string = sprintf("logTime = %.2f + %.2f logJobs",l(2),l(1))
                
                legend_entries(2*a_i) = desc_string;
            end
        end
        
        title("Machine Proportion = "+machines_proportion);
        legend('off');
        legend(legend_entries,'Location','best')
        legend('show');
        ylabel(y_axises(i)) 
        
        if i<4
            xlabel(x_axis)
        else
            xlabel("Log_{10} Number of Programs")
        end

        if save_path ~= ""
            %Save to path
            saveas(gcf,save_path+save_name+"n"+string(i)+'.png')
        else
            %Display and wait for user input
            disp('Press a key for next graphic')
            pause;
        end
    end
end