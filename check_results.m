%%
% check results
% load the different solutions and find the best neural network!

% procedure ..
% 1) load one result and compute the evaluation (e.g. rmse) ->
%   vector[1 : number_of_nets]
% 2) repeat for each result ->
%   matrix [168 : number_of_nets]
% 3) compute the average ->
%   vector [1 : number_of_nets] (above all, by season,by month ...)
% 4) repeat for the other sets of nets (and append) ->
%   vector [1 : number_of_sets * number_of_nets]
% 5) compare results and judge
%% variables
kind = ["heating" , "elec"];
bunch_of_nets_rmse_total_by_day = zeros(168, 28); % 28 is number of nets in one output (might be different)
overall_rmse_total_by_day = zeros(168, 28 * 3);
shift_out_num = 3; % out_num is the name of the output -> considered from 1 plus the constant shift
%% load the data from results
for out_num = 1:3
    for m = 1:2
        for n = 1:3
            for i = 1:28
                %out_num = 4;
                %i = 1;
                %n = 3;
                %m = 2;
                
                file_name = string(i) + '_output_' + string(out_num + shift_out_num) + '.dat';
                
                load_path = 'Results/season' + string(n) + '/' + kind(m) +  '/';
                %data = csvread(load_path + file_name)';
                T = readtable(load_path + file_name);
                
                
                
                
                %% compute rmse
                number_of_models = 28;
                A = table2array(T);
                original = A(:, end);
                for col = 1:size(A,2)-1
                    rmse = sqrt(mean((A(:,col)-original).^2));
                    row = (m-1) * number_of_models * 3 + (n-1) * number_of_models + i ;
                    bunch_of_nets_rmse_total_by_day(row , col) = rmse;
                end
                
                (m-1) * 28 * 3 + (n-1) * 28 + i % counter to check progression of the work
            end
        end
    end
    
    overall_rmse_total_by_day (1:168 , ((out_num - 1) * 28) + 1 : (out_num) * 28) = bunch_of_nets_rmse_total_by_day;
end


%% average performance

num_of_nets = size(overall_rmse_total_by_day,2);


overall_rmse_mean = zeros(1 , num_of_nets);
%season_1_rmse_mean = zeros(1 , 28 * 3);
%season_2_rmse_mean = zeros(1 , 28 * 3);
%season_3_rmse_mean = zeros(1 , 28 * 3);
season_1_rmse_mean_elec = zeros(1 , num_of_nets);
season_2_rmse_mean_elec = zeros(1 , num_of_nets);
season_3_rmse_mean_elec = zeros(1 , num_of_nets);
season_1_rmse_mean_heat = zeros(1 , num_of_nets);
season_2_rmse_mean_heat = zeros(1 , num_of_nets);
season_3_rmse_mean_heat = zeros(1 , num_of_nets);



for col = 1: num_of_nets
    overall_rmse_mean (col) = mean(overall_rmse_total_by_day(:,col));
    season_1_rmse_mean_heat (col) = mean (overall_rmse_total_by_day(1:28 , col));
    season_2_rmse_mean_heat (col) = mean (overall_rmse_total_by_day(29:56 , col));
    season_3_rmse_mean_heat (col) = mean (overall_rmse_total_by_day(57:84 , col));
    season_1_rmse_mean_elec (col) = mean (overall_rmse_total_by_day(85:112 , col));
    season_2_rmse_mean_elec (col) = mean (overall_rmse_total_by_day(113:140 , col));
    season_3_rmse_mean_elec (col) = mean (overall_rmse_total_by_day(141:168 , col));
    %season_1_rmse_mean = mean([season_1_rmse_mean_heat (col); season_1_rmse_mean_elec(col)]);
    %season_2_rmse_mean = mean([season_2_rmse_mean_heat (col); season_2_rmse_mean_elec(col)]);
    %season_3_rmse_mean = mean([season_3_rmse_mean_heat (col); season_3_rmse_mean_elec(col)]);
end

index = strings(1 , num_of_nets);
for k = 1:num_of_nets
    temp = mod(k,4);
    switch temp
        case 1
            index(k) = "small_" + string(k);
        case 2
            index(k) = "small_deseason_" + string(k);
        case 3
            index(k) = "all_" + string(k);
        otherwise
            % 0
            index(k) = "all_deseason_" + string(k);
    end
    
end

%% sort results
% first column is the number corresponding to the net
% second column is the rmse value
season_1_rmse_mean_heat = sortrows([index ; season_1_rmse_mean_heat]',2);
season_2_rmse_mean_heat = sortrows([index ; season_2_rmse_mean_heat]',2);
season_3_rmse_mean_heat = sortrows([index ; season_3_rmse_mean_heat]',2);
season_1_rmse_mean_elec = sortrows([index ; season_1_rmse_mean_elec]',2);
season_2_rmse_mean_elec = sortrows([index ; season_2_rmse_mean_elec]',2);
season_3_rmse_mean_elec = sortrows([index ; season_3_rmse_mean_elec]',2);

%% result table
results_elec = [season_1_rmse_mean_elec , season_2_rmse_mean_elec, season_3_rmse_mean_elec];
results_heat = [season_1_rmse_mean_heat , season_2_rmse_mean_heat, season_3_rmse_mean_heat];

%% top_ten
top_ten_elec = results_elec(1:10 , :);
top_ten_heat = results_heat(1:10 , :);

%% season ranking
rank = zeros(84,2);
% choose the best 2 seasons
 col_a = 3; % number of the column (names)
 col_b = 5;
 % choose the dataset
 data = results_heat; 
 
for i = [1:84] % i is the rank of the net in the first column
    for j = [1:84]
        if (data(i,col_a) == data(j, col_b))
            %rank(i, : ) = [i , i * double(data(i,col_a + 1))  + double(data(j, col_b + 1)) * j];
            rank(i , : ) = [i, i + j];
        end
    end
end

rank = sortrows(rank, 2);
