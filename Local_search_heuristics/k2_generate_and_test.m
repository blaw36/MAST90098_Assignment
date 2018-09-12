% Generates and tests the neighbourhood of the current instance
%       Optimised for k=2
%   TODO: Update this
%% Input:
%   %num_machines: The number of machines
%   %k: The size of the k-exchange
%   %L: The machine numbers of all the loaded machines
%   %M: The number of (movable) programs in each machine
%   %cycle: Whether the order is encoding a cycle or not
%   %machine_costs: The costs of all machines
%   %machine_start_indices: The ith value indicates which row of the
%       output_array the ith machine first appears
%   %program_costs: The cost of the programs ordered as in output_array
%% Ouput:
%   %best_neighbour = {order, programs} encoding move to best found
%   %best_makespan
%%
function [best_neighbour, best_makespan] = k2_generate_and_test(L, M,...
                 machine_costs, machine_start_indices, program_costs)
    k=2;
    num_selected = k;
    num_machines = length(machine_start_indices);
    %Prune selections of machines without a loaded machine
    %valid_machines = selected_machines(...
    %    any(ismember(selected_machines,L),2),:);
    
    %Pair each loaded machine with all other machines excluding self
    % has size |L|*(m-1)
    %Initiate outer column first to fix size
    valid_machines(:,2) =  repelem(L,num_machines-1);
    %Vectorise this
    curr = 1;
    for i = 1:length(L)
        next = curr + num_machines - 2;
        valid_machines(curr:next,1) = [1:(i-1),(i+1):num_machines]';
        curr = next+1;       
    end

    batch_makespans = Inf(2,1);
    batch_neighbours(2).move = {};
    
    %TODO: Maybe could have a check on the prod(M) here to determine
    %whether to use parfor or for?
    parfor c = 1:2
        cycle = logical(c-1);
        length_move = num_selected-not(cycle);
        
        if cycle
            orders = valid_machines;
        else
            orders = [valid_machines;valid_machines(:,2),valid_machines(:,1)];
        end

        [valid_orders, num_valid] = generate_valid_orders(...
            k, M, cycle, orders);

        if num_valid == 0
            continue
        end

        for i = 1:num_valid
            order = valid_orders(i,:);
            [programs, num_programs] = generate_programs(order, M, k, cycle);

            %Test
            [min_neigh_makespan, prog_index] = find_min_neighbour(...
                            order, programs, ...
                            machine_costs, machine_start_indices, ...
                            program_costs, ...
                            num_programs, num_selected, length_move);

            if min_neigh_makespan < batch_makespans(c)
                batch_makespans(c) = min_neigh_makespan;
                batch_neighbours(c).move = {order, programs(prog_index,:)};
            end
        end
    end
    [best_makespan, loc] = min(batch_makespans);
    best_neighbour = batch_neighbours(loc).move;
end