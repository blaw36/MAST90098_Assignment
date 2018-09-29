%% initialise_combinatoric_structs.m
% Initialises the supporting combinatoric structs used to navigate around
% the neighbourhoods of instances.
%% Input:
    % num_machines: the number of machines
    % k: the k-exchange
%% Output:
    % selected_machines: Encodes all the ways to select d = 2,...,k 
        % machines from m. 
        % selected_machines(i).data = a matrix encoding ncr(m,i)
    % machine_orders: Encodes all the ways to order those k machines as
        % cycles and as paths
        % machine_orders(i, 1).data = 
        %      all the ways to order those k machines in a path
        % machine_orders(i, 2).data = 
        %      all the ways to order those k machines in a cycle
%%
function [selected_machines, machine_orders] = ...
                        initialise_combinatoric_structs(num_machines, k)    
    % Iterate backwards so size doesn't change
    for d = k:-1:2
        %An improved version for d==2
        if d == 2
            % Outer column first so doesn't change size
            selected_machines(d-1).data(:,2) = ...
                        repelem(1:(num_machines-1),(num_machines-1):-1:1);

            curr = 1;
            for i = 2:num_machines
                next = curr + num_machines-i;
                selected_machines(d-1).data(curr:next,1) = (i:num_machines)';
                curr = next+1;       
            end 
        else
            % This becomes a big bottleneck performance-wise
            % as default matlab implementation is really slow
            selected_machines(d-1).data = combnk(1:num_machines, d);
        end
        
        % Cycles
        cycle = true;
        % Fix the first element and then perm the remainder to generate all
        % cycles starting/ending at the first element
        machine_orders(d-1,cycle+1).data = [ones(prod(1:(d-1)),1),perms(2:d)];
        
        % Paths - perm all elements, no fixed first element
        cycle = false;
        machine_orders(d-1,cycle+1).data = perms(1:d);
    end
end