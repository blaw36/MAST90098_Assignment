%% generate_ms_instances.m
% Generates a random makespan problem instance for the given parameters
%% Input:
    % n: the number of jobs that need to be assigned (must be integer >= 2)
    % m: the number of machines to assign the jobs to (must be integer > 0)
    % hard: a flag indicating whether to use the hard test case generator
        % from the paper 
        % "Multi-exhange algorithms for the minimum makespan machine"
        % described in detail at the start of section 4.1
%% Output:
    % inputArray: an array, (p_1,...,p_n,m)
        % Where p_i represent the integer amount of time required
        % to do job i = {1,...,n}, and the number of machines, m
%%

function inputArray=generate_ms_instances(n, m, hard)
    
    if ~exist('hard','var')
        hard=false;
    end

    if (n < 2)     % n >= 2
        error('n must be greater than or equal to 2')
    end
    
    if (floor(n) ~= n) % n must be an integer
        error('n must be an integer')
    end
    
    if (m <= 0)     % m > 0
        error('m must be greater than 0')
    end
    
    if (floor(m) ~= m) % m must be an integer
        error('m must be an integer')
    end
    
    % Pre-allocate for speed
    inputArray = zeros(1,n+1);
    a = 0;
    b = n*10;
    
    for i = 1:n
        if ~hard
            %Disrete Uniform on [a, b]
            inputArray(i) = randi([a,b]);
        else
            %0.98 of jobs are on the far right of the interval the 
            %remainder on the far left
            if i/n < 0.98
                inputArray(i) = randi([(b-a)*0.9, b]);
            else
                inputArray(i) = randi([a, (b-a)*0.02]);
            end
        end
    end
    inputArray(n+1) = m;
end