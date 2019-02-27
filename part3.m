m = [0.10 0.20 0.15]
C = [0.005 -0.010 0.004; 
    -0.010 0.040 -0.002; 
     0.004 -0.002 0.023];
 
 [PRisk, PRoR, PWts] = NaiveMV(m, C, 50)
 [PRisk2, PRoR2, PWts2] = ConvexMV(m, C, 50)
 
 hold on
 plot(PRisk, PRoR, 'b')
 plot(PRisk2, PRoR2, 'r')
 hold off