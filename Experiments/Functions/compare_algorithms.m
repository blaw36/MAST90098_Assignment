%% compare_algorithms.m
% Compares (multiple) algorithm(s) across a range of instances
%% Input:
    % algs: function handles for algs to be tested,
        % the handle must be of the form 
        % alg = @(input_array, args) f(input_array, args{:}
    % algs_args: the other args to be passed excluding input array
    % gen_method: a handle used to initialise the input array each trial
        % the handle must be of the form
        % gen_method = @(num_programs, num_machines) ...
        %                           gen_method(num_programs, num_machines);
    % programs_range: a vector of num_programs to vary across
    % machines_denom_iterator: controls how quickly the number of machines
        % are scaled towards the number of programs
    % num_trials: the number of trials to be done on the alg.
    % machines_proportion: an optional argument, that indicates whether a
        % constant fraction of num_programs should be used. This overwrites
        % anythin specified in machines_denom_iterator.    
%% Output:
    % results: stores the average [time, ratio_to_init, ratio_to_lb]
        % across the algs, and gen_args\
        % has dims |algs|x|programs_range|x(machines_denom_iterator)x3
%%

function results = compare_algorithms(algs, algs_args, gen_method, ...
                            programs_range, machines_denom_iterator, ...
                            num_trials, machines_proportion)
                        
if ~exist('machines_proportion','var')               
    machines_proportion=false;
end

if machines_proportion > 0
    %Override iterator, so just do 1 iteration.
    machines_denom_iterator = 1;
end

%Check Input
if machines_proportion<=0
    if any(mod(programs_range, machines_denom_iterator))
        error("Make sure the programs range is divisible by the denominator");
    end
end

results = zeros(length(algs), length(programs_range), ...
                machines_denom_iterator, 3);

%For each set number of programs
for j = 1: length(programs_range)
    num_programs = programs_range(j);
    fprintf("Number of Programs: %d\n", num_programs);
    machine_iterator = floor(num_programs/machines_denom_iterator);
    k = 0;
    %scale the number of machines to the number of programs
    for iterated_machines = machine_iterator:machine_iterator:num_programs
        k = k + 1;
        %Test each alg on this number of programs and machines
        for i=1:length(algs)
            fprintf("Algorithm: %d, ", i);
            alg = algs{i};
            alg_args = algs_args{i};
            
            if machines_proportion
                num_machines = floor(num_programs*machines_proportion);
            else
                num_machines = iterated_machines;
            end
            
            %Setting the seed as a funtion of num_machines, num_programs
            %means that the algorithms will be compared on the same test
            %case even if the gen_method has random elements.
            
            %mod(num_machines*num_programs,2^32) is a passable hash function
            % rng takes as an input an integer <2^32
            % If it was a perfect hash (which it isn't) then every
            % generation for a different number of machines and
            % programs would have a different seed.
            
            % In the worst case a match occurs for generation cases with
            % different numbers of programs and machines. Then if a random
            % generation method is used, the first portion of programs
            % generated in these two cases will be the same. (The larger
            % test case will still have a different 'tail' and given the
            % nature of having both different numbers of machines,
            % programs, and a different tail, is likely to be a very
            % 'different' instance.)
            rng(mod(num_machines*num_programs,2^32));
            results(i,j,k,:) = test_algorithm(alg, alg_args, gen_method, ...
                num_programs, num_machines, num_trials);
            fprintf("Time: %f\n", results(i,j,k,1));
        end
    end
end