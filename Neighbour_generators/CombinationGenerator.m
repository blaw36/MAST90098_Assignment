classdef CombinationGenerator < Generator
    %Iteratively generates all ways to choose k of n distinct elements.
    properties
        n
        k
    end
    methods
        function obj = CombinationGenerator(n, k)
            obj.n = n;
            obj.k = k;
            obj.curr = 1:k;
        end

        function val = next(obj)
            % Alg idea from https://en.wikipedia.org/wiki/Combination
            % Looks like could optimize further 
            %https://stackoverflow.com/questions/127704/algorithm-to-return-all-combinations-of-k-elements-from-n
            
            %val = [a1, a2, ..., ak] where ai elem [1,..n] ai distinct.
            val = obj.curr;
            
            %increment the last num if lower than n
            if obj.curr(obj.k) < obj.n
                obj.curr(obj.k) = obj.curr(obj.k) + 1;
                return
            end
            %or last index num x : curr(x)<curr(x+1)-1
            % and reseting indices after x to [x+1, x+2, ...]
            for i = obj.k:-1:2
                if obj.curr(i-1) < obj.curr(i) -1
                    obj.curr(i-1) = obj.curr(i-1) + 1;
                    j = 1;
                    while i-1 + j <=  obj.k
                        obj.curr(i-1 + j) = obj.curr(i-1) + j;
                        j = j + 1;
                    end
                    return
                end
            end
            obj.done = true;
            return
        end
    end
end

