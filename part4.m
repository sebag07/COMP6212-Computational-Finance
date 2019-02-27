[RB_Dates, RB_Returns] = readStock("data/RB.csv");
[TSCO_Dates, TSCO_Returns] = readStock("data/TSCO.csv");
[CPG_Dates, CPG_Returns] = readStock("data/CPG.csv");

half = size(RB_Returns) / 2 ;

Half_Dates = RB_Dates(1:half);
Half_RB_Returns = RB_Returns(1:half);
Half_TSCO_Returns = TSCO_Returns(1:half);
Half_CPG_Returns = CPG_Returns(1:half);

RB_MeanReturn = mean(Half_RB_Returns);
TSCO_MeanReturn = mean(Half_TSCO_Returns);
CPG_MeanReturn = mean(Half_CPG_Returns);

Mean_Vector = [RB_MeanReturn TSCO_MeanReturn CPG_MeanReturn];

ConcatenatedStocks = horzcat(Half_RB_Returns, Half_TSCO_Returns, Half_CPG_Returns);

C = cov(ConcatenatedStocks);

[NRet, NRisk, RWts] = NaiveMV(Mean_Vector, C, 1000);

BestPortfolio = getBestPortfolio(RWts, C, Mean_Vector);
One_Over_N = [(1/3) (1/3) (1/3)];

[BestDates, BestReturns] = getDailyReturns(BestPortfolio, Half_Dates, Half_RB_Returns, Half_TSCO_Returns, Half_CPG_Returns);
[NaiveDates, NaiveReturns] = getDailyReturns(One_Over_N, Half_Dates, Half_RB_Returns, Half_TSCO_Returns, Half_CPG_Returns);

bestMean = mean(BestReturns);
naiveMean = mean(NaiveReturns);

hold on
plot(BestDates, BestReturns, "DisplayName", "Efficient Portfolio");
plot(NaiveDates, NaiveReturns, "DisplayName", "1/N Portfolio");
title("Efficient vs 1/N Portfolio")
legend('Location', 'southeast')
hold off



function [DailyDates, DailyReturns] = getDailyReturns(p, Dates, Returns1, Returns2, Returns3)

DailyReturns = zeros(length(Returns1)-int16(length(Returns1)/2)+1,1);
length(Returns1)
int16(length(Returns1))

for i = int16(length(Returns1)/2)+1: length(Returns1)
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

for i = 1:length(Return)
    if Return(i)/Risk(i) > bestRatio
        bestRatio = Return(i)/Risk(i);
        index = i;
    end
end

ReturnPortfolio = Weights(index,:);

end

function[Dates, Returns] = readStock(fileName)

options = detectImportOptions(fileName);
T = readtable(fileName, options);
Dates = T.Date;
Values = T.AdjClose;

ValuesArray = Values;

Returns = zeros(length(ValuesArray),1);

for value = 2:length(ValuesArray)
    Returns(value) = (ValuesArray(value) / ValuesArray(value-1))-1;
end

end