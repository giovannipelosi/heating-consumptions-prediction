# heating-consumptions-prediction
#### Use of neaural networks to predict the consumption of electricity and heat of the next day

## useful links
#### Videos 
https://it.mathworks.com/videos/developing-forecast-models-from-time-series-data-in-matlab-part-1-93067.html
https://it.mathworks.com/videos/developing-forecast-models-from-time-series-data-in-matlab-part-2-93066.html

#### Sites 
https://it.mathworks.com/help/nnet/examples/time-series-forecasting-using-deep-learning.html
https://it.mathworks.com/help/nnet/ug/improve-neural-network-generalization-and-avoid-overfitting.html
https://it.mathworks.com/help/nnet/ug/ist-of-deep-learning-layers.html

## data
#### training data structure
The data contains samples about the consumptions of electricity and heat of an hospital.
The data is divided in three seasons and each season is subdivided in two groups: one containing the heating data and the other the electricity data. Finally for each of these gropus there are 28 datasets where each of them contains the data of 28 days (for training) and 1 (the next day) for testing.
For each day we have 24 samples (one per hour).
More in details :
- 1fold_out_tr contains the consumptions of the training data (the output of the training (heat or elec)
- 1fold_x_tr contains the training data (26 features)
- 1fold_out_ts contains the test output
- 1fold_x_ts contains the test input

all the data has been previously normalized

#### result data structure
Again the data is divided for each season and according to its type (heating or electricity).
For each train set we have multiple outputs : 
- matrices with the output results
- figures that compare the real value of the target and the predicted one

#### features
There are 26 input features
- 4 weather forecast infos for the specific hour (sample)
- 6 binary variables that identify the week day
- 1 binary vaiable that states if the day is holiday or not
- 12 weather forecast infos of the 3 previous (hours) samples
- 3 varaibles indicating the electric (or heating) consumption of the same hour of the same week day of the previous three weeks

#### training 
we cosidered two possible set of input features:
- small set : 11 features
1) 4 weather forecast infos for the specific hour (sample)
2) 6 binary variables that identify the week day
3) 1 binary vaiable that states if the day is holiday or not

- big set : all the 26 features

## expreriments
Here there is the list of the experiments (in order), with some comments.
See the main function for replication

#### first try (results ending by "output") experiment_1
First experiment to have a look at the data
networks used (in order):
- small_1 = feedforwardnet([5 5 5 5 5 5 5]);
- small_2 = feedforwardnet([5 5]);
- small_3 = feedforwardnet([11 8 8]);
- big_1 = feedforwardnet([5 5 5 5 5 5 5]);
- big_2 = feedforwardnet([5 5]);
- big_3 = feedforwardnet([26 15 15]);


Where small indicates that we used 11 features and big indicates that we used all the 26 features

###### conclusions experiment_1
The training procedure is relatively fast. Unfortunately the results (eye look) are not always accurate and not always the big train set beats the small one


#### lstm and aggregation try (results ending by "output_2") experiment_2
network used (in order):
    
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
    
    options = trainingOptions('sgdm', ...
    'MaxEpochs',300, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'MiniBatchSize', 40,...
    'Verbose',0 );
   
Here we used the same nework structure and we tryied to work a bit on the data. In particular we each network has been trained on four different datasets:
- small original
- small de_season (we simply tried to remove the "day" periodc trend, computed by avareging the consumption (grouped by hour) for the days of the training dataset) 
- all original
- all de-season

###### conclusions experiment_2
- the de-season networks perform better on some instances
- lstm take a very long time for training (even considering just one layer)
- there are 2 set of outputs ( a) all the nets output separately and b) aggregated by avereging the nets outputs grouped by dataset)
- results not always accurate

#### data multiplication (results ending by "output_3") experiment_3
Same experiment structure as experiment_2 but we tried to increase the dataset by adding more samples (we creaded more samples by adding a random (uniform) noise to the original data). In the experiment we made the dataset 6 times bigger.

###### conclusions experiment_3
Too much time for training all
Partial results apparently not significantly better when compared to the original datasets.

#### experiment 4 (results ending by "output_4") experiment_4
removed the lstm layer
and reduced the Max epoch

    layers_1 = [...
        sequenceInputLayer(number_of_inputs(k))
        fullyConnectedLayer(20)
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
    
    options = trainingOptions('sgdm', ...
    'MaxEpochs',120, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'MiniBatchSize', 40,...
    'Verbose',0 );



## TO DO NEXT
- work more on the paramenters of the net 
- try to enlarge the dataset by considering 2 months for training
- use of already trained data -> transfer learning :
1) try to find nets already trained by others (on similar datasets)
2) start from the net of the previous month and re-train it we the data of the current month.. (check foe repetetion in the datasets)
- ...

## EVALUATION
- compare all the results based on different metrics (rmse, ...)
