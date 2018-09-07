% Constructs all valid orders of machines.
%% Input:
%   %L: The machine numbers of all the loaded machines
%   %M: The number of (movable) programs in each machine
%   %cycle: Whether the order is encoding a cycle or not
%   %orders: All possible orders without considering restrictions
%% Ouput:
%   %valid_orders: A matrix encoding the valid ways to order the machine.
%   %num_valid: The number of rows of the matrix
%%

function [valid_orders, num_valid] = generate_valid_orders(k, L, M, cycle,...
                                        orders)
                                    
    %Prune elements of the order that don't include a loaded machine
    %Note this order of pruning is faster
    valid_orders = orders(any(ismember(orders,L),2),:);
    
    %Prune elements of the order that try to move from empty machines
    if cycle
        %Drop all with a single empty machine
        valid_orders = valid_orders(min(M(valid_orders),[],2)~=0,:);
    else
        %Drop all with a single empty machine which isn't the last
        not_last = valid_orders(:,1:k-1);
        
        %if only one machine check non-empty
        if size(not_last,2) == 1
            valid_orders = valid_orders(M(not_last)~=0,:);
        %otherwise check all machines_non_empty
        else
            valid_orders = valid_orders(min(M(not_last),[],2)~=0,:);
        end
    end
    
    num_valid = size(valid_orders, 1);
end

