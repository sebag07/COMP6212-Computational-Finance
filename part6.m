files = dir('stocks/*.L.csv');

FolderName = 'stocks/';

MyReturnsMap = containers.Map();
MyDatesMap = containers.Map();

N = length(files);

files(1)

% Fill Returns and Dates Map
for i=1:N
    FileName = files(i).name;
    [Dates, Returns] = readStock(strcat(FolderName,FileName));
    MyReturnsMap(FileName)= Returns;
    MyDatesMap(FileName)= Dates;
end

% Get Dates and Returns for FTSE Index
% [Dates,Returns] = indexTracker(MyDatesMap, MyReturnsMap, files);
[Dates, Returns] = readStock('stocks/FTSE.csv')


%Greedy Forward Selection of 6 assets
GreedyMap = greedySelection(Returns, MyReturnsMap, files);
BestSix = containers.Map();
for i=1:6
    SmallestDifference = 99999;
    SmallestRef = '';
    k = keys(GreedyMap)
    for j = k
        j
        FileName = j{1};
        Difference = GreedyMap(FileName);
        Mean = mean(Difference);
        if Mean < SmallestDifference
            SmallestDifference = Mean;
            SmallestRef = FileName;
        end
    end
    
    BestSix(SmallestRef) = SmallestDifference;
    remove(GreedyMap,SmallestRef);
end

MeanSquareList = zeros(6,1);
hold on
plot(Dates,Returns, 'DisplayName','FTSE30');

count = 1;
for i=keys(BestSix)
    FileName = i{1};
    plot(MyDatesMap(FileName),MyReturnsMap(FileName), 'DisplayName',FileName);
    MeanSquareList(count) = immse(MyReturnsMap(FileName), Returns);
    count = count +1;
end
legend('Location','southeast')
title('Index Tracking - Greedy Forward Selection')

hold off

MeanSquareGreedy = mean(MeanSquareList);

%How to read a map
%K = MyReturnsMap(files(1).name);