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

#### experiment 4 (results ending by "output_4") experiment_4 1h 10m
removed the lstm layer
and reduced the Max epoch
(no data multiplication)

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


#### experiment 5 and 6
change the training options but same structures

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

    options_1 = trainingOptions('sgdm', ...
        'MaxEpochs',220, ...
        'GradientThreshold',1, ...
        'InitialLearnRate',0.005, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',125, ...
        'LearnRateDropFactor',0.2, ...
        'MiniBatchSize', 40,...
        'Verbose',0 );
    nets_options{end + 1} = options_1;


    options_2 = trainingOptions('adam', ...
        'MaxEpochs',220, ...
        'GradientThreshold',0.95, ...
        'InitialLearnRate',0.05, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',70, ...
        'LearnRateDropFactor',0.3, ...
        'MiniBatchSize', 40,...
        'SquaredGradientDecayFactor',0.95,...
        'L2Regularization',0.0001,...
        'Verbose',0 );
    nets_options{end + 1} = options_2;

## TO DO NEXT
- work more on the paramenters of the net 
- try to enlarge the dataset by considering 2 months for training
- use of already trained data -> transfer learning :
1) try to find nets already trained by others (on similar datasets)
2) start from the net of the previous month and re-train it we the data of the current month.. (check foe repetetion in the datasets)
- ...

## EVALUATION
### 1) evaluations of the output of the nets from _4 to _6 (output_4,output_5,output_6) -> 84 nets are considered (mean of the rsme for each season)
#### TOP 10 elec
     season 1                           season 2                            season 3
     kind of net :        rmse          kind of net :          rmse         kind of net :        rmse
 1   "all_deseason_40"    "0.059021"    "small_deseason_70"    "0.11623"    "all_deseason_56"    "0.055899"
 2   "all_deseason_72"    "0.059078"    "small_deseason_58"    "0.11646"    "all_deseason_80"    "0.055916"
 3   "all_deseason_32"    "0.059283"    "small_deseason_82"    "0.11652"    "all_deseason_44"    "0.056047"
 4   "all_deseason_44"    "0.059527"    "small_deseason_62"    "0.11675"    "all_deseason_40"    "0.056232"
 5   "all_deseason_76"    "0.060081"    "small_deseason_66"    "0.11722"    "all_deseason_36"    "0.056552"
 6   "all_deseason_68"    "0.060191"    "small_deseason_74"    "0.11753"    "all_deseason_76"    "0.056567"
 7   "all_deseason_16"    "0.060398"    "small_deseason_78"    "0.11814"    "all_deseason_68"    "0.056705"
 8  "all_deseason_80"    "0.060421"    "small_57"             "0.1183"     "all_deseason_60"    "0.057028"
 9   "all_deseason_8"     "0.061021"    "small_61"             "0.12021"    "all_deseason_64"    "0.057055"
 10   "all_deseason_36"    "0.061359"    "small_81"             "0.12337"    "all_deseason_72"    "0.057151"

For all the seasons we can see that the trend_removal is quite effective. indeed almost all the best performing nets are those that have been trained using the de_season dataset. 
Further investigation is necessary on the season 2. Apparetly a dataset with less features (11 instead of 26) allows the net to perform better.
Almost all the nets come from the output_6 set (see the numbers on the name [from 57 to 84]) -> experiment 6 : options_2 -> 'adam' algorithm.

#### TOP 10 heat
     season 1                   season 2                            season 3
     kind of net  rmse      kind of net :   rmse         kind of net :        rmse
1    "all_55"    "0.1058"     "all_75"    "0.071589"    "all_deseason_84"    "0.059433"
2    "all_35"    "0.10647"    "all_43"    "0.07177"     "all_deseason_64"    "0.059747"
3    "all_71"    "0.10706"    "all_55"    "0.071785"    "all_deseason_60"    "0.060165"
4    "all_31"    "0.10754"    "all_3"     "0.072347"    "all_deseason_28"    "0.06032" 
5    "all_59"    "0.10768"    "all_47"    "0.072429"    "all_deseason_72"    "0.06074" 
6    "all_43"    "0.10825"    "all_35"    "0.072557"    "all_deseason_68"    "0.060958"
7    "all_63"    "0.10903"    "all_31"    "0.072701"    "all_deseason_80"    "0.06116" 
8    "all_67"    "0.11012"    "all_67"    "0.073447"    "all_deseason_56"    "0.061252"
9    "all_39"    "0.1102"     "all_79"    "0.073576"    "all_deseason_36"    "0.061338"
10   "all_83"    "0.11024"    "all_51"    "0.073652"    "all_deseason_76"    "0.061376"

For all the seasons the "all_features" dataset allowed better peformances.
There is a significat difference of perfomance though, among the seasons; and only on season 3 the de_season preprocess has been helpful (season 3 is indeed a more clean dataset). 
In season 3 the 'adam' algorithm has produced the best results -> Almost all the nets come from the output_6 set (see the numbers on the name [from 57 to 84]) -> experiment 6 : options_2 -> 'adam' algorithm.
While there is not a clear winner (options_1 or options_2 [experiment 5 and 6]) for season 1 and 2.

Overall we can conlude that the big feature dataset (26 features) allow to reach better performance(5 over 6). Different nets perform better on different dataset (with a preference for the adam algorithm).
...

TO DO
modify the most promising nets in order to try to increase the perfomances. (working by season and preprocessed dataset).




- compare all the results based on different metrics (rmse, ...)
- compare nets according to :
1) overall performance
2) seasonal performance
3) month ? 
4) aggregation?
5) ...
