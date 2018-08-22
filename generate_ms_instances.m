% Author: Brendan Law
% Date: 13th August 2018

% Here is a rough function to generate instances of
% the Makespan problem with:
% n = n jobs that need to be assigned (must be integer >= 2)
% m = m machines to assign the jobs to (must be integer > 0)

% Output: an array, (p1,...,pn,m)
% Where p_i represent the integer amount of time required
% to do job i = {1,...,n}, and the number of machines, m

% Should we have parameters around the size and variability
% of our randomly generated p_i's?

function inputArray=generate_ms_instances(n,m)
    
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
    
    for i = 1:n
        inputArray(i) = randi(n*10);
    end

    inputArray(n+1) = m;

end
