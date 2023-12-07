function DrawCompLFPPower_JM(TTBox)
f=figure('Position',[100 100 1000 700]);
for i=1:4
    RegionIndex = Region_Index2Name_JM(i);
subplot(2,2,i)
n=sum(~isnan(TTBox.Event(:,1,i)));
m = squeeze(nanmean(TTBox.Event(:,:,i),1));
se = squeeze(nanstd(TTBox.Event(:,:,i),1))/sqrt(n);
% boxplot(TTBox.Event(:,:,i))
errorbar(m,se,'MarkerSize',40,'LineWidth',1.5)
xlim([0.5 7.5]); xticks([0.5:1:7.5])
xticklabels({'-500ms','Start','S1','S2','S3','DivPnt','FW','End'});
xlabel('Period')
ylabel('Normalized Theta Band Power')
title(['Normalized Theta Band Power (' RegionIndex '), n=' num2str(n)])
end
saveImage(f,'Normalized Theta Band Power_Events.jpg','pixels',[100 100 1000 700])
% 
% figure;
% boxplot(TTBox.Region)
% xticks([1 2 3 4])
% xticklabels({'SUB','CA1','CA3','CA3(DG lesioned)'});
% xlabel('Target Region')
% ylabel('Normalized Theta Band Power')
% title('Normalized Theta Band Power')
% figure;
% boxplot(TTBox.Session)
% xticks([1 2])
% xticklabels({'STD','AMB'});
% xlabel('Session Type')
% ylabel('Normalized Theta Band Power')
% title('Normalized Theta Band Power')
% figure;
% boxplot(TTBox.Rat)
% xticklabels(RATLIST);
% xlabel('Rat Number')
% ylabel('Normalized Theta Band Power')
% title('Normalized Theta Band Power')