classdef Generator < handle
    %An abstract class for iterative generators.
    %While the generator is not done, you can call next to retrieve the
    %next value.
    %Inspired by,
    %https://stackoverflow.com/questions/21099040/what-is-the-matlab-equivalent-of-the-yield-keyword-in-python#
    
    properties
        curr;
        done = false; %Indicates whether the next value is available
    end

    methods (Abstract)
        val = next(obj) %Returns current val, positions to access next
    end
end