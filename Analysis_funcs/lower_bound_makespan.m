function lower_bound = lower_bound_makespan(a)
    %Provides a lower bound for the makespan instance
    num_progs = length(a) - 1;
    num_machines = a(length(a));
    max_prog = max(a(1:num_progs));
    
    divided_cost = sum(a(1:num_progs))/num_machines;
    
    lower_bound = max([max_prog, divided_cost]);
end

