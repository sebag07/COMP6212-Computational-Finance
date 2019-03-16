m = [0.10 0.20 0.15]
C = [0.005 -0.010 0.004; 
    -0.010 0.040 -0.002; 
     0.004 -0.002 0.023];
 
[PRisk, PRoR, PWts] = NaiveMV2(m, C, 1000)
% [PRisk2, PRoR2, PWts2] = NaiveMV(m, C, 50)
 
p = Portfolio;
p = setAssetMoments(p, m, C);
p = setDefaultConstraints(p);

N = 100;

weights = randfixedsum(3,N, 1, 0, 1);

[PortfolioRisk, PortfolioReturn] = portstats(m, C, weights');

hold on
plot(PRisk, PRoR, 'b','LineWidth',2)
% plot(PRisk2, PRoR2, 'g','LineWidth',2)
% plot(PortfolioRisk, PortfolioReturn, '.r')
% legend('Linprog and Quadprog','CVX Programming', 'Portfolios')
hold off