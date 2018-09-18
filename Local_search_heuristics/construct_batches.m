% Constructs batches of orders of machines to be processed by workers.
%   TODO: Tune parameters for dynamic switching (Two of them/ one formula)
%% Input:
%   %L: The machine numbers of all the loaded machines
%   %M: The number of (movable) programs in each machine
%   %k: The size of the k-exchange
%   %num_machines: The number of machines
%% Ouput:
%   %batches: the batches of machine orders to be processed
%   %num_batches: the number of batches
%   %use_par: a flag indicating whether to use parallel or not
%%
function [batches, num_batches, use_par] = construct_batches(L, M, k, ...
                 num_machines)
    use_par = false;
    
    %Pair each loaded machine with all other machines excluding self
    % has size |L|*(m-1)
    %Initiate outer column first to fix size
    valid_machines(:,2) =  repelem(L,num_machines-1);
    %Vectorise this
    curr = 1;
    for i = 1:length(L)
        next = curr + num_machines - 2;
        valid_machines(curr:next,1) = [1:(L(i)-1),(L(i)+1):num_machines]';
        curr = next+1;       
    end
    
    %Construct all the batches for processing
    sum_valid = 0;
    num_batches = 0;
    for c = 1:2
        cycle = logical(c-1);
        length_move = k-not(cycle);
        
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
        
        %TODO: Tune
        %max(M(L))^2*num_valid^2
        %num_workers = idivide(int32(max(M(L))^2*num_valid^2), 1.0*10^9);
        %fprintf("%d, %d\n",max(M(L)),num_valid);
        new_workers = 1 + idivide(int32(num_valid*max(M(L))), 2.0*10^4);
        num_batches = num_batches + new_workers;
        
        batches(num_batches).move = {};
        batches(num_batches).batch = {};
        batch_est_size = idivide(int32(num_valid),new_workers);
        
        for i = 1:new_workers
            start = (i-1)*batch_est_size+1;
            finish = max(i*batch_est_size, num_valid);
            batches(i).batch = valid_orders(start:finish,:);
            batches(i).size = finish + 1-start;
            batches(i).cycle = cycle;
            batches(i).length_move = length_move;
        end
        
        sum_valid = sum_valid + num_valid;
    end
    %TODO: Tune
    if sum_valid > 10^4
        use_par = true;
    end
end