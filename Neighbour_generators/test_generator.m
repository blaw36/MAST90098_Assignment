k = 2;
I = [2];
M =  [2,3,1,2];

g = NeighbourhoodGenerator(k, I, M);
while g.done == false
    val = g.next();
    order = val{1};
    programs = val{2};
    disp(order)
    disp(programs)
    disp(" ")
end