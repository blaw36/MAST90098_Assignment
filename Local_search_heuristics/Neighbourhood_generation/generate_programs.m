%% generate_programs.m
% Constructs all ways to move programs between the specified machines
%% Input:
    % order: Encodes the cycle/path that the movement takes place on.
    % M: The number of (movable) programs in each machine
    % k: The number of machines involved
    % cycle: Whether the order is encoding a cycle (true) or not (false)
%% Output:
    % programs: A matrix storing the indices of the programs to be moved
    % programs_end: The number of rows of the programs matrix, indicating
        % the number of possible program combinations to be moved between
        % the machines
%%

function [programs, programs_end] = generate_programs(order, M, k, cycle)
    progs_per_machine = M(order);

    if cycle == false
        % Don't move anything from last machine
        progs_per_machine = progs_per_machine(1:k-1);
    end

    programs_end = prod(progs_per_machine);

    if k == 2
        if cycle == false
            % just count through programs of one machine
            programs = (1:programs_end)';
        else
            %Outer initiated first to fix size
            %11...122....23....(m2-1)m2...m2
            programs(:,2) = repelem(1:progs_per_machine(2),progs_per_machine(1));
            %12...m112...m1...12...m1
            programs(:,1) = repmat(1:progs_per_machine(1),1,progs_per_machine(2));
            %Old method- slower
%             [col1, col2] = meshgrid(1:progs_per_machine(1),...
%                                 1:progs_per_machine(2));
%             programs = [col1(:), col2(:)];
        end
        return
    end
    
    
    %In effect this constructs [m1]x[m2]x...x[mj]
    %   where   mi = progs_per_machine(i), 
    %           j = length(progs_per_machine)

    % This is still a bottleneck, but not so much anymore.
    % Also now considers all the permutations of programs

    % Idea here is the go 1,...,n_m, followed by
    % 1,1,...,2,2,...,n_{m-1},n_{m-1}
    % etc, cumulatively 'telescoping' outwards in the repetitions
    % from right to left
    cols = length(progs_per_machine);
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
    intermed_programs = zeros(programs_end,cols);
    % Last column has no repeated elements, just repeated sequences
    intermed_programs(:,cols) = (repmat(1:progs_per_machine(cols), ...
        1, programs_end/progs_per_machine(cols)))';

    % The rest have repeated elements, and those sequences are then
    % repeated
    for k = (cols-1):-1:1
        intermed_programs(:,k) = (repmat(repelem(...
            1:progs_per_machine(k),divisors_repelem(k)), 1, divisors_repmat(k)))';
    end

    % Put the first row last (first row = itself as part of n/hood)
    programs = [intermed_programs(2:programs_end,:); ...
        intermed_programs(1,:)];    
end