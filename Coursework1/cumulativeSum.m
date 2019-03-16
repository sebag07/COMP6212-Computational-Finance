function sumArray = cumulativeSum(returns)

sum_pls = 0;
sumArray = zeros(length(returns), 1);

for i = 1:length(returns)
   sum_pls = sum_pls + returns(i);
   sumArray(i) = sum_pls;
end

end