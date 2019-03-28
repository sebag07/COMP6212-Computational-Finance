function volatility = standard_volatility(data) 
    returns = price2ret(data);
    s = std(returns);
    
    N = size(data);
    N = N(1);
    volatility = s / sqrt(N / 252);
end