function [valid_order, num_valid] = generate_valid_orders(k, L, M, cycle,...
                                        selected_machines, machine_order)
    
    valid_order = selected_machines(:, machine_order);
    %Prune elements of the order that are between empty machines
    if cycle
        %Drop all with a single empty machine in the order
        valid_order = valid_order(min(M(valid_order),[],2)~=0,:);
    else
        %Drop all with a single empty machine in the order
        %which isn't the last
        drawn_from = valid_order(:,1:k-1);
        %if only one machine check non-empty
        if size(drawn_from,2) == 1
            valid_order = valid_order(M(drawn_from)~=0,:);
        %otherwise check all machines_non_empty
        else
            valid_order = valid_order(min(M(drawn_from),[],2)~=0,:);
        end
    end
    %Prune elements of the order that don't have a loaded machine
    valid_order = valid_order(any(ismember(valid_order,L),2),:);
    
    num_valid = size(valid_order, 1);
end

