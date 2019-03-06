%% Read from files %%
files = dir('cleared/*.L.csv');

FolderName = 'cleared/';

MyReturnsMap = containers.Map();
MyDatesMap = containers.Map();

N = length(files);

files(1)

Returns = zeros(758, N);

% Fill Returns and Dates Map
for i=1:N
    FileName = files(i).name;
    [Dates, Return] = readStock(strcat(FolderName,FileName));
    Returns(:,i) = Return;
end

% Get Dates and Returns for FTSE Index
% [Dates,Returns] = indexTracker(MyDatesMap, MyReturnsMap, files);
[DatesFTSE, ReturnsFTSE] = readStock('cleared/FTSE.csv')

%% Greedy Forward Selection %%
%Greedy Forward Selection of 6 assets
indexMap = greedySelection(ReturnsFTSE, Returns);

MeanSquareList = zeros(6,1);

sumFTSE = cumulativeSum(ReturnsFTSE);

sumGreedy = zeros(758, 6);

for i = 1 : length(indexMap)
    sumGreedy(:,i) = cumulativeSum(Returns(:,indexMap(i)));
end

sumG = sum(sumGreedy,2) / 6

hold on
plot(Dates,sumFTSE, 'DisplayName','FTSE');
% for i = 1:6
%     sumArray = cumulativeSum(Returns(:,indexMap(i)));
%    plot(Dates, sumArray, 'DisplayName', files(indexMap(i)).name) ;
% end
plot(Dates,sumG,'DisplayName','Greedy')
plot(Dates, sparseSum, 'DisplayName', 'Sparse')
legend('Location','southeast', 'FontSize', 6)
xlabel('Dates')
ylabel('Return')
title('Index Tracking - Greedy and Sparse Selection')

hold off

errMSE = immse(sumFTSE, sumG)
