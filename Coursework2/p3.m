clear;
calls=readtable("Data/Calls2.csv","ReadVariableNames",true);
puts=readtable("Data/Puts2.csv","ReadVariableNames",true);
ftse_prices=xlsread("Data/FTSEOptionsData.xlsx",3);
ftse_prices=ftse_prices(:,1);
T = size(calls(:, 1),1)
quarter = round(T/4);
strike_prices = calls.Properties.VariableNames(2:28);


for x = 1:10
    implied_volatilities = zeros(27, 1);
    calculated_volatilities = zeros(27, 1);
    t = round((rand()) * (T - (quarter+1)) + quarter + 1);
    for ref = 1:27
        strike_price = strike_prices(ref);
        strike_price = str2double(erase(strike_price{:},'x'));
        call_prices = table2array(calls(:,strike_prices(ref)));
        put_prices = table2array(puts(:,strike_prices(ref)));
        thing  = blsimpv(ftse_prices(t), strike_price, 0.02, (T + 1 - t) / 365, call_prices(t))
        implied_volatilities(ref) = thing;
        window = call_prices((t-quarter):t);
        u = tick2ret(window, [], 'Continuous');
        s = std(u);
        N = size(window, 1);
        calculated_volatilities(ref) = s / sqrt(N / 239);
    end
    
%     figure;
%     scatter(implied_volatilities, calculated_volatilities);
%     hold on;
%     % plot(0:0.05:0.05, 0:0.05:0.05);
%     title(strcat('Implied volatility vs estimated volatility' , sprintf(' Day %d',t)));
%     xlabel('Implied volatility');
%     ylabel('Estimated volatility');
end

for x = 1:30
    implied_volatilities = zeros(27, 1);
    calculated_volatilities = zeros(27, 1);
    t = round((rand()) * (T - (quarter+1)) + quarter + 1);
    for ref = 1:27
        strike_price = strike_prices(ref);
        strike_price = str2double(erase(strike_price{:},'x'));
        call_prices = table2array(calls(:,strike_prices(ref)));
        put_prices = table2array(puts(:,strike_prices(ref)));
        thing  = blsimpv(ftse_prices(t), strike_price, 0.02, (T + 1 - t) / 365, call_prices(t))
        implied_volatilities(ref) = thing;
        window = call_prices((t-quarter):t);
        u = tick2ret(window, [], 'Continuous');
        s = std(u);
        N = size(window, 1);
        calculated_volatilities(ref) = s / sqrt(N / 239);
    end
    
%     figure;
%     scatter(implied_volatilities, calculated_volatilities);
%     hold on;
%     % plot(0:0.05:0.05, 0:0.05:0.05);
%     title(strcat('Implied volatility vs estimated volatility' , sprintf(' Day %d',t)));
%     xlabel('Implied volatility');
%     ylabel('Estimated volatility');
end
