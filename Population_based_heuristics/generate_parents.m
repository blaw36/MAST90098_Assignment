%% generate_parents.m

% according to the cumulative probability arrays, pick a desired number of
% parent pairings

% m x 2 array of parent pairings
% Round num_parents up to closest even num
% # parents proportional to pop'n size (1 = same as pop'n size, will
% produce half as many children)
function parent_mat = generate_parents(prob_parent_select, ...
    proportion_of_parents, init_pop_size)

    % Ensure number is even
    num_parent_pairings = floor(...
        (init_pop_size * proportion_of_parents)/2)*2;

    possible_parents = [1:init_pop_size];
    parent_ids = randsample(possible_parents, num_parent_pairings, ...
        true, prob_parent_select);
%     for i = 1:num_parent_pairings
%         random = rand(1);
%         parent_ids(i) = min(find(random <= cumul_prob_parent));
%     end
    
    % Reshape into (num_parent_pairings/2) x 2 matrix
    parent_mat = reshape(parent_ids,[],2);

end
