classdef NeighbourhoodGenerator < Generator
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
    %With iterative alg we start with 'smallest' member. Then iterate up
    %all the values of P until we 'overflow' into O, until O 'overflows'
    %into N, and so on, until we reach the end.
    
    %TODO: Tidy/Refactor Big time
    %TODO: Optimize - Especially on cycle duplicates issue.
    
    properties (Access = private)
        k %the exchange number
        L %L(i) = the index of the ith loaded machine
        M %M(i) = the number of programs in machine i
        cycle % boolean indicating whether generating cycles or paths
        
        num_loaded
        num_machines
        
        %The generators used, listed according to their order
        loaded_generator
        other_m_generator
        machine_order_generator
        programs_generator
        
        loaded_indices %last output of loaded_generator
        other_m_indices %last output of other_m_generator
        machine_order_indices %last output of machine_order_generator
        
        order %The order specifying a cycle or path
        programs %The programs to be moved, specified by index in machine.
    end

    methods
        function obj = NeighbourhoodGenerator(k, L, M)
            obj.k = k;
            obj.L = L;
            obj.M = M;
            obj.cycle = true;
            
            %Calculated params
            obj.num_loaded = length(L);
            obj.num_machines = length(M);
            
            %Generators
            obj.loaded_generator = CombinationGenerator(obj.num_loaded,1);
            obj.other_m_generator = ...
                        CombinationGenerator(obj.num_machines-1, obj.k-1);
            obj.machine_order_generator = PermutationGenerator(k);
            
            %Top of each generator
            obj.loaded_indices = obj.loaded_generator.next();
            obj.other_m_indices = obj.other_m_generator.next();
            obj.machine_order_indices = obj.machine_order_generator.next();
            
            %Program generator depends on order
            obj.construct_order();
            obj.programs_generator = ProgramsGenerator(obj.M(obj.order));
            
            obj.programs = obj.programs_generator.next();
            
            %Get first value
            obj.curr = {obj.order,obj.programs};
        end
        
        function construct_order(obj)
            %Combines the information in the machine related generators to
            %display the selected machines in their selected order.
            selected_loaded_index = obj.L(obj.loaded_indices);
            other_machines_indices = cat(2, 1:(selected_loaded_index-1), ...
                            (selected_loaded_index+1):obj.num_machines);
            selected_other_machines_indices = ...
                            other_machines_indices(obj.other_m_indices);
            
            select_machines = cat(2,selected_other_machines_indices, ...
                                selected_loaded_index);
            
            obj.order = select_machines(obj.machine_order_indices);
        end
        
        function val = next(obj)
            %Generates the neighbourhood.
            %The lowest generator tries to iterate, if it is done, then the
            %next lowest tries to iterate, and so on.
            %Whenever an 'upper' generator is done it reset the generators
            %below it.
            
            %val = {order, programs}
            val = obj.curr;
            if obj.programs_generator.done
                if obj.machine_order_generator.done
                    if obj.other_m_generator.done
                        if obj.loaded_generator.done
                            if obj.cycle
                                %Move on to paths
                                obj.cycle = false;
                            else
                                obj.done = true;
                            end
                            %Reset loaded_generator
                            obj.loaded_generator = ...
                                 CombinationGenerator(obj.num_loaded, 1);
                        end
                        obj.loaded_indices = obj.loaded_generator.next();
                        %Reset other_m_generator
                        obj.other_m_generator = ...
                          CombinationGenerator(obj.num_machines-1,obj.k-1);
                    end
                    obj.other_m_indices = obj.other_m_generator.next();
                    %Reset machine_order_generator
                    obj.machine_order_generator = ...
                                               PermutationGenerator(obj.k);
                end
                obj.machine_order_indices = ...
                                       obj.machine_order_generator.next();
                %Reset programs_generator
                obj.construct_order();
                target_progs = obj.M(obj.order);
                if obj.cycle == false
                    target_progs = target_progs(1:obj.k-1);
                end
                obj.programs_generator = ProgramsGenerator(target_progs);
            end
            obj.programs = obj.programs_generator.next();
            obj.curr = {obj.order, obj.programs};
        end
    end
end