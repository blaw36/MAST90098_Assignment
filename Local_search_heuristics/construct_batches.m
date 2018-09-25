%% construct_batches.m
% Constructs batches of machine combinations to be processed by workers
% (parallelisation on computer)
%   TODO: Tune parameters for dynamic switching
%% Input:
    % L: The machine numbers of all the loaded machines
    % M: The number of (movable) programs in each machine
    % k: The size of the k-exchange
    % num_machines: The number of machines
%% Output:
    % batches: a list with the data required for each batch of machine 
        % orders to be processed
    % num_batches: the number of batches
    % valid_orders: the orders to be processed in batch
    % use_par: a flag indicating whether to use parallel or not
%%
function [batches, num_batches, valid_orders, use_par] = construct_batches(L, M, k, ...
                 num_machines)
    use_par = false;
    %global BATCH_DIV_PARAM;
    BATCH_DIV_PARAM = 5*10^5;
    
    % Pair each loaded machine with all other machines excluding self. Has
        % size |L|*(m-1)
    % Initiate outer column first to fix matrix size
    valid_machines(:,2) =  repelem(L,num_machines-1);
    % Vectorise this
    % Generate all pairs, excluding L(i)
    curr = 1;
    for i = 1:length(L)
        next = curr + num_machines - 2;
        valid_machines(curr:next,1) = [1:(L(i)-1),(L(i)+1):num_machines]';
        curr = next+1;       
    end
    
    %As the number of valid orders is not known ahead of time can't
    %pre-allocate, however it is not a large time sink to v-stack the
    %new_valid_orders twice.
    valid_orders = [];
    sum_valid = 0;
    
    % Allocate work (if req'd) by splitting into sets of only paths, then 
    % of only cycles
    num_batches = 0;
    for c = 1:2
        cycle = logical(c-1);
        length_move = k-not(cycle);
        
        if cycle
            % Set the loaded machine as fixed
            orders = valid_machines;
        else
            % Generate all combos - as k=2 for this script, quick method to
            % add in the machine combos, and the reverse
            orders = [valid_machines;valid_machines(:,2),valid_machines(:,1)];
        end

        [new_valid_orders, num_new_valid] = generate_valid_orders(...
            k, M, cycle, orders);
        
        %V-stack new orders see init of valid_orders
        valid_orders = [valid_orders; new_valid_orders];

        if num_new_valid == 0
            continue
        end
        
        %TODO: Tune
        % max(M(L))^2*num_valid^2
        % num_workers = idivide(int32(max(M(L))^2*num_valid^2), 1.0*10^9);
        % fprintf("%d, %d\n",max(M(L)),num_valid);
        old_num_batches = num_batches;
        % Idea is here is big oh for k=2 is O(max(M(L))^2 m^2) (check)
        % So should look for a threshold in terms of this larger behavior
        % to determine where to split/create our batches.
        % If we don't exceed this threshold, then no need to have multiple
        % batches.
        check = num_new_valid*max(M(L))^2/BATCH_DIV_PARAM;
        if check > 0.5
            use_par = true;
        end
        new_batches = 1+floor(check);
        num_batches = num_batches + new_batches;
        
        batches(num_batches).move = {};
        batches(num_batches).batch = {};
        
        %Seting the size of batches by using ceil, will 'overallocate' to
        %batches before last => last batch won't have a full load but
        %just the remainder
        batch_size = ceil(num_new_valid/new_batches);
        for i = 1:new_batches
            start = (i-1)*batch_size+1 + sum_valid;
            %Last batch only gets remainder
            finish = min(i*batch_size, num_new_valid) + sum_valid;
            
            %Store information needed to process batch in batches
            batch_index = i+old_num_batches;
            batches(batch_index).start = start;
            batches(batch_index).finish = finish;            
            batches(batch_index).size = finish + 1 - start;
            batches(batch_index).cycle = cycle;
            batches(batch_index).length_move = length_move;
        end
        sum_valid = sum_valid + num_new_valid;
    end
end