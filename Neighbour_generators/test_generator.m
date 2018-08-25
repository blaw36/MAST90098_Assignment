k = 2;
I = [2];
M =  [2,3,1,2];

% g = NeighbourhoodGenerator(k, I, M);
% while g.done == false
%     val = g.next();
%     order = val{1};
%     programs = val{2};
%     disp(order)
%     disp(programs)
%     disp(" ")
% end

%Performance testing
k_range = [2,2];
k_steps = 1;

m_range = [25,100];
m_steps = 4;

M_max_range = [500,1000];%Max number of programs in a machine
M_max_steps = 2;

total_time = 0;
total_neighbours = 0;
for M_max = M_max_range(1):M_max_range(2)/M_max_steps:M_max_range(2)
    for m = m_range(1):m_range(2)/m_steps:m_range(2)
        M = randi(M_max,1,m);
        [max_,I] = max(M);
        for k = k_range(1):k_range(2)/k_steps:min(m, k_range(2))
            startTime = tic;
            neighbourhood_size = 0;
            g = NeighbourhoodGenerator(k, I, M);
            while g.done == false
                g.next();
                neighbourhood_size = neighbourhood_size +1;
            end
            t = toc(startTime);
            n = sum(M);
            mem_int = 8; % if just use int8, in bits bits
            mem_per_neigh = 2*k*mem_int;
            required_memory_bytes = neighbourhood_size*mem_per_neigh/8;
            fprintf("For M_max = %d, n = %d, m = %d, k = %d, len(I)=%d:",...
                    [M_max, n, m, k, length(I)])
            fprintf(" |Neigh| = %.2e, req_non_it_mem =%.2e  time=%f\n", ...
               [neighbourhood_size,required_memory_bytes, t])
                
            total_time = total_time + t;
            total_neighbours = total_neighbours + neighbourhood_size;
        end
    end
end
fprintf("Average Neighbours per unit time(s?) = %f\n",...
                                            total_neighbours/total_time)