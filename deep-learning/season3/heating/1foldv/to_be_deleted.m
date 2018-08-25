data = thingSpeakRead(12397,'Fields',[2 3 4 6],'DateRange',[datetime('Sep 7, 2016'),datetime('Sep 9, 2016')],...
    'outputFormat','table');

% Assign input variables
inputs = [data.Humidity'; data.TemperatureF'; data.PressureHg'; data.WindSpeedmph']; 
% Calculate dew point from temperature and relative humidity to use as the target
% Convert temperature from Fahrenheit to Celsius
tempC = (5/9)*(data.TemperatureF-32);
% Specify the constants for water vapor (b) and barometric pressure (c)
b = 17.62;
c = 243.5;
% Calculate the intermediate value 'gamma'
gamma = log(data.Humidity/100) + b*tempC ./ (c+tempC);
% Calculate dew point in Celsius
dewPointC = c*gamma ./ (b-gamma);
% Convert to dew point in Fahrenheit
dewPointF = (dewPointC*1.8) + 32;

% Assign target values for the network
targets = dewPointF';