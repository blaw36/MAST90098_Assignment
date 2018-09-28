%% construct_results_table.m
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
    
    alg_names = alg_names(alg_subset);
    subset = zeros(number_of_algs, number_dif_programs, ...
                      number_dif_machine_props, number_of_metrics);
    
    %Construct strings that will be used in labelling the tables
    if machines_proportion
        varying_m = machines_proportion;
    else
        varying_m = 1/machines_denom_iterator:1/machines_denom_iterator:1;
    end
    varying_m = cellstr(string(varying_m));
    programs_range = cellstr(string(programs_range));
    
    metric_names = {'Log$_{10}$ Average Time',  ...
                    'Average Ratio to Initiation',...
                    'Average Ratio to Lower Bound'};
    
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
        table_data = arrayfun(@(x) num2str(x,"%.2f"),table_data,...
                                                    'UniformOutput',false);
        %Join along the algorithms dim, creating a latex sub table to store
        %the result of all algorithms for each combination of machines and
        %number of programs.
        table_data = reshape(join(table_data, "\\", 1), ...
                        number_dif_programs, number_dif_machine_props)';
        
        if number_of_algs > 1
            input.data = cellstr("\begin{tabular}{@{}c@{}}" ...
                          + table_data ...
                          + "\end{tabular}");
        else
            input.data = cellstr(table_data);
        end
        
        % Setting row and column labeks
        input.tableColLabels = programs_range;
        input.tableRowLabels = varying_m;

        % A string is being placed each cell
        input.dataFormat = {'%s'}; 

        % Column alignment in Latex table ('l'=left-justified, 'c'=centered,'r'=right-justified):
        input.tableColumnAlignment = 'c';

        % Switch table borders on/off (borders are enabled by default):
        input.tableBorders = 1;

        % A flag to indicate this table will be placed inside another
        input.inner = true;

        % Constructs the specified table
        data_table = latexTable(input);
        
        %Then we place this created table inside another.
        
        input.data = join(data_table);

        % Setting row and column labels
        input.tableColLabels = cellstr("Number of Jobs");
        %The row label is itself a table listing the different algs
        input.tableRowLabels = cellstr("\begin{tabular}{@{}c@{}}" ...
                              + "Machine Proportion\\" ...
                              + join(alg_names,"\\")...
                              + "\end{tabular}");

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