%% construct_results_table.m
% Programatically generates latex tables for the report.
%% Input:
    % results: stores the average [time, ratio_to_init, ratio_to_lb]
        % across the algs, and gen_args\
        % has dims |algs|x|programs_range|x(machines_denom_iterator)x3
    % alg_names: Identifying names for algs used in the legend.
    % alg_subset: Specifies a subset of algorithms to consider
    % programs_range: a vector of num_programs to vary across
    % machines_denom_iterator:
    % save_path: An optional param indicating figures should just be saved
    % to the indicated path
    % save_name: An option param giving the filename of the figure
    % machines_proportion: An optional param which if used indicates
        % just using one fixed proportion of machines.
        % if used, a num_programs x num_algs table is produced
        % if not used, a num_programs x proportions table is produced.
%%

function construct_results_table(results, alg_names, alg_subset, ...
                        programs_range, machines_denom_iterator, ...
                        save_path, save_name, machines_proportion)
                    
    %Use empty string to signify no save path
    if ~exist('save_path','var')
        save_path = "";
    end
    
    if ~exist('machines_proportion','var')
        machines_proportion = false;
    end
    
    number_of_algs = size(alg_subset,2);
    number_dif_programs = size(programs_range,2);
    number_dif_machine_props = size(results,3);
    number_of_metrics = size(results,4);
    
    subset = zeros(number_of_algs, number_dif_programs, ...
                      number_dif_machine_props, number_of_metrics);
    
    %Construct strings that will be used in labelling the tables
    if machines_proportion
        varying_m = machines_proportion;
    else
        varying_m = 1/machines_denom_iterator:1/machines_denom_iterator:1;
    end
    
    alg_names = cellstr(alg_names(alg_subset));
    varying_m = cellstr(string(varying_m));
    programs_range = cellstr(string(programs_range));
    
    metric_names = {'Log$_{10}$ Average Time',  ...
                    'Average Ratio to Initiation',...
                    'Average Ratio to Lower Bound'};
    
    %Retrieve subset of result data to be displayed
    for a_i = alg_subset
        for n_j = 1:number_dif_programs
            subset(a_i, n_j, :, :) = results(a_i, n_j, :, :);            
        end
    end
    
    for i = 1:3
        table_data = subset(:,:,:,i);
        if i==1
            table_data = log10(table_data);
        end
           
        %Convert elements of table to strings rounded to two decimal places.
        table_data = arrayfun(@(x) num2str(x,"%.2f"), table_data,...
                                                    'UniformOutput',false);
        
        % if used, a num_programs x num_algs table is produced
        % if not used, a num_programs x proportion table is produced.
        if machines_proportion
            table_data = reshape(table_data', ...
                        number_dif_programs, number_of_algs);
            col_label = cellstr("Algorithm");
            input.tableColLabels = alg_names;
            
            row_label =  cellstr("Number of Jobs");
        else
            %Join along the algs dim, creating a sub table to store
            %the result of all algs for each combination of machines and
            %number of programs.
            table_data = reshape(join(table_data, "\\", 1), ...
                        number_dif_programs, number_dif_machine_props);
            col_label = cellstr("Machine Proportion");
            input.tableColLabels = varying_m;
            %Will be using a multi-cell so indicate order of algs in cell
            row_label = cellstr("\begin{tabular}{@{}c@{}}" ...
                              + "Number of Jobs" + " \\" ...
                              + join(alg_names,"\\")...
                              + "\end{tabular}");
        end
        input.tableRowLabels = programs_range;
        
        if number_of_algs > 1
            if machines_proportion > 0
                %Single value in each cell
                input.data = cellstr(table_data);
            else
                %Multi-cell
                input.data = cellstr("\begin{tabular}{@{}c@{}}" ...
                              + table_data ...
                              + "\end{tabular}");
            end
        else
            input.data = cellstr(table_data);
        end

        % A string is being placed in each cell
        input.dataFormat = {'%s'}; 

        % Column alignment in Latex table ('l'=left-justified, 'c'=centered,'r'=right-justified):
        input.tableColumnAlignment = 'c';

        % Switch table borders on/off (borders are enabled by default):
        input.tableBorders = 1;

        % A flag to indicate this table will be placed inside another
        input.inner = true;

        % Constructs the specified table
        data_table = latexTable(input);
        
        %We then create a single cell table containing this inner table
        
        %Make sure the inner table is just one string of latex commands
        input.data = join(data_table);

        % Setting row and column labels
        input.tableColLabels = col_label;
        %The row label is itself a table listing the different algs
        input.tableRowLabels = row_label;

        % A string is being placed each cell
        input.dataFormat = {'%s'}; 

        % LaTex table labels and caption:
        if machines_proportion
            input.tableCaption = char(save_name+"-Fixed-Proportion: "+metric_names{i});
            input.tableLabel = char(save_name+"-Fixed-Proportion: "+metric_names{i});
        else
            input.tableCaption = char(save_name+"-Varying-Proportion: "+metric_names{i});
            input.tableLabel = char(save_name+"-Varying-Proportion: "+metric_names{i});
        end

        %Disable borders on this outer table
        input.tableBorders = true;

        % A flag to indicate this table will be placed inside another
        input.inner = false;
        % Kill whitespace on either side of each cell so outer table flush
        % with inner
        input.tableColumnAlignment = '@{}c@{}';
        
        %Construct this final table
        clc
        latex = latexTable(input);
        
        if save_path ~= ""
            %Save file
            if machines_proportion
                filename = save_path+save_name+"n"+string(i)+'.tex';
            else
                filename = save_path+save_name+"m"+string(i)+'.tex';
            end    
            fid=fopen(filename,'w');
            nrows = size(latex,1);
            for row = 1:nrows
                fprintf(fid,'%s\n',latex{row,:});
            end
            fclose(fid);
        else
            %Display and wait for user input
            disp('Press a key for next table')
            pause;
        end
    end
end