m = [0.10 0.20 0.15]
C = [0.005 -0.010 0.004; 
    -0.010 0.040 -0.002; 
     0.004 -0.002 0.023]

p = Portfolio;
p = setAssetMoments(p, m, C);
p = setDefaultConstraints(p);

N = 1000;

weights = randfixedsum(3,N, 1, 0, 1)

[PortfolioRisk, PortfolioReturn] = portstats(m, C, weights');

M = weights' * m';

V = weights' * C * weights;
 
hold on
tic
for i =1:N
   scatter(M(i), V(i,i), 25, '.r')
end
title('(E,V) combinations')
xlabel('E (Mean)')
ylabel('V (Variance)')
toc
hold off



% Plot the efficient frontier for the three assets and the 100 points
% figure
% hold on
% p.plotFrontier;
% plot(PortfolioRisk, PortfolioReturn, '.r')
% title('Efficient Frontier - Three Assets')
% hold off

