%% init
rand('seed',1234); % used for reproducibility

kind = ["heating" , "elec"]; % kind of data

% uncomment to cycle on all the data (see end of the script)
for m = 1:2
for n = 1:3
for i = 1:28

% set for test otherwise comment
%i = 7;
%n = 3;
%m = 1;


% LOAD DATA
name = string(i) + "_output_2" ;
figure_name =  string(i) + "_figure_2" ;
save_path = 'Results/season' + string(n) + '/' + kind(m) +  '/';
load_path = 'deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(i) + 'foldv/' + string(i);

all_tr_x = csvread(load_path + 'fold_x_tr')';
tr_out = csvread(load_path + 'fold_out_tr')';
test_x = csvread(load_path + 'fold_x_ts')';
test_out = csvread(load_path + 'fold_out_ts')';

small_tr_x = all_tr_x(1:11 ,: ); % consider only the first 11 features
test_small_x = test_x(1:11 , :); % smaller version of the dataset


%% perform preprocessing ? -> remove linear trends and seasonal trends

% WORKING/USEFUL ? -> just removed the "daily" trand by avereging (by hour); for
% instance considering the first feature, we sum the data 1,25,49,.. and
% divide by 28 (number of days in the dataset

% applied to all the variables (should we remove the 'day of the week'
% variables ?)


% remove linear trends first
% remove seasonal trends
% (remove the same? trends also when we test -> REMEMBER to add it back to
% before plotting results

% variables

dataset = all_tr_x; % 26 feature dataset -> for the 11, just take the first 11 features

dayHours = 24;
daysInDataset = 28;

all_data = [dataset; tr_out]; % de-trend also the output (train data)

% remove seasonal trend
%detrend_data_t = detrend_data';
seasonalComponent = zeros(size(all_data,1), dayHours);
for l = 1:size(all_data,1)
    for k = 1:dayHours
        temp = 0;
        j = k;
        while j <= size(all_data,2)
            temp = all_data(l , j) + temp;
            j = j + dayHours;
        end
        seasonalComponent(l,k) = temp / daysInDataset;
    end
end

de_season_data = zeros(size(all_data,1), size(all_data,2));
for l = 1:size(all_data,1)
    for k = 1:dayHours
        j = k;
        while j <= size(all_data,2)
            de_season_data(l,j) = all_data(l , j) -  seasonalComponent(l,k);
            j = j + dayHours;
        end
    end
end

% de_tred the test -> remove from the test data the seasonal component
de_tred_test_x = zeros(size(test_x,1),size(test_x,2));
for l = 1:size(test_x,1)
    for k = 1:dayHours
        de_tred_test_x(l,k) = test_x(l , k) -  seasonalComponent(l,k);
        
    end
end
%% create networks
% variables
number_of_inputs = [11 26];
%num_of_layers_sets = 7; % modify if you change the layers
layers = {}; %list of the sets of layers

for k = 1:2
    
    layers_1 = [...
        sequenceInputLayer(number_of_inputs(k))
        lstmLayer(20)
        fullyConnectedLayer(1)
        regressionLayer()];
    layers{end + 1} = layers_1;
    
    layers_2 = [...
        sequenceInputLayer(number_of_inputs(k))
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];
    layers{end + 1} = layers_2;
    
    layers_3 = [...
        sequenceInputLayer(number_of_inputs(k))
        fullyConnectedLayer(5)
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];
    layers{end + 1} = layers_3;
    
    layers_4 = [...
        sequenceInputLayer(number_of_inputs(k))
        fullyConnectedLayer(15)
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];
    layers{end + 1} = layers_4;
    
    layers_5 = [...
        sequenceInputLayer(number_of_inputs(k))
        fullyConnectedLayer(15)
        fullyConnectedLayer(15)
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];
    layers{end + 1} = layers_5;
    
    layers_6 = [...
        sequenceInputLayer(number_of_inputs(k))
        fullyConnectedLayer(15)
        fullyConnectedLayer(5)
        fullyConnectedLayer(5)
        fullyConnectedLayer(1)
        regressionLayer()];
    layers{end + 1} = layers_6;
    
    layers_7 = [...
        sequenceInputLayer(number_of_inputs(k))
        fullyConnectedLayer(100)
        fullyConnectedLayer(1)
        regressionLayer()];
    layers{end + 1} = layers_7;
    
end

options = trainingOptions('sgdm', ...
    'MaxEpochs',300, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'MiniBatchSize', 40,...
    'Verbose',0 );

% additional option settings
%{
    'adam' or 'sgdm' or 'rmsprop'
    'SquaredGradientDecayFactor',0.999,...
    'L2Regularization',0.0001,...
    'Plots','training-progress',...
'Plots','training-progress',...
%}

%% train network
% for each set of layers we will build 4 nets cosidering the 4 datasets:
% small_tr_x -> 11_features_original
% de_season_data(1:11, :) -> 11_features_detrend
% all_tr_x -> 26_features_original
% de_season_data(1:26, :) -> 26_features_detrend

% the output train is the 27th feature in de_season_data (end list keyword)
layers_size_half = size(layers,2) / 2;
nets = cell(1 , 4 * layers_size_half); % list of networks

for k = 0:layers_size_half-1
    nets{4 * k + 1} = trainNetwork(small_tr_x, tr_out, layers{k + 1}, options);
    nets{4 * k + 2} = trainNetwork(de_season_data(1:11, : ), de_season_data(end, : ), layers{k + 1}, options);
    nets{4 * k + 3} = trainNetwork(all_tr_x, tr_out, layers{layers_size_half + k + 1}, options);
    nets{4 * k + 4} = trainNetwork(de_season_data(1:26, : ), de_season_data(end, : ), layers{layers_size_half + k + 1}, options);
end

%% predict
predictions = cell(1 , size(nets,2)); % store the prediciton results

for k = 0:(size(nets,2)/4)-1
    predictions{4 * k + 1} = predict(nets{4 * k + 1}, test_small_x); % small orig
    predictions{4 * k + 2} = predict(nets{4 * k + 2}, de_tred_test_x(1 : 11, :)) + seasonalComponent(end,:); %  test on small deseason data and add seasonal component
    predictions{4 * k + 3} = predict(nets{4 * k + 3}, test_x); % all orig
    predictions{4 * k + 4} = predict(nets{4 * k + 4}, de_tred_test_x) + seasonalComponent(end,:); % test on all deseason data and add seasonal component
end

%% composed predictions
composed_predictions = cell(1,4);

% aggregation of nets with same data
num_of_hours = size(test_x,2);
num_of_nets = size(nets,2)/4;
for k = 1:4 % divide by dataset type
    aggregated_pred = zeros(1,num_of_hours);
    for p = 1:num_of_hours % dimension of the test (one day predition -> 24 hours is the size)
        temp = 0;
        for l = 0:num_of_nets-1 % divide by net
            temp = temp + predictions{4 * l + k}(p);
        end
        aggregated_pred(p) = temp / num_of_nets;
    end
    composed_predictions{k} = aggregated_pred;
end


%% plot and save data
f_1 = figure;
title (figure_name)
% plot predicitons
for k = 1:size(predictions,2)
    plot(predictions{k});
    hold on
end
% plot orignal data
plot(test_out)
hold on
legend ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','original');
temp = save_path + figure_name;
saveas(f_1,temp , 'fig');
hold off
close(f_1);

f_2 = figure;
title (figure_name + "_aggregated")
% plot predicitons
for k = 1:size(composed_predictions,2)
    plot(composed_predictions{k});
    hold on
end
% plot orignal data
plot(test_out)
hold on
legend ('small','small_de','all','all_de','original');
temp = save_path + figure_name + "_aggregated";
saveas(f_2,temp , 'fig');
hold off
close(f_2);

% save results ...
predictions{end + 1} = test_out; % append the original data
composed_predictions{end + 1} = test_out; % append the original data

for k = 1:size(predictions,2)
    predictions{k} = double(predictions{k}');
end
predictions = cell2mat(predictions);

table_pred = array2table(predictions, 'VariableNames', {'small_1','small_de_2','all_3','all_de_4','small_5','small_de_6','all_7','all_de_8','small_9','small_de_10','all_11','all_de_12','small_13','small_de_14','all_15','all_de_16','small_17','small_de_18','all_19','all_de_20','small_21','small_de_22','all_23','all_de_24','small_25','small_de_26','all_27','all_de_28', 'original'});

for k = 1:size(composed_predictions,2)
    composed_predictions{k} = composed_predictions{k}';
end
composed_predictions = cell2mat(composed_predictions);

table_aggr = array2table(composed_predictions, 'VariableNames', {'agg_small_1','agg_small_de_2','agg_all_3','agg_all_de_4','original'});

result_path  = fullfile( save_path, name + '.dat' );
result_path_agg  = fullfile( save_path, name + "_agg" + '.dat' );
writetable(table_pred, result_path);
writetable(table_aggr, result_path_agg);

(m-1) * 2 + (n-1) * 3 + i
%% end
% uncomment to cycle on all the data (see begin of the script)
end
end
end