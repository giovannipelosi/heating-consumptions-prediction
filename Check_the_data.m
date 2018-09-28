%% check the data
% slide_horizon and incremental
rand('seed',1234); % used for reproducibility

kind = ["heating" , "elec"]; % kind of data

%for m = 1:2
%for n = 1:3
%for i = 0:14

m = 1; % 1:2
n = 3; % 1:3
i = 2; % 0:14

% LOAD DATA big
name = string(i) + "_output_big_2"; % INCREASE COUNTER
figure_name = string(i) + "_figure_big_2"; % INCREASE COUNTER
save_path = 'Results_big/season' + string(n) + '/' + kind(m) +  '/';
load_path = 'dataset_big/season' + string(n) + '/' + string(kind(m)) + '/' + string(i);


slide_all_tr_x = csvread(load_path + '_slide_tr_x')';
slide_tr_out = csvread(load_path + '_slide_tr_out')';

incre_all_tr_x = csvread(load_path + '_increasing_tr_x')';
incre_tr_out = csvread(load_path + '_increasing_tr_out')';

test_all_x = csvread(load_path + '_test_x')';
test_out = csvread(load_path + '_test_out')';

slide_small_tr_x = slide_all_tr_x(1:11,:);
incre_small_tr_x = incre_all_tr_x(1:11,:);
test_small_x = test_all_x(1:11,:);


%% plots big 
total_size  = size (incre_tr_out , 2) + size (test_out, 2);
all_out = [incre_tr_out , test_out];

for i = 1:1 %size(incre_all_tr_x, 1)
    f = figure;
    plot (all_out);
    hold on
    plot (incre_tr_out);
    hold on 
    plot ([incre_all_tr_x(i,:) , test_all_x(i,:)]);
    hold on
    plot (incre_all_tr_x(i,:));
    hold off;
    legend ('all_out','interm_out','all_in','interm_in');

end

%%
% LOAD DATA small
%name = string(i) + "_output_" + string(str2num(output_number) + opt - 1  ) ; % INCREASE COUNTER
%figure_name =  string(i) + "_figure_" + string(str2num(output_number) + opt - 1  ) ; % INCREASE COUNTER
save_path = 'Results/season' + string(n) + '/' + kind(m) +  '/';
load_path = 'deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(i) + 'foldv/' + string(i);


all_tr_x = csvread(load_path + 'fold_x_tr')';
tr_out = csvread(load_path + 'fold_out_tr')';
test_x = csvread(load_path + 'fold_x_ts')';
test_out = csvread(load_path + 'fold_out_ts')';

small_tr_x = all_tr_x(1:11 ,: ); % consider only the first 11 features
test_small_x = test_x(1:11 , :); % smaller version of the dataset

%% plots small 
all_out = [tr_out , test_out];

for i = 1:1 %size(all_tr_x, 1)
    f = figure;
    plot (all_out);
    hold on
    plot (tr_out);
    hold on 
    plot ([all_tr_x(i,:) , test_x(i,:)]);
    hold on
    plot (all_tr_x(i,:));
    hold off;
    legend ('all_out','interm_out','all_in','interm_in');

end