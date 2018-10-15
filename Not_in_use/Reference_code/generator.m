classdef generator < handle
    %From,
    %https://stackoverflow.com/questions/21099040/what-is-the-matlab-equivalent-of-the-yield-keyword-in-python#
    %Also includes an example of use
    

    properties (Access = private)
        k
        I
        M
        curr
        done
    end

    methods
        function obj = generator(k, I, M)
            obj.k = k;
            obj.I = I;
            obj.M = M;
            obj.curr = first(k, I, M);
            obj.done = false;
        end

        function val = next(obj)
            if obj.done == true;
                val = %generate next somehow f(curr, k, I, M)
                obj.curr = val;
            else
                error('Iterator:StopIteration', 'Stop iteration')
            end
        end
    end
end