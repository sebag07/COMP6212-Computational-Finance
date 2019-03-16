m = [0.10 0.20 0.15]
C = [0.005 -0.010 0.004; 
    -0.010 0.040 -0.002; 
     0.004 -0.002 0.023]

p = Portfolio;
p = setAssetMoments(p, m, C);
p = setDefaultConstraints(p);

% Assets 1 and 2
m1 = [0.10 0.20]
C1 = [0.005 -0.010; 
     -0.010 0.040]

p1 = Portfolio;
p1 = setAssetMoments(p1, m1, C1);
p1 = setDefaultConstraints(p1);

% Assets 2 and 3
m2 = [0.20 0.15]
C2 = [0.040 -0.002; 
     -0.002 0.023]
 
p2 = Portfolio;
p2 = setAssetMoments(p2, m2, C2);
p2 = setDefaultConstraints(p2);
 
%  Assets 1 and 3
m3 = [0.10 0.15]
C3 = [0.005 0.004;
      0.004 0.023]

p3 = Portfolio;
p3 = setAssetMoments(p3, m3, C3);
p3 = setDefaultConstraints(p3);

weights = randfixedsum(2,100, 1, 0, 1)

[PortfolioRisk, PortfolioReturn] = portstats(m1, C1, weights');


% % % Plot the efficient frontier for the three assets and the 100 points
% % hold on
% % plotFrontier(p, 100)
% % plot(PortfolioRisk, PortfolioReturn, '.r')
% % title('Efficient Frontier - Three Assets')
% % hold off

hold on
% plotFrontier(p,100)
plotFrontier(p1, 100)
% plotFrontier(p2, 100)
% plotFrontier(p3, 100)
plot(PortfolioRisk, PortfolioReturn, '.r')
title('Efficient Frontier - Assets 1 and 2')
hold off
