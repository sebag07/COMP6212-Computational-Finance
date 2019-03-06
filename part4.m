[RB_Dates, RB_Returns] = readStock("cleared/TSCO.L.csv");
[TSCO_Dates, TSCO_Returns] = readStock("cleared/EZJ.L.csv");
[CPG_Dates, CPG_Returns] = readStock("cleared/ANTO.L.csv");

half = size(RB_Returns) / 2 

Half_Dates = RB_Dates(1:half);
Half_RB_Returns = RB_Returns(1:half);
Half_TSCO_Returns = TSCO_Returns(1:half);
Half_CPG_Returns = CPG_Returns(1:half);

RB_MeanReturn = mean(Half_RB_Returns);
TSCO_MeanReturn = mean(Half_TSCO_Returns);
CPG_MeanReturn = mean(Half_CPG_Returns);

nr_of_weights = 100;

one_array = ones(nr_of_weights,3);

Mean_Vector = [RB_MeanReturn TSCO_MeanReturn CPG_MeanReturn];

ConcatenatedStocks = horzcat(Half_RB_Returns, Half_TSCO_Returns, Half_CPG_Returns);

C = cov(ConcatenatedStocks);

[NRet, NRisk, RWts] = NaiveMV(Mean_Vector, C, nr_of_weights);

BestPortfolio = getBestPortfolio(RWts, C, Mean_Vector);
One_Over_N = [(1/3) (1/3) (1/3)];

[BestDates, BestReturns] = getDailyReturns(BestPortfolio, RB_Dates(half+1:end), RB_Returns(half+1:end), TSCO_Returns(half+1:end), CPG_Returns(half+1:end));
[NaiveDates, NaiveReturns] = getDailyReturns(One_Over_N, RB_Dates(half+1:end), RB_Returns(half+1:end), TSCO_Returns(half+1:end), CPG_Returns(half+1:end));

bestMean = mean(BestReturns);
naiveMean = mean(NaiveReturns);

bestCov = cov(BestReturns)
naiveCov = cov(NaiveReturns)

err = immse(BestReturns, NaiveReturns)

half(1)

sum1Array = zeros(half(1), 1);
sum2Array = zeros(half(1), 1);

sum1Array = cumulativeSum(BestReturns)
sum2Array = cumulativeSum(NaiveReturns)

procent = zeros(half(1),1);

sum1 = 0;
sum2 = 0;

for i = 1:half
    procent(i) = sum1Array(i)/sum2Array(i);
end

procent = log10(procent);
var1 = procent; var2 = procent;

var1(var1 < 0) = nan
var2(var2 > 0) = nan

%% Plot log graph

% hold on
% 
% area(BestDates, var1, "DisplayName", "Efficient Portfolio");
% area(NaiveDates, var2, "DisplayName", "1/N Portfolio");
% title("Efficient vs 1/N Portfolio")
% xlabel("Dates")
% ylabel("Returns")
% legend('Location','southeast')
% 
% hold off

%% plot cumulativeSum graph
hold on

plot(BestDates, sum1Array, "DisplayName", "Efficient Portfolio");
plot(NaiveDates, sum2Array, "DisplayName", "1/N Portfolio");
title("Efficient vs 1/N Portfolio")
xlabel("Dates")
ylabel("Returns")
legend('Location','southeast')
hold off

%% Functions %%
function [DailyDates, DailyReturns] = getDailyReturns(p, Dates, Returns1, Returns2, Returns3)

DailyReturns = zeros(length(Returns1)-int16(length(Returns1)/2),1);
length(Returns1)
int16(length(Returns1))

for i = 2: length(Returns1)
    DailyDates(i) = Dates(i);
    DailyReturns(i) = p(1)*(Returns1(i)) + p(2)*(Returns2(i)) + p(3)*(Returns3(i));
    
end
end


function ReturnPortfolio = getBestPortfolio(Weights, Covariance, Mean_Vector)

Return = zeros(length(Weights),1);
Risk = zeros(length(Weights),1);

for i = 1:length(Weights)
    Return(i) = dot(Weights(i,:)', Mean_Vector);
    Risk(i) = sqrt(Weights(i,:)*Covariance*Weights(i,:)');
end

index = 0;
bestRatio = 0;
risk_free_rate = 0.03;

for i = 1:length(Return)
    if Return(i)/Risk(i) > bestRatio
        bestRatio = (Return(i) - risk_free_rate)/Risk(i);
        index = i;
    end
end

ReturnPortfolio = Weights(index,:);

end
