function [data] = dataMultiplication(input_dataset, mult_factor, noise_percentage , fix_random)
%DATA MULTIPLICATION increase the size of a dataset
%   given an input dataset create for each set of features (column)
%   multiple copy modified with a gaussian noise. Each column is considered
%   as indipendent from the others of the input dataset.
%   variables:
%   input_dataset : matrix in which the columns are the features
%   mult_factor : the size of the final set will be size(input_dataset) *
%   mult_factor
%   noise_percentage : the random noise will be computed cosidered the
%   range of values of the feature and the selected percentage of noise
%   (for instance: add or subtract at most 10% of the range of values)
%   fix_random : true or false

if (fix_random) % if fix_random is true
    rng(0,'twister'); % to make data repeatable
end

number_of_features = size(input_dataset,1);
input_size = size(input_dataset,2);
features_range = zeros(number_of_features); % for each feature identify the range of their values

% calculate ranges of the variables
for i = 1:number_of_features
    features_range(i) = max(input_dataset(i, :)) - min(input_dataset(i, :));
end

% create new data
% alterate each element randomly
final_size = floor(input_size * mult_factor);
data = zeros(number_of_features , final_size);

for i = 1:number_of_features
    for j = 1:final_size
        r = features_range(i) * noise_percentage;
        noise = (r.* rand()) - r/2;
        data (i,j) = input_dataset(i , floor(mod(j,input_size) + 1)) + noise ;
    end
end

end

