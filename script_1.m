% FISRT script -> see files ending by "output.dat" and "figure.fig"

%RandStream.setDefaultStream(RandStream('mt19937ar','seed',1)); 
rand('seed',1234); % used for reproducibility

kind = ["heating" , "elec"];

for m = 1:2
for n = 1:3
for i = 1:28
%i = 1;

name = string(i) + "_output_2" ;
figure_name =  string(i) + "_figure_2" ;
save_path = 'Results/season' + string(n) + '/' + kind(m) +  '/';
load_path = 'deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(i) + 'foldv/' + string(i);

all_tr_x = csvread(load_path + 'fold_x_tr')';
tr_out = csvread(load_path + 'fold_out_tr')'; 
test_x = csvread(load_path + 'fold_x_ts')'; 
test_out = csvread(load_path + 'fold_out_ts')'; 

small_tr_x = all_tr_x(1:11 ,: );
test_small_x = test_x(1:11 , :);

% small -> 11 features
% big -> all the features

% create net

% SMALL 1

small_1 = feedforwardnet([5 5 5 5 5 5 5]);
[small_1, tr_s_1] = train(small_1, small_tr_x,tr_out);

output_s_1 = [];
for j = 1:size(test_small_x,2)
    output_s_1 = [output_s_1 , small_1(test_small_x(:,j))]; 
end

% SMALL 2

small_2 = feedforwardnet([5 5]);
[small_2, tr_s_2] = train(small_2, small_tr_x,tr_out);

output_s_2 = [];
for j = 1:size(test_small_x,2)
    output_s_2 = [output_s_2 , small_2(test_small_x(:,j))]; 
end

% SMALL 3

small_3 = feedforwardnet([11 8 8]);
[small_3, tr_s_3] = train(small_3, small_tr_x,tr_out);

output_s_3 = [];
for j = 1:size(test_small_x,2)
    output_s_3 = [output_s_3 , small_3(test_small_x(:,j))]; 
end

% BIG 1

big_1 = feedforwardnet([5 5 5 5 5 5 5]);
[big_1, tr_b_1] = train(big_1, all_tr_x,tr_out);

output_b_1 = [];
for j = 1:size(test_x,2)
    output_b_1 = [output_b_1 , big_1(test_x(:,j))]; 
end

% BIG 2

big_2 = feedforwardnet([5 5]);
[big_2, tr_b_2] = train(big_2, all_tr_x,tr_out);

output_b_2 = [];
for j = 1:size(test_x,2)
    output_b_2 = [output_b_2 , big_2(test_x(:,j))]; 
end

% BIG 3

big_3 = feedforwardnet([26 15 15]);
[big_3, tr_b_3] = train(big_3, all_tr_x,tr_out);

output_b_3 = [];
for j = 1:size(test_x,2)
    output_b_3 = [output_b_3 , big_3(test_x(:,j))]; 
end

% training paramenters parameters -> avoid early stop (might overfit)
%{
net_big = feedforwardnet([5 5]);
net_big.divideParam.trainRatio = 1;
net_big.divideParam.valRatio = 0;
net_big.divideParam.testRatio = 0;
net_big.trainParam.goal = 0;
net_big.trainParam.min_grad = 1e-100;
[net_big, tr_b] = train(net_big, all_tr_x,tr_out);
%}
%{
miniBatchSize = 1;
options = trainingOptions( 'sgdm','InitialLearnRate',0.00001,'MiniBatchSize', miniBatchSize,'Plots', 'training-progress');
layers = [ 
            sequenceInputLayer(11)
            fullyConnectedLayer(2)
            fullyConnectedLayer(5)
            fullyConnectedLayer(6)
            fullyConnectedLayer(1)
            regressionLayer()
         ];
net = trainNetwork(small_tr_x, tr_out, layers, options);
%}


%YPred = predict(net,test_small_x,'MiniBatchSize',1);


original = [small_tr_x(1,:) , test_out];
trained_s_1 = [small_tr_x(1,:) , output_s_1];
trained_s_2 = [small_tr_x(1,:) , output_s_2];
trained_s_3 = [small_tr_x(1,:) , output_s_3];
trained_b_1 = [small_tr_x(1,:) , output_b_1];
trained_b_2 = [small_tr_x(1,:) , output_b_2];
trained_b_3 = [small_tr_x(1,:) , output_b_3];

% save result
result_output = [original', trained_s_1', trained_s_2', trained_s_3', trained_b_1', trained_b_2', trained_b_3'];
result_table = array2table(result_output, 'VariableNames', {'original', 'trained_s_1', 'trained_s_2','trained_s_3', 'trained_b_1', 'trained_b_2', 'trained_b_3'});
% create and save the figure


%f = figure('visible','off');
f = figure;
title(figure_name);


plot (trained_s_1,'c');
hold on
plot (trained_s_2, 'y');
hold on 
plot (trained_s_3, 'm');
hold on 
plot (trained_b_1,'r');
hold on
plot (trained_b_2, 'g');
hold on
plot (trained_b_3, 'k');
hold on
plot (original,'b');
hold on
legend ('trained_s_1', 'trained_s_2',  'trained_s_3','trained_b_1', 'trained_b_2','trained_b_3', 'original');
%saveas(f,figure_name,'fig');
%temp = save_path + figure_name + '.fig';
temp = save_path + figure_name;
saveas(f,temp , 'fig');
hold off
close(f);

result_path  = fullfile( save_path, name + '.dat' );
writetable(result_table, result_path);
%writetable(result_table,[pwd string(save_path + name + '.dat')]);

%get the directory of your input files:
%pathname = fileparts('/prova');
%use that when you save
%matfile = fullfile(pathname, 'output.mat');
%figfile = fullfile(pathname, 'output.fig');
%save(matfile, );
%saveas(figfile );




end
end
end