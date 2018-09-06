tic
a = [1 2 3 4 5 6 7 8];
b = [4 5 2 5 6 3 5 3];
c = [3 9 4 8 3 2 3 4];

d = {a b c};
my_legend = cell(1,3);
for i = 1:3
        my_legend{i} = string('graph_' + string(i));
end

f = figure;

for i = 1:3
    plot(d{i});
    hold on
end
legend (my_legend);
hold off

toc