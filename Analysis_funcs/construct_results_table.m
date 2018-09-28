%% construct_results_table.m
%% Input:

%%

function construct_results_table(results, alg_names, alg_subset, ...
                        programs_range, machines_denom_iterator, save_path)
    %Use empty string to signify no save path
    if ~exist('save_path','var')
        save_path = "";
    end
    
    number_of_algs = size(alg_subset,2);
    number_dif_programs = size(programs_range,2);
    number_dif_machine_props = size(results,3);
    number_of_metrics = size(results,4);
    
    alg_names = alg_names(alg_subset);
    subset = zeros(number_of_algs, number_dif_programs, ...
                      number_dif_machine_props, number_of_metrics);
    
    %Construct strings that will be used in labelling the tables
    varying_m = 1/machines_denom_iterator:1/machines_denom_iterator:1;
    varying_m = cellstr(string(varying_m));
    programs_range = cellstr(string(programs_range));
    
    metric_names = {'Log$_{10}$ Average Time',  ...
                    'Average Ratio to Initiation',...
                    'Average Ratio to Lower Bound'};
    
    for a_i = alg_subset
        for n_j = 1:number_dif_programs
            size(results)
            a_i
            n_j
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

        input.data = cellstr("\begin{tabular}{@{}c@{}}" ...
                          + table_data ...
                          + "\end{tabular}");
        
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
        input.tableCaption = metric_names{i};
        input.tableLabel = metric_names{i};

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
            %Save to path
            fid=fopen(save_path+"m"+string(i)+'.tex','w');
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