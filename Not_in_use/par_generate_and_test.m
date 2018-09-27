%% par_generate_and_test.m
% Generates and tests the neighbourhood of the current instance
% (generalised for k > 2)
%% Input:
    % k: The size of the k-exchange
    % curr_makespan: the makespan of the current instance
    % L: The machine numbers of all the loaded machines
    % M: The number of (movable) programs in each machine
    % num_machines: The number of machines
    % machine_costs: The ith value indicates the cost of the ith machine
    % machine_start_indices: The ith value indicates which row of the 
        % output_array the ith machine first appears
    % program_costs: The cost of the programs ordered as in output_array
    % selected_machines: Encodes all all possible m choose k
        % combinations to select k machines (combs matrix)
        % Selected_machines has 3 dims , (d=[2,..,k], combs=matrix())
    % machine_orders: Encodes all the ways to order those k machines as
        % cycles and as paths (d_cycle matrix)
        % machine_orders has 4 dims 
        % ([2,..,k],[1,2] , orders_for_d_cycle=matrix())
    % greedy_flag: a boolean flag indicating whether greedy or not
%% Output:
    % best_neighbour = {order, programs} encoding move to best found
    % best_makespan: makespan value of lowest makespan ('best') neighbour
%%
function [best_neighbour, best_makespan] = par_generate_and_test(...
                 k, curr_makespan, L, M, ...
                 machine_costs, machine_start_indices, program_costs,...
                 selected_machines, machine_orders, greedy_flag)
    
    %Equivalent to if ~exist('greedy_flag','var')
    if nargin == 9
        greedy_flag = false;
    end
              
    best_makespan = inf;
    best_neighbour = {};
    
    %Take the union of all cycles and paths involving <= k machines
    for d = 2:k
        num_selected = d;
        
        %Prune selections of machines without a loaded machine
        valid_machines = selected_machines(d-1).data(...
            any(ismember(selected_machines(d-1).data,L),2),:);
        
        batch_makespans = Inf(2,1);
        batch_neighbours(2).move = {};
        
        parfor c = 1:2
            cycle = logical(c-1);
            length_move = num_selected-not(cycle);
            
            %Count the number of ways to order these valid machines
            n = numel(valid_machines(:, machine_orders(d-1, c).data));
            orders = reshape(...
               valid_machines(:, machine_orders(d-1, c).data),...
              n/d,d);

            [valid_orders, num_valid] = generate_valid_orders(...
                d, M, cycle, orders);

            if num_valid == 0
                continue
            end
            
            for i = 1:num_valid
                order = valid_orders(i,:);
                [programs, num_programs] = generate_programs(order, M, d, cycle);

                %Test
                [min_neigh_makespan, prog_index] = find_min_neighbour(...
                                order, programs, ...
                                machine_costs, machine_start_indices, ...
                                program_costs,...
                                num_programs, num_selected, length_move,...
                                curr_makespan, L, greedy_flag);
                            
                if min_neigh_makespan < batch_makespans(c)
                    batch_makespans(c) = min_neigh_makespan;
                    batch_neighbours(c).move = {order, programs(prog_index,:)};
                end
            end
        end
        [best_makespan, loc] = min(batch_makespans);
        best_neighbour = batch_neighbours(loc).move;
    end
end