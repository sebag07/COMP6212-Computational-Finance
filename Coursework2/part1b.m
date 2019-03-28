% sed -i -E "s/CALL[^,]+ ([0-9]+)(,|$)/\1\2/g" Calls.csv
% sed -i -E "s/PUT[^,]+ ([0-9]+)(,|$)/\1\2/g" Calls.csv

dCalls = importOptions('Calls');
dPuts = importOptions('Puts');
[dFTSE, ~, ~] = xlsread("Data/FTSEOptionsData",3);

columns = dCalls.Properties.VariableNames;

strike = columns(:, :);
strike = str2double(extractAfter(strike,"JAN19"));



[T, col] = size(dCalls);
blsp = NaN(T, col);
blsc = NaN(T, col);
err = NaN(1, col);
timeToMaturity=275;

results = NaN(T, col);

for idx=2:col
    ofsset = 0;
    startT = 0;
    endT = T;
    
    for t=1:T
        if t >= 200 && startT == 0
            break
        end
        
        if startT == 0 && ~ismissing(dCalls{t, idx})
            offset = floor((T - t) / 4) + 1;
            startT = t + offset + 1;
        end
        
        if endT == T && startT ~= 0 && ismissing(dCalls{t,idx})
            endT = t - 1;
        end
    end
    
    if startT ~= 0
        for t=startT:endT
            if ismissing(dCalls{t, idx})
                break
            end
            
            daysUntilMaturity = endT - t + 1;
            
            [c, p] = blsprice(...
                dFTSE(t, 2),...% FTSE Price
                strike(1, idx),...% Strike Price
                0.02,...% Risk free rate
                daysUntilMaturity / 252,...% Time
                standard_volatility(dFTSE(t - offset : t - 1, 2)));% Volatility
%                 standard_volatility(dCalls{t - offset : t - 1, idx}));% Volatility
            blsc(t, idx) = c;
            blsp(t, idx) = p;
        end
    end
    
%         scatter(dCalls{:, idx}, blsc(:, idx), '.');
%     xlabel('True Price')
%     ylabel('Estimated call price')
%     zlabel('Real call price')
%     hold on
end

% hold off

diffCall = blsc(:,2:end) - dCalls{:, 2:end};
callMSE = nanmean((diffCall.^2),'all')
callRMSE = sqrt(nanmean((diffCall.^2),'all'))

diffPuts = blsp(:,2:end) - dPuts{:, 2:end};
putMSE = nanmean((diffPuts.^2),'all')
putRMSE = sqrt(nanmean((diffPuts.^2),'all'))

% figure
% for i=2:83
%     plot(70:T, diffPuts(70:end, i), 'k')
%     hold on
% end
% hold off
% xlabel('Time')
% ylabel('Black Scholes - True Price')

% blackscholes = NaN(1, 83)
% trueprice = NaN(1,83)
% 
% % figure
% for i=2:83
% %     plot(i, nanmean((blsc(:, i))), '.r')
% %     hold on
% %     plot(i, nanmean(dCalls{:, i}), '.b')
% %     xlabel('Option')
% %     ylabel('Call price')
% %     legend('Black-Scholes Call Price', 'True Price')
% blackscholes(1, i) = nanmean(blsc(:, i));
% trueprice(1, i) = nanmean(dCalls{:, i});
% end
% 
% figure
% hold on
%     plot(1:83, blackscholes, '.r');
%     plot(1:83, trueprice, '.b');
% hold off
% 
% xlabel('Option')
% ylabel('Call price')
% legend('Black-Scholes Call Price', 'True Price')

