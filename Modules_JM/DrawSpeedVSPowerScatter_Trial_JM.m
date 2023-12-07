function DrawSpeedVSPowerScatter_Trial_JM(x,y,thisRID,thisSID,Color_Array)
l = min(size(x,1),size(y,1));
for r=1:4
    if size(x,3)>=r
        if max(max(x(:,:,r)))~=0
            f = figure('Position',[100 100 600 600]);
            RegionIndex = Region_Index2Name_JM(r);
            for j=3:4
                x1 = x(1:l,j,r); y1= y(1:l,j,r);
                p(j)=scatter(x1,y1,30,hex2rgb(Color_Array(j-1)),'filled');
% if j==3 c=autumn(length(x1)); else c=winter(length(x1)); end
% p(j)=scatter(x1,y1,30,c,'filled');
                hold on

            end
            
            for j = 3:4
                x1 = x(1:l,j,r); y1= y(1:l,j,r);
                                % Fit linear regression line with OLS.
                b = [ones(size(x1,1),1) x1]\y1;
                % Use estimated slope and intercept to create regression line.
                RegressionLine = [ones(size(x1,1),1) x1]*b;
                q(j)=plot(x1,RegressionLine,'Color',hex2rgb(Color_Array(j-1))*0.4);
                
                % RMSE between regression line and y
                RMSE = sqrt(mean((y1-RegressionLine).^2));
                % R2 between regression line and y
                SS_X = sum((RegressionLine-mean(RegressionLine)).^2);
                SS_Y = sum((y1-mean(y1)).^2);
                SS_XY = sum((RegressionLine-mean(RegressionLine)).*(y1-mean(y1)));
                R_squared = SS_XY/sqrt(SS_X*SS_Y);
                text(mean(x1),mean(y1),sprintf('RMSE: %0.2f | R^2: %0.2f\n',RMSE,R_squared),'Color',hex2rgb(Color_Array(j-1))*0.4,'FontWeight','b');
                
            end
            xlabel('Velocity(cm/s)'); xlim([0.1 (nanmean(x(1:l,3:4,r),'all')+2*max(nanstd(x(1:l,3:4,r))))*1.1])
            ylabel('Normalized Theta Band Power'); ylim([0.1 (nanmean(y(1:l,3:4,r),'all')+2*max(nanstd(y(1:l,3:4,r))))*1.1])
            set(gca,'FontSize',15,'FontWeight','b')
            legend([p(3), p(4)],{'s1-s2','s2-s3'},'Location','northoutside','NumColumns',2)
            title(['Norm. TBP.Rat ' thisRID '-' thisSID '(' RegionIndex ')'])
           saveImage(f,[thisRID '-' thisSID '-' RegionIndex '_Speed_vs_Power.jpg'],'pixels',[100 100 600 600])
        end
    end
end