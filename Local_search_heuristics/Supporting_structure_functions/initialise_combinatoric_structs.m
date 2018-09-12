% Initialises the supporting combinatoric structs
%% Input:
%   %num_machines: the number of machines
%   %k: the k-exchange
%% Ouput:
%   TODO: Structs incurr overhead
%       Other way?, not sure if possible variable shape arrays
%       Fine tune for particular values of k
%   TODO: Cause this is no longer done iteratively runs into memory 
%         constraints at about 40000 machines for k=2
%
%   %selected_machines: Encodes all the way to select k machines
%        Selected_machines has 3 dims , (d=[2,..,k], combs=matrix())
%   %machine_orders: Encodes all the ways to order those machine
%       machine_orders has 4 dims 
%           ([2,..,k],[1,2] , orders_for_d_cycle=matrix())
%   %machine_orders_end: Encodes all the ways to order those machine
%       machine_orders_end has 3 dims 
%           ([2,..,k],[1,2] , num rows in matrix)
%%
function [selected_machines, machine_orders, machine_orders_end] = ...
                        initialise_combinatoric_structs(num_machines, k)
    
    if  k==2
        
%         selected_machines(:,2) = ...
%                         repelem(1:(num_machines-1),(num_machines-1):-1:1);
%         %Vectorise this
%         curr = 1;
%         for i = 2:num_machines
%             next = curr + num_machines-i;
%             selected_machines(curr:next,1) = (i:num_machines)';
%             curr = next+1;       
%         end 
        machine_orders = [];
        machine_orders_end = 0;
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
            %TODO: This becomes a big bottleneck performance-wise
            % as default matlab imp is really slow
            selected_machines(d-1).data = combnk(1:num_machines, d);
        end
        
        cycle = true;
        %Fix the first element and then perm the remainder.
        machine_orders(d-1,cycle+1).data = [ones(prod(1:(d-1)),1),perms(2:d)];
        machine_orders_end(d-1,cycle+1) = prod(1:(d-1));
        
        %paths
        cycle = false;
        machine_orders(d-1,cycle+1).data = perms(1:d);
        machine_orders_end(d-1,cycle+1) = prod(1:d);
    end
end