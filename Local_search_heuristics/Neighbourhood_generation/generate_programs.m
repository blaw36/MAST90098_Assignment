function [programs, programs_end] = generate_programs(order, M, k, cycle)
    %Using the current order of machines constructs all ways to
        %move programs between these machines.
%     v = valid_order
%     o = order
%     cycle = cycle
    progs_per_machine = M(order);

    if cycle == false
        %Don't move anything from last machine
        progs_per_machine = progs_per_machine(1:k-1);
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
    programs = [intermed_programs(2:rows,:); ...
        intermed_programs(1,:)];

    programs_end = rows;        
end