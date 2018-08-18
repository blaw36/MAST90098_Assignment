function plot = draw_bar_plot(output, num_machines)
    [common, freq] = mode(output(:,2));
    new_data = zeros(num_machines,freq);
    for i = 1:num_machines
        machine_jobs = output(output(:,2) == i,1)';
        machine_jobs = [machine_jobs, zeros(1,freq - length(machine_jobs))]; % Pad with zeroes
        new_data(i,:) = machine_jobs;
    end
    plot = bar(new_data, 'stacked');
end