
% Current Method
start = tic;
for a = 1:5000
test1 = mod(...
                            repmat((1:rows)', 1, cols), ...
                            progs_per_machine)+1;
end
m1_time = toc(start);
fprintf("m1: %f", m1_time)


% Improvement on current method
start = tic;
for a = 1:5000
divisors = rows./progs_per_machine;
test2_intermed = zeros(rows,cols);
    for j = 1:cols
        test2_intermed(:,j) = (repmat(1:progs_per_machine(j),1,divisors(j)))';
    end
    test2 = [test2_intermed(2:rows,:); test2_intermed(1,:)];
end
m2_time = toc(start);
fprintf("m2: %f", m2_time)


% Correct(?) method
start = tic;
for a = 1:5000
divisors2 = zeros(1,cols);
for k = 1:cols
    divisors2(:,k) = rows/prod(progs_per_machine(1:k));
end
divisors3 = zeros(1,cols);
for k = cols:-1:1
    divisors3(:,k) = rows/prod(progs_per_machine(k:cols));
end
test3_intermed = zeros(rows,cols);
test3_intermed(:,cols) = (repmat(1:progs_per_machine(cols), 1, rows/progs_per_machine(cols)))';
for l = (cols-1):-1:1
    test3_intermed(:,l) = (repmat(repelem(1:progs_per_machine(l),divisors2(l)), 1, divisors3(l)))';
end
test3 = [test3_intermed(2:rows,:); test3_intermed(1,:)];
end
m3_time = toc(start);

fprintf("m3: %f", m3_time)
