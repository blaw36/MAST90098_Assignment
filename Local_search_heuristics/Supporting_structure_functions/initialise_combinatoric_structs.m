% Initialises the supporting combinatoric structs
%% Input:
%   %num_machines: the number of machines
%   %k: the k-exchange
%% Ouput:
%   %selected_machines: Encodes all the way to select k machines
%        Selected_machines has 3 dims , (d=[2,..,k], combs=matrix())
%   %machine_orders: Encodes all the ways to order those machines
%       machine_orders has 4 dims 
%           ([2,..,k],[1,2] , orders_for_d_cycle=matrix())
%%
function [selected_machines, machine_orders] = ...
                        initialise_combinatoric_structs(num_machines, k)
    
    if  k==2
        %Don't use comb data structures, just generate when needed later
        machine_orders = [];
        selected_machines = [];
        return
    end
    
    %Iterate backwards so size doesn't change
    for d = k:-1:2
        if d == 2
            %Outer column first so doesn't change size
            selected_machines(d-1).data(:,2) = ...
                        repelem(1:(num_machines-1),(num_machines-1):-1:1);
            %Vectorise this
            curr = 1;
            for i = 2:num_machines
                next = curr + num_machines-i;
                selected_machines(d-1).data(curr:next,1) = (i:num_machines)';
                curr = next+1;       
            end 
        else
            %This becomes a big bottleneck performance-wise
            % as default matlab imp is really slow
            selected_machines(d-1).data = combnk(1:num_machines, d);
        end
        
        cycle = true;
        %Fix the first element and then perm the remainder.
        machine_orders(d-1,cycle+1).data = [ones(prod(1:(d-1)),1),perms(2:d)];
        
        %paths
        cycle = false;
        machine_orders(d-1,cycle+1).data = perms(1:d);
    end
end