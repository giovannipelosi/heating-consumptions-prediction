%%
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',1)); 
rand('seed',12345); % used for reproducibility

kind = ["heating" , "elec"];

%for m = 1:2
%for n = 1:3
%for i = 1:28
i = 7;
n = 1;
m = 1;

%name = string(i) + "_output_2" ;
%figure_name =  string(i) + "_figure_2" ;
%save_path = 'Results/season' + string(n) + '/' + kind(m) +  '/';
load_path = 'deep-learning/season' + string(n) + '/' + string(kind(m)) + '/' + string(i) + 'foldv/' + string(i);

all_tr_x = csvread(load_path + 'fold_x_tr')';
tr_out = csvread(load_path + 'fold_out_tr')'; 
test_x = csvread(load_path + 'fold_x_ts')'; 
test_out = csvread(load_path + 'fold_out_ts')'; 

small_tr_x = all_tr_x(1:11 ,: );
test_small_x = test_x(1:11 , :);

% small -> 11 features
% big -> all the features


%%
% preprocessing
% remove linear trends
%{
all_data = [all_tr_x; tr_out];
detrend_data = detrend(all_data');
trend = all_data' - detrend_data;
%}

all_data = [all_tr_x; tr_out];
detrend_data_t = all_data;

% remove seasonal trend
%detrend_data_t = detrend_data';
seasonalComponent = [];
for l = 1:27
for k = 1:24
    temp = 0;
    j = k;
    while j <= 672
        temp = detrend_data_t(l , j) + temp;
        j = j + 24;
    end
    seasonalComponent(l,k) = temp / 28;
    
end
end

de_season_data = [];
for l = 1:27
for k = 1:24
    j = k;
    while j <= 672
        de_season_data(l,j) = detrend_data_t(l , j) -  seasonalComponent(l,k);
        j = j + 24;
    end
    
end
    
end



%%
% create net

% small 1
layers = [...
    sequenceInputLayer(26)
    %lstmLayer(11)
    %lstmLayer(11)
    fullyConnectedLayer(10)
    %fullyConnectedLayer(10)
    %fullyConnectedLayer(10)
    %fullyConnectedLayer(10)
    %fullyConnectedLayer(10)
    %fullyConnectedLayer(10)
    %fullyConnectedLayer(10)
    %fullyConnectedLayer(10)
    %fullyConnectedLayer(5)
    %fullyConnectedLayer(5)
    fullyConnectedLayer(1)
    regressionLayer()];

options = trainingOptions('adam', ...
    'MaxEpochs',500, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.01, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'MiniBatchSize', 40,...
    'Plots','training-progress',...
    'Verbose',0 );

%{
    'SquaredGradientDecayFactor',0.999,... 
    'L2Regularization',0.0001,...
    %}

%{
options = trainingOptions('adam', ...
    'MaxEpochs',300, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    %'Plots','training-progress'...
    );
%}
    
net = trainNetwork(all_tr_x, tr_out, layers, options);
net_detrend = trainNetwork(de_season_data(1:26, : ), de_season_data(27, : ), layers, options);


YPred = predict(net, test_x);

% de_tred the test
de_tred_test_x = [];
for l = 1:26
for k = 1:24
        de_tred_test_x(l,k) = test_x(l , k) -  seasonalComponent(l,k);

end
end

YPred_detrend = predict(net_detrend, de_tred_test_x);

YPred_w_trend = YPred_detrend + seasonalComponent(1,:);

%%
% plot result
figure
plot (YPred, 'r')
hold on
plot (YPred_w_trend , 'G')
hold on
plot (test_out , 'b')
legend ('pred', 'YPred_w_trend' , 'orig');
hold off

rmse = sqrt(mean((YPred-test_out).^2));
figure
subplot(2,1,1)
plot(test_out)
hold on
plot(YPred,'.-')
hold off
legend(["Observed" "Predicted"])
ylabel("Cases")
title("Forecast with Updates")

subplot(2,1,2)
stem(YPred - test_out)
xlabel("Month")
ylabel("Error")
title("RMSE = " + rmse)

%{
net = predictAndUpdateState(net,small_tr_x);

YPred = [];
numTimeStepsTest = numel(test_out);
for i = 1:numTimeStepsTest
    [net,YPred(1,i)] = predictAndUpdateState(net,test_small_x(:,i));
end
rmse = sqrt(mean((YPred-test_out).^2));

numTimeStepsTrain = numel(tr_out);
%}
%{
figure
plot(data(1:numTimeStepsTrain))
hold on
idx = numTimeStepsTrain:(numTimeStepsTrain+numTimeStepsTest);
plot(idx,[data(numTimeStepsTrain) YPred],'.-')
hold off
xlabel("Month")
ylabel("Cases")
title("Forecast")
legend(["Observed" "Forecast"])
%}

%{
original = [small_tr_x(1,:) , test_out];
trained_s_1 = [small_tr_x(1,:) , YPred];

figure
plot (trained_s_1,'r');
hold on
plot (original, 'b');
legend ('trained_s_1', 'original');
hold off


rmse = sqrt(mean((YPred-test_out).^2));


figure
subplot(2,1,1)
plot(test_out)
hold on
plot(YPred,'.-')
hold off
legend(["Observed" "Predicted"])
ylabel("Cases")
title("Forecast with Updates")

subplot(2,1,2)
stem(YPred - test_out)
xlabel("Month")
ylabel("Error")
title("RMSE = " + rmse)
%}

%YPred = predict(net,test_small_x,'MiniBatchSize',1);


% training paramenters parameters -> avoid early stop (might overfit)
%{
small_1 = feedforwardnet([5 5 5 5 5 5 5 5 5]);
[small_1, tr_s_1] = train(small_1, small_tr_x,tr_out);

output_s_1 = [];
for j = 1:size(test_small_x,2)
    output_s_1 = [output_s_1 , small_1(test_small_x(:,j))]; 
end

%}
%{
miniBatchSize = 1;
options = trainingOptions( 'sgdm','InitialLearnRate',0.00001,'MiniBatchSize', miniBatchSize,'Plots', 'training-progress');
layers2 = [ 
            sequenceInputLayer(11)
            fullyConnectedLayer(2)
            fullyConnectedLayer(5)
            fullyConnectedLayer(6)
            fullyConnectedLayer(1)
            regressionLayer()
         ];
net2 = trainNetwork(small_tr_x, tr_out, layers, options);



YPred2 = predict(net2,test_small_x,'MiniBatchSize',1);
%}
%{
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


%}


%get the directory of your input files:
%pathname = fileparts('/prova');
%use that when you save
%matfile = fullfile(pathname, 'output.mat');
%figfile = fullfile(pathname, 'output.fig');
%save(matfile, );
%saveas(figfile );




%end
%end
%end