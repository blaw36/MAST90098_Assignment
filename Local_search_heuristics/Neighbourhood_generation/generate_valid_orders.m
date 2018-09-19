%% generate_valid_orders.m
% Constructs all valid orders of machines. Invalid orders include:
    % - Moving elements out of empty machines
    % - Involving an empty machine in a cycle such that it remains empty
    % - Involving an empty machine in a path such that it remains empty
        % (all cases unless empty machine is the end point of the path)
%% Input:
    % k: the number of machines involved
    % M: The number of (movable) programs in each machine
    % cycle: Whether the order is encoding a cycle or not
    % orders: All possible orders of machines without considering 
        % whether valid orders or not
%% Output:
    % valid_orders: A matrix encoding the valid ways to order the machine.
    % num_valid: The number of rows of the 'valid_orders' matrix
%%

function [valid_orders, num_valid] = generate_valid_orders(k, M, cycle,...
                                        orders)
                                    
    % Prune elements of the order that try to move from empty machines
    if cycle
        % Drop all with a single empty machine
        valid_orders = orders(min(M(orders),[],2)~=0,:);
    else
        % Drop all with a single empty machine which isn't the last
        not_last = orders(:,1:k-1);
        
        % if only one machine check non-empty
        if size(not_last,2) == 1
            valid_orders = orders(M(not_last)~=0,:);
        % otherwise check all machines_non_empty
        else
            valid_orders = orders(min(M(not_last),[],2)~=0,:);
        end
    end
    
    num_valid = size(valid_orders, 1);
end

