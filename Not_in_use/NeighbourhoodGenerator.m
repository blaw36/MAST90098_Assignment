classdef NeighbourhoodGenerator < handle
    % You only call next when you want the next order, and the accompanying
    % set of all possible ways to move programs between them.
    
    %Iteratively generates the neighbourhood of the current instance.
    %
    % For the k-exchange neighborhood:
    %   All paths and cycles that involve k machines, in which at least one
    %   of the k machines is loaded.
    %
    %The Neighbourhood of an instance can be viewed as LxNxOxP where,
    %   L - choose a loaded machine
    %   N - choose k-1 other machines from m-1 remaining machines
    %   O - list all permutations of these k selected machines
    %   P - list all the ways to move programs between these k machines
    %
    %The problem of generating a neighbourhood can be viewed as
    %establishing an order between elements of the neighbourhood then
    %start at the smallest and repeatedly move to the next until done.
    %
    %If you have two ordered sets A, B then one way to order the AxB is to
    %sort by A, then sort by B.
    %
    %So, on our Neighbourhood could sort in order (L,N,O,P).
    %
    %This generator holds in memory, all of the ways to generate each of
    %(L,N,O,P) then combines this information together iteratively.
    %
    %This means the memory requirement,
    %   is O(|L|+|N|+|O|+|P|), instead of O(|LxNxOxP|).
    %
    %So we can compute all of these sub-components quickly then index
    %through them, to iterate through our neighbourhood.
    
    %TODO: Further Tidy/Refactor
    %TODO: Optimize -
    %
    % Could maybe optimized by switching to using largely column vectors
    % (as matlab uses column major order)
            
    
    properties
        k %the exchange number
        L %L(i) = the index of the ith loaded machine
        M %M(i) = the number of programs in machine i
        cycle % boolean indicating whether generating cycles or paths
        
        num_loaded %Size L
        num_machines %Size M
        
        selected_machines % The m selected machines
        selected_machines_i = 1 %The current row of the matrix
        selected_machines_end = 0 %The number of rows of the matrix
        
        machine_order %a matrix encoding the order of the selected machines
        machine_order_i = 1 %The current row of the matrix
        machine_order_end = 0 %The number of rows of the matrix
        
        valid_order %The valid orderings of the selected_machines
        valid_order_i = 1 %The current row of the matrix
        valid_order_end = 0 %The number of rows of the matrix
        
        programs % Prod_i(|M_i|)x(k or k-1) matrix encoding progs to move
        programs_end = 0 %The number of rows of the matrix
        
        order %The order specifying a cycle or path
        curr %{order_specifying_path/cycles, target_programs}
        done = false %boolean indicating whether exhausted neighbourhood
    end

    methods
        function obj = NeighbourhoodGenerator(k, L, M)
            obj.k = k;
            obj.L = L;
            obj.M = M;
            obj.cycle = true; %Do cycles first
            
            %Calculated params
            obj.num_loaded = length(L);
            obj.num_machines = length(M);
            
            %Create initial Values
            
            %Choose k machines from m            
            obj.selected_machines = combnk(1:obj.num_machines,obj.k);
            obj.selected_machines_end = size(obj.selected_machines,1);
            
            %Order those k machines
            obj.construct_order();
            
            %Calls the first next
            obj.next()
        end
        
        function construct_order(obj)
            if obj.cycle
                %Can be viewed as selecting a neclace, see Wikipedia
                %Fix the first element and then perm the remainder.
                %TODO: Product
                obj.machine_order_end = factorial(obj.k-1);
                obj.machine_order = [
                        ones(factorial(obj.k-1),1), perms(2:obj.k)
                ];                
            else
                obj.machine_order_end = factorial(obj.k);
                obj.machine_order = perms(1:obj.k);
            end
        end
        
        function order_selected(obj)
            %Combines the information in the machine related generators to
            %display the selected machines in their selected order.
%             M = obj.M
%             select = obj.selected_machines
%             order = obj.machine_order
%             selected_order = obj.machine_order(obj.machine_order_i,:)
            %Orders the selected using the machine_order permutation
            obj.valid_order = obj.selected_machines(:, ...
                                obj.machine_order(obj.machine_order_i,:));
            a = obj.valid_order;
            %Prune elements of the order that are between empty machines
            if obj.cycle
                %Drop all with a single empty machine in the order
                obj.valid_order = obj.valid_order(...
                                    min(obj.M(obj.valid_order),[],2)~=0,:);
            else
                %Drop all with a single empty machine in the order
                %which isn't the last
                drawn_from = obj.valid_order(:,1:obj.k-1);
                %if only one machine check non-empty
                if size(drawn_from,2) == 1
                    obj.valid_order = obj.valid_order(obj.M(drawn_from)~=0,:);
                %otherwise check all machines_non_empty
                else
                    obj.valid_order = obj.valid_order(...
                        min(obj.M(drawn_from),[],2)~=0,:);
                end
            end
            b = obj.valid_order;  
            %Prune elements of the order that don't have a loaded machine
            obj.valid_order = obj.valid_order(...
                                any(ismember(obj.valid_order,obj.L),2),:);
            c = obj.valid_order;  
            
            %TODO: Could shuffle valid_order for greater diversity
            
            obj.valid_order_end = size(obj.valid_order, 1);
            obj.valid_order_i = 1;
        end
        
        function construct_programs(obj)
            %Using the current order of machines constructs all ways to
            %move programs between these machines.
%             v = obj.valid_order
%             o = obj.order
%             cycle = obj.cycle
            obj.order = obj.valid_order(obj.valid_order_i,:);
            progs_per_machine = obj.M(obj.order);
            
            if obj.cycle == false
                %Don't move anything from last machine
                progs_per_machine = progs_per_machine(1:obj.k-1);
            end
            
            %Initialise programs array
            rows = prod(progs_per_machine);
            cols = length(progs_per_machine);
            
            %In effect this constructs [m1]x[m2]x...x[mj]
            %   where   mi = progs_per_machine(i), 
            %           j = length(progs_per_machine)
            
            % This is still a bottleneck, but not so much anymore.
            % Also now considers all the permutations of programs
            
            % Idea here is the go 1,...,n_m, followed by
            % 1,1,...,2,2,...,n_{m-1},n_{m-1}
            % etc, cumulatively 'telescoping' outwards in the repetitions
            % from right to left
            
            divisors_repelem = zeros(1,cols);
            % Number of repeats (repelem) required for each program, for 
            % each machine except the last one
            divisors_repelem(:,cols) = 1;
            for k = (cols-1):-1:1
                divisors_repelem(:,k) = divisors_repelem(:,k+1).*progs_per_machine(k+1);
            end
            
            % Number of times the sequence of repeated programs, for each
            % machine, gets repeated
            divisors_repmat = zeros(1,cols);
            divisors_repmat(:,1) = 1;
            for k = 2:cols
                divisors_repmat(:,k) = divisors_repmat(:,(k-1)).*progs_per_machine(k-1);
            end
            
            % Put it all together
            intermed_programs = zeros(rows,cols);
            % Last column has no repeated elements, just repeated sequences
            intermed_programs(:,cols) = (repmat(1:progs_per_machine(cols), ...
                1, rows/progs_per_machine(cols)))';
            
            % The rest have repeated elements, and those sequences are then
            % repeated
            for k = (cols-1):-1:1
                intermed_programs(:,k) = (repmat(repelem(...
                    1:progs_per_machine(k),divisors_repelem(k)), 1, divisors_repmat(k)))';
            end
            
            % Put the first row last (first row = itself as part of n/hood)
            obj.programs = [intermed_programs(2:rows,:); ...
                intermed_programs(1,:)];
            
            %Using bsxfun is actually slower
            %obj.programs = bsxfun(@mod,(1:rows)',progs_per_machine)+1;
            
            obj.programs_end = rows;        
        end

        function next(obj)
            %When you have finished iterating through all programs for the
            %current order, call this to get generate next order and 
            %programs.
            
            while obj.done==false && obj.valid_order_i > obj.valid_order_end
                obj.machine_order_i = obj.machine_order_i+1;
                if obj.machine_order_i > obj.machine_order_end
                    %Selects different set of un-loaded machines
                    obj.selected_machines_i = obj.selected_machines_i+1;
                    if obj.selected_machines_i > obj.selected_machines_end
                        if obj.cycle
                            %Move on to paths
                            obj.cycle = false;
                            %Switch to using paths
                            obj.construct_order();
                        else
                            obj.done = true;
                        end
                        %Reset the selected loaded machine to first
                        obj.selected_machines_i = 1;
                    end
                    %Reset the selected permutation to first
                    obj.machine_order_i = 1;                    
                end
                %Updates the order
                obj.order_selected();
            end
            if obj.done == false
                %Updates the programs,
                obj.construct_programs();
                %Gets next valid_order
                obj.valid_order_i = obj.valid_order_i+1;
            end
        end
    end
end
