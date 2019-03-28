strike = 4000;
rate = 0.02;
[ftse, ~, ~] = xlsread("Data/FTSEOptionsData",3);
T = 275;
window = ceil(T / 4);

dataset = NaN(T, 1);

ttm = NaN(T, 1);

for t=window + 1:T
    vol = standard_volatility(ftse(t - window: t - 1, 2));
%     get FTSE data for more than 275
%     timeToMaturity = (252 - mod(t, 252)) / 252;
    timeToMaturity = (T - t) / 252;
    [c, ~] = blsprice(ftse(t,2), strike, ftse(t,3) / 100, timeToMaturity, vol);
    
    dataset(t) = c;
    ttm(t) = timeToMaturity;
end

input = ftse(window + 1:T,2);
output = dataset(window + 1:T, :);
%% RBF MODEL
net = newrb(input', output', 0.25, 5);

result = net(input');

% figure
% plot(window + 1:T, dataset(window + 1:T), '+');
% hold on
% plot(window + 1:T, result)
% hold off

range = window + 1 : T;
result = result / strike;
ftse_normalised = ftse(range, 2) / strike;

figure
scatter3(ttm(range), ftse_normalised, result', 'filled')

% figure


%% Gaussian Mixture model
model = fitgmdist(output, 2)