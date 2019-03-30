rng(1000)
[callData, txt1, raw1] = xlsread("Data/FTSEOptionsData",1);
[pullData, txt2, raw2] = xlsread("Data/FTSEOptionsData",2);
[FTSEData, txt3, raw3] = xlsread("Data/FTSEOptionsData",3);

data = raw1(1,:);
data(1)= []; 
data = str2double(extractAfter(data,"JAN19"));

folderPath = '/home/cniculae/Options/';
ftse = FTSEData(:,2:3);
ftse_log_ret = tick2ret(ftse(:,1));

day_of_trading = 253;
alpha = 274;
T = 274;
q = ceil(T/4);
range = q+1:T-1;
i = 52;

callOption = zeros(T-q,1);
K = 6350;
X = zeros(T-q, 2);
for t=q+1:T
%     vol = std(ftse_log_ret(t-q:t-1))/sqrt(q/alpha);
    vol = blsimpv(ftse(t,1),data(i),ftse(t,2)/100,(T-t + 1)/alpha,callData(t,i+1));
    if(isnan(vol))
        vol = std(ftse_log_ret(t-q:t-1))/sqrt(q/alpha);
    end
    [a,b] = blsprice(ftse(t,1),K,ftse(t,2)/100,(T-t+1)/alpha,vol);
    
    callOption(t-q) = a;
    X(t-q,1) = ftse(t,1)/K;
    X(t-q,2) = (T-t+1)/alpha;
end

global trainingX trainingY testingX testingY;
XN = size(X(:,1),1);
trainingSplit = 0.8;
trainingRange = 1:ceil(XN*trainingSplit);
testingRange = ceil(XN*trainingSplit)+1:XN;

volat = zeros(size(ftse,1), 1);
alpha_prim = size(ftse,1);

for t = q+1:T
    disp(t)
    %volat(t) = blsimpv(ftse(t,1),K,ftse(t,2)/100,(T-t + 1)/alpha,callOption(t-q));
    volat(t) = std(ftse_log_ret(t-q:t-1))/sqrt(q/alpha_prim); 
end

trainingX = X(trainingRange,:);
trainingY = callOption(trainingRange,:);

testingX = X(testingRange,:);
testingY = callOption(testingRange,:);

% net = newrb(trainingX',trainingY');

% solution = sim(net,testingX');
% hold off;
% plot(solution);
% hold on;
% plot(testingY);

% plot(solution)
% plot(callData(testingRange,3))
%solution = solution';

%by me

options = statset('MaxIter',500000);
GMModel = fitgmdist(X,4,'Options',options);

global mean sigma designMatrix;
mean = GMModel.mu;
sigma = GMModel.Sigma;
siginv = zeros(2,2,4);

for i =1:4
    sigCurrent = sigma(:,:,i);
    sigCurrent = inv(sigCurrent);
    
    siginv(:,:,i) = sigCurrent;
end

designMatrixCol = 7;
designMatrix = zeros(size(trainingX, 1), designMatrixCol);

for i=1:size(trainingX,1)
    for j = 1:4
        designMatrix(i,j) = mahalanobisDistance(trainingX(i,:),mean(j),sigma(j));
    end
    
    designMatrix(i,5) = trainingX(i,1);
    designMatrix(i,6) = trainingX(i,2);
    designMatrix(i,7) = 1;
end

x0 = pinv(designMatrix) * trainingY;
x =x0;
% options = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',5000000, 'MaxIterations', 1000000);
% x = x0;
% x = lsqnonlin(@func,x0,[],[],options);
% disp(x);

designMatrixTest = zeros(size(testingX, 1), designMatrixCol);

for i=1:size(testingX,1)
    for j = 1:4
        designMatrixTest(i,j) = mahalanobisDistance(testingX(i,:),mean(j),sigma(j));
    end
    
    designMatrixTest(i,5) = testingX(i,1);
    designMatrixTest(i,6) = testingX(i,2);
    designMatrixTest(i,7) = 1;
end

plot(designMatrixTest * x);
hold on;
plot(testingY);
figure()
plot(designMatrixTest * x);
hold on;
plot(callData(size(callData,1) - size(testingX):size(callData,1)-1,15));
figure();

syms KStrike real 
syms x2 real 
syms S real
syms sig1 real 
syms sig2 real 
syms sig3 real 
syms sig4 real
syms miu1 real 
syms miu2 real 
syms const real
syms f(S, KStrike, x2, sig1,sig2,sig4,miu1,miu2) 

f(S, KStrike, x2, sig1,sig2,sig4,miu1,miu2) = ((([S/KStrike, x2]-[miu1, miu2])*([sig1,sig2;sig2,sig4])*([S/KStrike, x2]-[miu1, miu2])').^(1/2));

f_prim(S, KStrike, x2, sig1,sig2,sig4,miu1,miu2) = diff(f, S);
% 
% syms f(S, KStrike, x2, sig1,sig2,sig3,sig4,miu1,miu2) 
% 
% f(S, KStrike, x2, sig1,sig2,sig3,sig4,miu1,miu2) = ((([S/KStrike, x2]-[miu1, miu2])*inv([sig1,sig2;sig3,sig4])*([S/KStrike, x2]-[miu1, miu2])')^(1/2));
% 
% f_prim(S, KStrike, x2, sig1,sig2,sig3,sig4,miu1,miu2) = diff(f(S, KStrike, x2, sig1,sig2,sig3,sig4,miu1,miu2), S);

hedge_ratio = zeros(size(testingX,1),1);
hedge_ratio_test = zeros(size(testingX,1),1);

ftse_test = ftse(testingRange,1);
r_test = ftse(testingRange,2);


for i = 1:size(testingX,1)
    current = 0;
    for j = 1:4
        current = current + x(j) * eval(f_prim(ftse_test(i,1), K, testingX(i,2), siginv(1,1,j), siginv(1,2,j), siginv(2,2,j), mean(j,1), mean(j,2)));
    end
    hedge_ratio(i,1) = (current + x(5)/K)/100000;
    disp(hedge_ratio(i,1));

    [a] = blsdelta(ftse_test(i,1), K, r_test(i,1), volat(i+size(trainingX,1),1), T, size(trainingX,1)+i);
    disp(a);
    hedge_ratio_test(i) = a;
end

plot(hedge_ratio);
hold on;
plot(hedge_ratio_test);

function [result] = func(input)
    global designMatrix trainingY;
    result = sum((designMatrix * input - trainingY).^2);
    %result = designMatrix * input - trainingY;
    disp(result)
end

% strike = 4000;
% rate = 0.02;
% [ftse, ~, ~] = xlsread("Data/FTSEOptionsData",3);
% T = 275;
% window = ceil(T / 4);
% 
% dataset = NaN(T, 1);
% 
% ttm = NaN(T, 1);
% input = zeros(205, 2);
% 
% for t=window + 1:T
%     vol = standard_volatility(ftse(t - window: t - 1, 2));
% %     get FTSE data for more than 275
% %     timeToMaturity = (252 - mod(t, 252)) / 252;
%     timeToMaturity = (T - t) / 252;
%     [c, ~] = blsprice(ftse(t,2), strike, ftse(t,3) / 100, timeToMaturity, vol);
%     input(t  - window, 2) = T-t;
%     dataset(t) = c;
%     ttm(t) = timeToMaturity;
% end
% 
% ftseInput = ftse(window + 1:T,2); 
% input(1:T-window, 1) = ftseInput(:, 1);
% output = dataset(window + 1:T, :);
% 
% 
% trainingRange = (T - window) * 0.80;
% TrainingX = input(1:trainingRange, 1:2);
% TestingX = input(trainingRange:T-window, 1:2);
% TrainingY = dataset(1:trainingRange, 1);
% %% RBF MODEL
% net = newrb(TrainingX', TrainingY', 0.25, 5);
% 
% result = net(TestingX');
% 
% figure
% plot(window + 1:T, dataset(window + 1:T), '+');
% hold on
% plot(window + 1:T, result)
% hold off
% 
% % range = window + 1 : T;
% % ftse_normalised = TrainingX((T-window) - trainingRange:end, 1) / strike;
% % 
% % figure
% % scatter3(ttm(range), ftse_normalised, result', 'filled')
% 
% % figure
% 
% 
% %% Gaussian Mixture model
% model = fitgmdist(output, 4)