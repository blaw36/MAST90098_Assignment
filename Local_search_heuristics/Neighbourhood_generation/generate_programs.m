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
            % Outer machine initiated first to fix size.
            % Denote the ith program of the jth machine as j_i, having pj
            % programs.
            
            % Create second machine sequence first:
            % 2_1,...,2_1,2_2,...,2_2,...,2_(p2-1),2_p2,...,2_p2
%             programs(:,2) = repelem(1:progs_per_machine(2),progs_per_machine(1));
            tmp_col2 = repmat(1:progs_per_machine(2),progs_per_machine(1),1);
            programs(:,2) =  tmp_col2(:);
%             programs(:,2) =  reshape(tmp_col2,[],1);
            
            % Then create first machine sequence:
            % 1_1,1_2,...,1_p1,1_1,1_2,...,1_p1, repeated as many times 
            % as req'd to equal the number of rows of 'programs'
            programs(:,1) = repmat(1:progs_per_machine(1),1,progs_per_machine(2));
        end
        return
    end
    
    
    % In effect this constructs [m1]x[m2]x...x[mj]
    %   where   mi = progs_per_machine for machine i, 
    %           j = # of machines chosen for moving

    % Idea here is to compile sequences from the jth to 1st machine:
    % denoting the ith program of the jth machine as j_i, having pj
    % programs:
        % prepare jth machine sequence, j_1,...j_pj, and repeat as many
        % times until 'programs_end'
        % prepare (j-1)th machine sequence,
        % (j-1)_1,(j-1)_1,...,(j-1)_2,(j-1)_2,...,(j-1)_p(j-1),(j-1)_p(j-1)
        % with each program repeated j_pj times to 'align' with the length
        % of a complete sequence from machine j
    % Etc, cumulatively 'telescoping' outwards in the repetitions from
    % right (jth machine) to left (1st machine)
    cols = length(progs_per_machine);
    divisors_repelem = zeros(1,cols);
    
    % Number of repeats (repelem) required for each program, for 
    % each machine except the last (jth) one (where only whole sequences,
    % not individual programs, are repeated)
    divisors_repelem(:,cols) = 1;
    for k = (cols-1):-1:1
        divisors_repelem(:,k) = divisors_repelem(:,k+1).*progs_per_machine(k+1);
    end

    % Number of times the sequence of repeated programs, for each
    % machine, gets repeated.
    divisors_repmat = zeros(1,cols);
    % The first program only has one repeat (its sequence is one long
    % sequence of repeated 1s, then 2s, ..., then repeated 1_p1's)
    divisors_repmat(:,1) = 1;
    for k = 2:cols
        divisors_repmat(:,k) = divisors_repmat(:,(k-1)).*progs_per_machine(k-1);
    end

    % Put it all together
    intermed_programs = zeros(programs_end,cols);
    % Last column has no repeated elements, just repeated sequences
    intermed_programs(:,cols) = (repmat(1:progs_per_machine(cols), ...
        1, programs_end/progs_per_machine(cols)))';

    % The rest have 'divisors_repmat' # of repeated elements in their 
    % sequences, and those sequences are then repeated 'divisors_repelem'
    % times
    for k = (cols-1):-1:1
        tmp_intermed = repmat(1:progs_per_machine(k), divisors_repelem(k), ...
            divisors_repmat(k));
        intermed_programs(:,k) = tmp_intermed(:);
%         intermed_programs(:,k) = reshape(tmp_intermed, [], 1);
%         intermed_programs(:,k) = (repmat(repelem(...
%             1:progs_per_machine(k),divisors_repelem(k)), 1, divisors_repmat(k)))';
    end

    % Put the first row last (first row = itself as part of n/hood)
    programs = [intermed_programs(2:programs_end,:); ...
        intermed_programs(1,:)];    
end