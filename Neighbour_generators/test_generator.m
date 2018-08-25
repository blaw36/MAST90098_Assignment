k = 2;
L = [2];
M =  [2,3,1,2];

g = NeighbourhoodGenerator2(k, L, M);

% while g.done == false
%     val = g.next();
%     g;
%     order = val{1};
%     programs = val{2};
%     disp(order)
%     disp(programs)
%     disp(" ")
% end

%Performance testing
k_range = [2,3];

m_range = [5,25];
m_steps = 5;

M_max_range = [10,40];%Max number of programs in a machine
M_max_steps = 4;

for M_max = M_max_range(1):M_max_range(2)/M_max_steps:M_max_range(2)
    for m = m_range(1):m_range(2)/m_steps:m_range(2)
        M = randi(M_max,1,m);
        [max_,L] = max(M);
        for k = k_range(1):min(m, k_range(2))
            disp("NeighbourhoodGenerator")
            startTime = tic;
            neighbourhood_size = 0;
            g = NeighbourhoodGenerator(k, L, M);
            while g.done == false
                g.next();
                neighbourhood_size = neighbourhood_size +1;
            end
            t = toc(startTime);
            n = sum(M);
            fprintf("For M_max = %d, n = %d, m = %d, k = %d, len(L)=%d:",...
                    [M_max, n, m, k, length(L)])
            fprintf(" |Neigh| = %d, time=%f\n", ...
               [neighbourhood_size, t])
                
            disp("NeighbourhoodGenerator2")
            startTime = tic;
            neighbourhood_size = 0;
            g = NeighbourhoodGenerator2(k, L, M);
            while g.done == false
                g.next();
                neighbourhood_size = neighbourhood_size +1;
            end
            t = toc(startTime);
            n = sum(M);
            fprintf("For M_max = %d, n = %d, m = %d, k = %d, len(L)=%d:",...
                    [M_max, n, m, k, length(L)])
            fprintf(" |Neigh| = %d, time=%f\n", ...
               [neighbourhood_size, t])
           
            %Assuming one byte per int (an underestimate with current code)
            mem_per_neigh = 2*k;
            naive_memory_req_bytes = neighbourhood_size*mem_per_neigh;
            fprintf("Mem required for naive cartesian product est: %.2e bytes\n",...
                naive_memory_req_bytes)
            
            table_programs_size_bytes = k*M_max;
            other_mem_est_bytes = k*nchoosek(m,k);
            fprintf("Mem required Generator2 method est: %.2e bytes\n\n",...
                table_programs_size_bytes+other_mem_est_bytes)
        end
    end
end