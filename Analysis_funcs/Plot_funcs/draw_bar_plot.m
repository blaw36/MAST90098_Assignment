function plot = draw_bar_plot(output, num_machines)
    [common, freq] = mode(output(:,2)); % Get machine with highest number of jobs
    new_data = zeros(num_machines,freq); % Create an array with machines x max jobs
    for i = 1:num_machines % Assign machine-wise
        machine_jobs = output(output(:,2) == i,1)';
        machine_jobs = [machine_jobs, zeros(1,freq - length(machine_jobs))]; % Pad with zeroes
        new_data(i,:) = machine_jobs;
    end
    plot = bar(new_data, 'stacked');
    if size(new_data,1) == 1
        new_data = [new_data; nan(1,freq)];
        plot = bar(new_data, 'stacked');
        set(gca,'xtick',1)
    end
end