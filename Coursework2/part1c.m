% sed -i -E "s/CALL[^,]+ ([0-9]+)(,|$)/\1\2/g" Calls.csv
% sed -i -E "s/PUT[^,]+ ([0-9]+)(,|$)/\1\2/g" Calls.csv


dCalls = importOptions('Calls');
dPuts = importOptions('Puts');
[dFTSE, ~, ~] = xlsread("Data/FTSEOptionsData",3);

columns = dCalls.Properties.VariableNames;

strike = columns(:, :);
strike = str2double(extractAfter(strike,"JAN19"));



[T, col] = size(dCalls);
results = NaN(T, col);


days = randperm(275 - 70, 30) + 70

vols = NaN(30, col);
impl = NaN(30, col);
strikeArray = NaN(1, 30);

for d=1:30   
    for idx=1:83  
        t = days(d);
        if ismissing(dCalls{floor(t - T/4), idx+1}) || ismissing(dCalls{t, idx+1})
            continue
        end
        
        vols(d, idx+1) = standard_volatility(dFTSE(floor(t - T/4) : t - 1, 2));
        % blsimpv(Price,Strike,Rate,Time,Value)
        impl(d, idx+1) = blsimpv(...
            dFTSE(t, 2),...
            strike(1, idx+1),...
            dFTSE(t, 3) / 100,...
            70 / 252,...
            dCalls{t, idx+1});
    end
    newArray = table2array(dCalls(days(d), 2:end));
    strikeArray(1, d) = nanmean(newArray);
end

timeArray = zeros(30, 30);

for i=1:30
    for j=1:30
        timeArray(i,j) = i;
    end
end

mv = NaN(1, 30);
mi = NaN(1, 30);



for i=1:30
    mv(i) = nanmean(vols(i,:));
    mi(i) = nanmean(impl(i,:));
end

% figure
% for i=1:84
%     scatter3(strike(i) * ones(30,1), 1:30, impl(:, i), '.')
% hold on
% % scatter(1:84, vols(27, :))
% end
% xlabel('Strike')
% ylabel('Days')
% zlabel('Volatility')
% hold off

% xlabel('Days')
% ylabel('Volatility')
% zlabel
% figure
% hold on
% scatter(1:30, mi, 'k')
% xlabel('Days')
% ylabel('Implied volatility')
% hold off