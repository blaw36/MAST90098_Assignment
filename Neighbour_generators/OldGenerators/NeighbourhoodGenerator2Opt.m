classdef NeighbourhoodGenerator2Opt < handle
    %Just 2 optimized, no longer uses cells or returns values in next.
    %Have to access programs and order from object if want to use.
    
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
    
    %TODO: Tidy/Refactor Big time
    %TODO: Optimize - Especially on cycle duplicates issue.
    
    properties
        k %the exchange number
        L %L(i) = the index of the ith loaded machine
        M %M(i) = the number of programs in machine i
        cycle % boolean indicating whether generating cycles or paths
        
        num_loaded
        num_machines
        
        loaded
        loaded_i = 1
        loaded_end
        
        other_m
        other_m_i = 1
        other_m_end
        
        machine_order
        machine_order_i = 1
        machine_order_end
        
        programs
        programs_i = 1
        programs_end
        
        order %The order specifying a cycle or path
        curr %{order_specifying_path/cycles, target_programs}
        done = false %boolean indicating whether exhausted neighbourhood
    end

    methods
        function obj = NeighbourhoodGenerator2Opt(k, L, M)
            obj.k = k;
            obj.L = L;
            obj.M = M;
            obj.cycle = true;
            
            %Calculated params
            obj.num_loaded = length(L);
            obj.num_machines = length(M);
            
            %Create initial Values
            obj.loaded = combnk(L,1);
            obj.loaded_end = length(obj.loaded);

            obj.other_m = combnk(1:(obj.num_machines-1),obj.k-1);
            obj.other_m_end = length(obj.other_m);

            obj.machine_order = perms(1:obj.k);
            obj.machine_order_end = length(obj.machine_order);
            
            obj.construct_order()
            obj.construct_programs()
        end
        
        function construct_order(obj)
            %Combines the information in the machine related generators to
            %display the selected machines in their selected order.
            selected_loaded = obj.loaded(obj.loaded_i);
            other_machines = cat(2, 1:(selected_loaded-1), ...
                            (selected_loaded+1):obj.num_machines);
            selected_other_machines = ...
                            other_machines(obj.other_m(obj.other_m_i,:));
            
            select_machines = cat(2,selected_other_machines, ...
                                selected_loaded);

            obj.order = select_machines( ...
                                obj.machine_order(obj.machine_order_i,:));
        end
        
        function construct_programs(obj)
            %Using the current order of machines constructs all ways to
            %move programs between these machines.
            %TODO: Optimise this
            progs_per_machine = obj.M(obj.order);
            
            if obj.cycle == false
                progs_per_machine = progs_per_machine(1:obj.k-1);
            end
            
            %Initialise programs array
            rows = prod(progs_per_machine);
            cols = length(progs_per_machine);
            %obj.programs = zeros(rows, cols);
            
            %Iterating through like this in effect creates a cartesian prod
            %for j = 1:cols
            %    obj.programs(:,j) = mod(1:rows,progs_per_machine(j))+1;
            %end
              
            obj.programs = mod(...
            repmat(linspace(1,rows,rows).', 1, cols), progs_per_machine)+1;
            
            obj.programs_i = 1;        
            obj.programs_end = rows;        
        end

        function next(obj)
            
            obj.programs_i = obj.programs_i+1;
            if obj.programs_i > obj.programs_end
                obj.machine_order_i = obj.machine_order_i+1;
                if obj.machine_order_i > obj.machine_order_end
                    obj.other_m_i = obj.other_m_i+1;
                    if obj.other_m_i > obj.other_m_end
                        obj.loaded_i = obj.loaded_i+1;
                        if obj.loaded_i > obj.loaded_end
                            if obj.cycle
                                %Move on to paths
                                obj.cycle = false;
                            else
                                obj.done = true;
                            end
                            %Reset loaded
                            obj.loaded_i = 1;
                        end
                        %Reset other_m
                        obj.other_m_i = 1;                        
                    end
                    %Reset machine_order
                    obj.machine_order_i = 1;                    
                end
                %Reset whole order
                obj.construct_order();
                %Reset programs
                obj.construct_programs();        
            end
        end
    end
end