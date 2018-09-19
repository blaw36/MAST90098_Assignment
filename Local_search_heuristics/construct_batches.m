%% construct_batches.m
% Constructs batches of machine combinations to be processed by workers
% (parallelisation on computer)
%   TODO: Tune parameters for dynamic switching (Two of them/ one formula)
%% Input:
    % L: The machine numbers of all the loaded machines
    % M: The number of (movable) programs in each machine
    % k: The size of the k-exchange
    % num_machines: The number of machines

%% Output:
    % batches: a list with the data required for each batch of machine 
        % orders to be processed
    % num_batches: the number of batches
    % use_par: a flag indicating whether to use parallel or not
%%
function [batches, num_batches, use_par] = construct_batches(L, M, k, ...
                 num_machines)
    use_par = false;
    BATCH_DIV_PARAM = 4*10^8;
    
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

        [valid_orders, num_valid] = generate_valid_orders(...
            k, M, cycle, orders);

        if num_valid == 0
            continue
        end
        
        %TODO: Tune
        % max(M(L))^2*num_valid^2
        % num_workers = idivide(int32(max(M(L))^2*num_valid^2), 1.0*10^9);
        % fprintf("%d, %d\n",max(M(L)),num_valid);
        old_num_batches = num_batches;
        % Idea is here is big oh for k=2 is O(max(M(L))^2 m^2) (check)
        % So should look for a threshold in terms of this larger behavior
        % if we want to  batch together jobs of 'similar' difficulty.
        % If we don't exceed this threshold, then no need to have multiple
        % batches.
        new_batches = max([1,idivide(int32(num_valid*max(M(L)))^2, BATCH_DIV_PARAM)]);
        num_batches = num_batches + new_batches;
        
        batches(num_batches).move = {};
        batches(num_batches).batch = {};
        batch_est_size = idivide(int32(num_valid),new_batches);
        
        for i = 1:new_batches
            start = (i-1)*batch_est_size+1;
            finish = max(i*batch_est_size, num_valid);
            batches(i+old_num_batches).batch = valid_orders(start:finish,:);
            batches(i+old_num_batches).size = finish + 1-start;
            batches(i+old_num_batches).cycle = cycle;
            batches(i+old_num_batches).length_move = length_move;
        end
        
        %We have split the data (for either cycles or paths) which
        %indicates we think we have enough data to warrant parallel
        if new_batches>1
            use_par = false;
        end
    end
end