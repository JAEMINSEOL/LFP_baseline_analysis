
figure;
Y1 = cell2mat(skaggsMap1D(1,1))';
X2 = linspace(1,length(Y1),10000); 
X1=linspace(1,length(Y1),length(Y1));
Y2 = interp1(X1,Y1,X2); 
imagesc(Y2)
colormap(jet)
% axis equal 
colorbar;
axis off