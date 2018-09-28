
kind = ["heating" , "elec"]; % kind of data
m = 1;
n = 3;
i = 1;
load_path = 'deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(i) + 'foldv/' + string(i) + 'fold_x_tr';
all_tr_x = csvread(load_path)';