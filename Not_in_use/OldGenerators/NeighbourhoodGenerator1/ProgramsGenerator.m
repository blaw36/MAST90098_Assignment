classdef ProgramsGenerator < Generator
    %This class iteratively generates all of the ways to pick one program
    %in each machine.
    
    properties
        num_machines
        M %M(i) = the number of programs in machine i
    end
    methods
        
    function obj = ProgramsGenerator(M)
        obj.num_machines = length(M);
        obj.M = M;
        
        %Initially Picks first program in each machine.
        obj.curr = ones(1, obj.num_machines);
    end
    
    function val = next(obj)
        %val = [p1, p2, ..., pk] where pi is the program selected in the
        %ith machine
        val = obj.curr;

        %Treat curr as a number with that has 'variable bases per 
        %digit.' In particular digit i, has base Mi+1 .
        for i = obj.num_machines:-1:1
            if obj.curr(i) < obj.M(i)
                obj.curr(i) = obj.curr(i)+1;
                return
            else
                obj.curr(i) = 1;
            end
        end
        obj.done = true;
        return
    end
    end
end