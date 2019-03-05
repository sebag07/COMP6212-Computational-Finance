%% Read from files %%
files = dir('cleared/*.csv');

FolderName = 'cleared/';

N = 30;

Returns = zeros(758, N);

% Fill Returns and Dates Map
for i=1:N
    FileName = files(i).name;
    [Dates, Return] = readStock(strcat(FolderName,FileName));
    Returns(:,i) = Return;
end

% Get Dates and Returns for FTSE Index
% [Dates,Returns] = indexTracker(MyDatesMap, MyReturnsMap, files);
[DatesFTSE, ReturnsFTSE] = readStock('cleared/FTSE.csv');

%% Sparse Portfolio %%

tic
disp('Start lasso')
tau = 0.06;
weightsSparse = getSparsePortfolio(ReturnsFTSE, Returns, tau);
weightsSparse = round(weightsSparse*10000)/sum(round(weightsSparse*10000))
numFeatures = nnz(weightsSparse);
selectedSparse = find(weightsSparse);

toc

dailyReturns = getDailyReturns(weightsSparse, Returns);

sparseSum = cumulativeSum(dailyReturns);
FTSEsum = cumulativeSum(ReturnsFTSE);

err = immse(FTSEsum, sparseSum)

plot(Dates, sum1Array)

%% Function

function dailyReturns = getDailyReturns(weights, Returns)

N = size(Returns);
dailyReturns = zeros(N(1),1);

for i=1:N(1)
    dailyReturns(i) = dot(weights, Returns(i,:));
end

end

function w = getSparsePortfolio(ReturnsFTSE, Returns, tau)

cvx_begin quiet
variable w(30,1)
    minimize(square_pos(norm(ReturnsFTSE - Returns * w)) + tau * norm(w, 1));
cvx_end

end

function[Dates, Returns] = readStock(fileName)

options = detectImportOptions(fileName);
T = readtable(fileName, options);
Dates = T(:,1);
Values = T(:,2);
Dates = table2array(Dates);
Values = table2array(Values);

ValuesArray = Values;

Returns = zeros(size(ValuesArray));

for value = 2:size(ValuesArray)
        Returns(value, :) = (ValuesArray(value, :) / ValuesArray(value-1, :))-1;
end

end