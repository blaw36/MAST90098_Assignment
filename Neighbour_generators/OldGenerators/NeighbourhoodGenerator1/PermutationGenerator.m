classdef PermutationGenerator < Generator
    %Iterates through all the permutations of length n using Heap's Alg.
    
    properties
        n
        c
        i
    end
    methods
        function obj = PermutationGenerator(n)
            obj.n = n;
            obj.curr = 1:n;
            
            %Extra information used by Heap's Alg
            obj.c = ones(1,n);
            obj.i = 1;
        end

        function val = next(obj)
            %Generates the next n_perm using Heap's Algorithm
            %https://en.wikipedia.org/wiki/Heap%27s_algorithm
            % Compared to wiki code - array indices changed [1,...,n]
            
            %val = [a1, a2, ..., an] where ai elem [1,..n] ai distinct.
            val = obj.curr;

            while obj.i <= obj.n
                if obj.c(obj.i) < obj.i
                    if mod(obj.i, 2) == 1
                         temp = obj.curr(1);
                         obj.curr(1) = obj.curr(obj.i);
                         obj.curr(obj.i) = temp;
                    else
                        temp = obj.curr(obj.c(obj.i));
                        obj.curr(obj.c(obj.i)) = obj.curr(obj.i);
                        obj.curr(obj.i) = temp;
                    end
                    obj.c(obj.i) = obj.c(obj.i) + 1;
                    obj.i = 1;
                    return
                else
                    obj.c(obj.i) = 1;
                    obj.i = obj.i + 1;
                end
            end
            obj.done = true;
            return
        end
    end
end

