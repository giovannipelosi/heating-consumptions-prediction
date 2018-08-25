%RandStream.setDefaultStream(RandStream('mt19937ar','seed',1)); 
rand('seed',1234); % used for reproducibility

name = "output_";
figure_name = "figure_";

all_tr_x = csvread('1fold_x_tr')';
tr_out = csvread('1fold_out_tr')'; 
test_x = csvread('1fold_x_ts')'; 
test_out = csvread('1fold_out_ts')'; 

small_tr_x = all_tr_x(1:11 ,: );
test_small_x = test_x(1:11 , :);

% small -> 11 features
% big -> all the features

% create net

% SMALL 1

small_1 = feedforwardnet([5 5 5 5 5 5 5]);
[small_1, tr_s_1] = train(small_1, small_tr_x,tr_out);

output_s_1 = [];
for i = 1:size(test_small_x,2)
    output_s_1 = [output_s_1 , small_1(test_small_x(:,i))]; 
end

% SMALL 2

small_2 = feedforwardnet([5 5]);
[small_2, tr_s_2] = train(small_2, small_tr_x,tr_out);

output_s_2 = [];
for i = 1:size(test_small_x,2)
    output_s_2 = [output_s_2 , small_2(test_small_x(:,i))]; 
end

% BIG 1

big_1 = feedforwardnet([5 5 5 5 5 5 5]);
[big_1, tr_b_1] = train(big_1, all_tr_x,tr_out);

output_b_1 = [];
for i = 1:size(test_x,2)
    output_b_1 = [output_b_1 , big_1(test_x(:,i))]; 
end

% BIG 2

big_2 = feedforwardnet([5 5]);
[big_2, tr_b_1] = train(big_2, all_tr_x,tr_out);

output_b_2 = [];
for i = 1:size(test_x,2)
    output_b_2 = [output_b_2 , big_2(test_x(:,i))]; 
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
trained_b_1 = [small_tr_x(1,:) , output_b_1];
trained_b_2 = [small_tr_x(1,:) , output_b_2];

% save result
result_output = [original', trained_s_1', trained_s_2', trained_b_1', trained_b_2'];
result_table = array2table(result_output, 'VariableNames', {'original', 'trained_s_1', 'trained_s_2', 'trained_b_1', 'trained_b_2'});
% create and save the figure


f = figure('visible','off');
title(figure_name);


plot (trained_s_1,'c');
hold on
plot (trained_s_2, 'y');
hold on 
plot (trained_b_1,'r');
hold on
plot (trained_b_2, 'g');
hold on
plot (original,'b');
hold on
legend ('trained_s_1', 'trained_s_2', 'trained_b_1', 'trained_b_2', 'original');
%saveas(f,figure_name,'fig');
saveas(f,[pwd '/prova/myFig.fig']);
hold off

writetable(result_table,[pwd '/prova/myFig.dat']);

%get the directory of your input files:
%pathname = fileparts('/prova');
%use that when you save
%matfile = fullfile(pathname, 'output.mat');
%figfile = fullfile(pathname, 'output.fig');
%save(matfile, );
%saveas(figfile );




