
kind = ["heating" , "elec"]; % kind of data
m = 2;
for n = 1:3 
%n = 3;
i = 1;

load_path = '../deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(i) + 'foldv/' + string(i);
all_tr_x_1 = csvread(load_path + 'fold_x_tr');
i = 28;
load_path = '../deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(i) + 'foldv/' + string(i);
all_tr_x_2 = csvread(load_path + 'fold_x_tr');

data_tr_x = [all_tr_x_1 ; all_tr_x_2(25:end , :)];

i = 1;
load_path = '../deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(i) + 'foldv/' + string(i);
all_tr_out_1 = csvread(load_path + 'fold_out_tr');
i = 28;
load_path = '../deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(i) + 'foldv/' + string(i);
all_tr_out_28 = csvread(load_path + 'fold_out_tr');

data_tr_out = [all_tr_out_1 ; all_tr_out_28(25:end , :)];



plot (data_tr_x(:,1));

%% 55 DAYS 
% 14 EXPERIMENTS
% test on the next day (data from the previous dataset (last 14 days)

for k = 0:14
    slide_dataset_x = data_tr_x(24 * k + 1 : 24 * k + 312 , :);
    increasing_dataset_x = data_tr_x(1 : 24 * k + 312 , :);
    
    slide_dataset_out = data_tr_out(24 * k + 1 : 24 * k + 312 , :);
    increasing_dataset_out = data_tr_out(1 : 24 * k + 312 , :);

    load_path = '../deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(k + 14) + 'foldv/' + string(k + 14);
    all_test_x = csvread(load_path + 'fold_x_ts');
    all_test_out = csvread(load_path + 'fold_out_ts');
    
    
    save_path = '../dataset_big/season' + string(n) + '/' + string(kind(m)) + '/' + string(k);
    csvwrite(save_path + '_slide_tr_x' ,slide_dataset_x);
    csvwrite(save_path + '_increasing_tr_x' ,increasing_dataset_x);
    csvwrite(save_path + '_slide_tr_out' ,slide_dataset_out);
    csvwrite(save_path + '_increasing_tr_out' ,increasing_dataset_out);
    csvwrite(save_path + '_test_x' ,all_test_x);
    csvwrite(save_path + '_test_out' ,all_test_out);
    
    
end





end

