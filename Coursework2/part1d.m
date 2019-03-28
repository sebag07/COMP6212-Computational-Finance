% sed -i -E "s/CALL[^,]+ ([0-9]+)(,|$)/\1\2/g" Calls.csv
% sed -i -E "s/PUT[^,]+ ([0-9]+)(,|$)/\1\2/g" Calls.csv


dCalls = importOptions('Calls');
dPuts = importOptions('Puts');
[dFTSE, ~, ~] = xlsread("Data/FTSEOptionsData",3);

columns = dCalls.Properties.VariableNames;

strike = columns(:, :);
strike = str2double(extractAfter(strike,"JAN19"));

[T, col] = size(dCalls);



t = 70;
idx = randi([2, 84]);

abs_diff = NaN(T, 1);

for dt=t:T 
    if ismissing(dFTSE(floor(t - 69), 2)) || ismissing(dFTSE(t, 2))
        continue
    end

    v = standard_volatility(dFTSE(t - 69 : t - 1, 2));

    [c, p] = blsprice(...
                dFTSE(t, 2),...% FTSE Price
                strike(1, idx),...% Strike Price
                dFTSE(t, 3) / 100,...% Risk free rate
                (T - dt) / 252,...% Time
                v...% Volatility
                );

    [price, lattice] = LatticeEurCall(...
        dFTSE(t,2),...
        strike(1, idx),...
        dFTSE(t, 3) / 100,...
        (T - dt) /252,...
        v,...
        100 ...
    );

    abs_diff(dt) = price - c;
%     scatter(vols, impl, 'filled');
end

log_diff = real(log(abs_diff));
plot(abs_diff);
disp(strcat('Option #', num2str(idx)))
xlabel('Time')
ylabel('Lattice error')

for tau=1:50
    disp("tau")
    disp(tau)
    for i= (tau+1):2:(2*50+1-tau)
        disp(i)
        
    end
    
end

