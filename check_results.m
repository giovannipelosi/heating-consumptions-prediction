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
A = table2array(T);
original = A(:, end);
for col = 1:size(A,2)-1
rmse = sqrt(mean((A(:,col)-original).^2));
row = (m-1) * 28 * 3 + (n-1) * 28 + i;
bunch_of_nets_rmse_total_by_day(row , col) = rmse;
end

(m-1) * 28 * 3 + (n-1) * 28 + i % counter to check progression of the work
end
end
end

overall_rmse_total_by_day (1:168 , ((out_num - 1) * 28) + 1 : (out_num) * 28) = bunch_of_nets_rmse_total_by_day;
end


%% average performance 
overall_rmse_mean = zeros(1 , 28 * 3);
season_1_rmse_mean = zeros(1 , 28 * 3);
season_2_rmse_mean = zeros(1 , 28 * 3);
season_3_rmse_mean = zeros(1 , 28 * 3);
season_1_rmse_mean_elec = zeros(1 , 28 * 3);
season_2_rmse_mean_elec = zeros(1 , 28 * 3);
season_3_rmse_mean_elec = zeros(1 , 28 * 3);
season_1_rmse_mean_heat = zeros(1 , 28 * 3);
season_2_rmse_mean_heat = zeros(1 , 28 * 3);
season_3_rmse_mean_heat = zeros(1 , 28 * 3);

for col = 1: size(overall_rmse_total_by_day,2)
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

% by season
% by month

