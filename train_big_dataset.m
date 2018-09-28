%% NEW train_sets -> bigger
% slide_horizon and incremental
rand('seed',1234); % used for reproducibility

kind = ["heating" , "elec"]; % kind of data

%for m = 1:2
%for n = 1:3
%for i = 0:14

m = 1; % 1:2
n = 3; % 1:3
i = 3; % 0:14

% LOAD DATA
name = string(i) + "_output_big_3"; % INCREASE COUNTER
figure_name = string(i) + "_figure_big_3"; % INCREASE COUNTER
save_path = 'Results_big/season' + string(n) + '/' + kind(m) +  '/';
load_path = 'dataset_big/season' + string(n) + '/' + string(kind(m)) + '/' + string(i);


slide_all_tr_x = csvread(load_path + '_slide_tr_x')';
slide_tr_out = csvread(load_path + '_slide_tr_out')';

incre_all_tr_x = csvread(load_path + '_increasing_tr_x')';
incre_tr_out = csvread(load_path + '_increasing_tr_out')';

test_all_x = csvread(load_path + '_test_x')';
test_out = csvread(load_path + '_test_out')';

slide_small_tr_x = slide_all_tr_x(1:4,:); %11
incre_small_tr_x = incre_all_tr_x(1:4,:); %11
test_small_x = test_all_x(1:4,:); %11


%% create networks

nets = {};

% options
    options_1 = trainingOptions('sgdm', ...
        'MaxEpochs',420, ...
        'GradientThreshold',1, ...
        'InitialLearnRate',0.005, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',185, ...
        'LearnRateDropFactor',0.2, ...
        'MiniBatchSize', 40,...
        'Verbose',0 );
    
    options_2 = trainingOptions('adam', ...
        'MaxEpochs',420, ...
        'GradientThreshold',0.99, ...
        'InitialLearnRate',0.25, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',180, ...
        'LearnRateDropFactor',0.2, ...
        'MiniBatchSize', 40,...
        'SquaredGradientDecayFactor',0.99,...
        'L2Regularization',0.0001,...
        'Verbose',0 );
    
    maxEpochs = 100;
    miniBatchSize = 20;
    options_3 = trainingOptions('sgdm', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0);

    % layers
    
        layers_2 = [...
        sequenceInputLayer(4) % 26 % 11
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];
    
        layers_3 = [...
        sequenceInputLayer(4) % 26 % 11
        fullyConnectedLayer(5)
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];

        layers_4 = [...
        sequenceInputLayer(4) % 26 % 11
        fullyConnectedLayer(15)
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];
         
        layers_5 = [...
        sequenceInputLayer(4) % 26 % 11
        fullyConnectedLayer(15)
        fullyConnectedLayer(15)
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];
    
        layers_6 = [...
        sequenceInputLayer(4) % 26 % 11
        fullyConnectedLayer(15)
        fullyConnectedLayer(5)
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];
    
        layers_7 = [...
        sequenceInputLayer(4) % 26 % 11
        fullyConnectedLayer(100)
        fullyConnectedLayer(1)
        regressionLayer()];
         
    
        layers_i_1 = [ ...
        sequenceInputLayer(4) % 26 % 11
        lstmLayer(100,'OutputMode','sequence')
        fullyConnectedLayer(1)
        regressionLayer];
    
        layers_i_2 = [ ...
        sequenceInputLayer(4) % 26 % 11
        lstmLayer(11,'OutputMode','sequence')
        lstmLayer(11,'OutputMode','sequence')
        fullyConnectedLayer(1)
        regressionLayer];
           
    
if m == 1 % heating nets
    
    %%% SLIDING HORIZON
    % 1)
     nets{end + 1} = trainNetwork(slide_small_tr_x, slide_tr_out, layers_3 , options_1);
    
    % 2)
     nets{end + 1} = trainNetwork(slide_small_tr_x, slide_tr_out, layers_4 , options_1);

     % 3)
     nets{end + 1} = trainNetwork(slide_small_tr_x, slide_tr_out, layers_6 , options_2);

     % 4)
     nets{end + 1} = trainNetwork(slide_small_tr_x, slide_tr_out, layers_5 , options_2);

     
     % 5)
     nets{end + 1} = trainNetwork(slide_small_tr_x, slide_tr_out, layers_4 , options_2);
    
     %%% INCREMENTAL
     
     % 6) small 
     nets{end + 1} = trainNetwork(incre_small_tr_x, incre_tr_out, layers_i_1 , options_1);
 
     % 7) small
     nets{end + 1} = trainNetwork(incre_small_tr_x, incre_tr_out, layers_i_2 , options_1);
 
     % 8) all 
     nets{end + 1} = trainNetwork(incre_small_tr_x, incre_tr_out, layers_3 , options_1);

    
end

if m == 2 % elec nets
    
    %%% SLIDING HORIZON
    
     % 1)
     nets{end + 1} = trainNetwork(slide_all_tr_x, slide_tr_out, layers_5 , options_2);
     
     % 2)
     nets{end + 1} = trainNetwork(slide_all_tr_x, slide_tr_out, layers_7 , options_1);

     % 3)
     nets{end + 1} = trainNetwork(slide_all_tr_x, slide_tr_out, layers_2 , options_1);
     
     % 4)
     nets{end + 1} = trainNetwork(slide_all_tr_x, slide_tr_out, layers_4 , options_1);    
     
     % 5)
     nets{end + 1} = trainNetwork(slide_all_tr_x, slide_tr_out, layers_6 , options_1);

     %%% INCREMENTAL
     % 6) small 
     nets{end + 1} = trainNetwork(incre_small_tr_x, incre_tr_out, layers_i_1 , options_1);
 
     % 7) small
     nets{end + 1} = trainNetwork(incre_small_tr_x, incre_tr_out, layers_i_2 , options_1);
 
     % 8) all 
     nets{end + 1} = trainNetwork(incre_all_tr_x, incre_tr_out, layers_5 , options_2);

end

%% predictions
num_of_nets = size(nets,2);
predictions = cell (1, num_of_nets + 1);

for k = 1:5
    predictions{k} = predict(nets{k}, test_small_x);
end

for k = 6:7
    predictions{k} = predict(nets{k}, test_small_x);
end

for k = 8:8
    predictions{k} = predict(nets{k}, test_small_x);
end


%% prediction 2
%{
net = feedforwardnet(10);
[net,tr] = train(net,incre_all_tr_x,incre_tr_out);
predictions{1} = net(test_all_x);

net = feedforwardnet([60 60]);
[net,tr] = train(net,incre_all_tr_x,incre_tr_out);
predictions{2} = net(test_all_x);

net = feedforwardnet([5 5 5 5 5 5 5 5 5 5 5 5 5]);
[net,tr] = train(net,incre_all_tr_x,incre_tr_out);
predictions{3} = net(test_all_x);

net = feedforwardnet(200);
[net,tr] = train(net,incre_all_tr_x,incre_tr_out);
predictions{4} = net(test_all_x);

    net = feedforwardnet([50 50 50 50 50]);
[net,tr] = train(net,incre_all_tr_x,incre_tr_out);
predictions{5} = net(test_all_x);

net = feedforwardnet([10 10 10 10 10 10]);
[net,tr] = train(net,incre_all_tr_x,incre_tr_out);
predictions{6} = net(test_all_x);
%}

%% plot and save
num_of_nets = 6;
plot_legend = {};
f_1 = figure;
title (figure_name)
% plot predicitons
for k = 1:num_of_nets
    plot(predictions{k});
    plot_legend{k} = string(k);
    hold on
end
% plot orignal data
plot(test_out, 'LineWidth', 2)
hold on
plot_legend{end + 1} = 'original';
legend (plot_legend);
temp = save_path + figure_name;
saveas(f_1,temp , 'fig');
hold off
%close(f_1);

predictions{end + 1} = test_out;
for k = 1:size(predictions,2)
    predictions{k} = double(predictions{k}');
end
predictions = cell2mat(predictions);
table_pred = array2table(predictions, 'VariableNames', {'s1','s2','s3','s4','s5','i6','i7','i8', 'original'});
result_path  = fullfile( save_path, name + '.dat' );
writetable(table_pred, result_path);

i
%end 
%end 
%end

