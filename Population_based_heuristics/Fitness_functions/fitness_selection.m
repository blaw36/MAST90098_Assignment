%fitness_selection.m Computes the fitness of each member of the population
%as a function of their makespans using the selected method.


function probability = fitness_selection(makespan_mat, invert, method)
    if method == "minMaxLinear"
        probability = fitness_minmaxLinear(makespan_mat, invert);
    elseif method == "neg_exp"
        probability = fitness_negexp(makespan_mat, invert);
    else
        error("Invalid Fitness Selection Method");
    end
end
        