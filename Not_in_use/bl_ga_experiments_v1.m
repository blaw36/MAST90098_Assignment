%% Crossing over using matrices. Not faster

start = tic;
for j = 1:1000000
    child_array = ...
            [parent_genes(2,1:cross_point), ...
            parent_genes(1,(cross_point + 1):num_jobs)];
end
finish = toc(start);

start2 = tic;
for j = 1:1000000
    cross_mat_2 = zeros(1,100);
    cross_mat_1 = 1-cross_mat_2;
    cross_mat_2(1:cross_point) = 1;
    child_array = (parent_genes(2,:) .* cross_mat_2 + ...
        parent_genes(1,:) .* cross_mat_1);
end
finish2 = toc(start2);


%% New way of storing population.
% Twice as fast!!! Matrix in struct (1s/0s), rather than matrix of integers

start1= tic;
% test = pop_mat(1:3000,:);
for i = 1:size(pop_mat,1)
    pop(i).mach_mat = zeros(num_machines, size(jobs_array_aug,2));
    for j = 1:size(jobs_array_aug,2)
        pop(i).mach_mat(pop_mat(i,j),j) = 1;
    end
end
stop1 = toc(start1);


start = tic;
for j = 1:1000%000
     for k = 1:num_machines
         indicator_mat = (pop_mat == k);
         machine_cost_mat(:,k) = indicator_mat * jobs_array_transpose;
     end
end
stop = toc(start);

start2 = tic;
for j = 1:1000%000
     for k = 1:size(pop,2)
         machine_cost_mat(k,:) = pop(k).mach_mat*jobs_array_transpose;
     end
end
stop2 = toc(start2);

%% New way of generating parents
% This is an improvement on the current implementation of the current
% method. STill takes a while - so maybe we go for an even simpler parent
% generation/matching scheme (eg: 75% chance we choose member at random
% from top 25% of pop, 25% chance we choose member at random from bottom
% 75% of pop)

prob_parent_select;
cumul_prob_parent = cumsum(prob_parent_select);

num_parent_pairings = floor(...
        (init_pop_size * 5)/2)*2;
parent_ids = zeros(num_parent_pairings,1);

start = tic;
for j = 1:10%00
    for i = 1:num_parent_pairings
        random = rand(1);
        parent_ids(i) = min(find(random <= cumul_prob_parent));
    end
end
stop = toc(start);

start2 = tic;
for j = 1:10%00
    parent_ids = randsample([1:3000], num_parent_pairings, true, ...
        prob_parent_select);
end
stop2 = toc(start2);