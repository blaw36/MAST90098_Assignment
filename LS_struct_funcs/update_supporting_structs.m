function [outputArray, machine_start_indices, M, machine_costs, ...
                                            outputMakespan, L] ...
    = update_supporting_structs(outputArray, num_machines, num_jobs)
     %Sorts outputArray by machine, then cost        
    outputArray = sortrows(outputArray,1);
    outputArray = sortrows(outputArray,2);
    
    %Find where the machine first appears in table (if at all)
    %Todo: Better way
    machine_start_indices = zeros(1,num_machines);
    for i = 1:num_jobs
        machine_start_indices(outputArray(num_jobs+1-i,2)) = num_jobs-i+1;
    end
    %Find M
    %Todo: Better way
    M = zeros(1,num_machines);
    for i = 1:num_machines
        M(i) = sum(outputArray(:,2)==i);
    end
    
    %TODO: Better Compute/Update new Costs
    %Todo: Better Compute/Update new L
    %for now
    machine_costs = zeros(1,num_machines);
    for i = 1:(length(machine_start_indices)-1)
        slice = [machine_start_indices(i), ...
                machine_start_indices(i+1)-1];
        if slice(1)>0 && slice(2)>0
            machine_costs(i) = sum(outputArray(slice(1):slice(2),1));
        elseif slice(1)>0
            machine_costs(i) = sum(...
                outputArray(slice(1):num_jobs,1));
        else
            machine_costs(i) = 0;
        end
    end
    %last
    if machine_start_indices(num_machines) == 0
        machine_costs(num_machines) = 0;
    else
        machine_costs(num_machines) = sum(outputArray(...
        machine_start_indices(num_machines):num_jobs,1));
    end
     
    outputMakespan = max(machine_costs);
    L = find(machine_costs==outputMakespan);
end

