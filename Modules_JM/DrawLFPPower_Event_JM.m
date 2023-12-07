function DrawLFPPower_Event_JM(PMean,TTNum,ssnum_p,MaxSSNum,session_id,period)
s=1;
pi=period(1); pe=period(2);
PLabel = {'-500ms','Start','S1','S2','S3','DivPnt','FW','End'};
for k=1:size(PMean,3)
    if ~isempty(find(TTNum(:,3)==k))

        r = TTNum(find(TTNum(:,3)==k),2);
                    
        
        
                subplot(MaxSSNum,3,(ssnum_p-1)*3+s)
        RegionIndex = Region_Index2Name_JM(r);
        n=sum(~isnan(PMean(:,1,k)));
        m = squeeze(nanmean(PMean(:,2:8,k)/mean(PMean(:,end,k)),1));
        se = squeeze(nanstd(PMean(:,2:8,k)/mean(PMean(:,end,k)),1))/sqrt(n);
        % boxplot(TTBox.Event(:,:,i))
        errorbar(m,se,'MarkerSize',40,'LineWidth',1.5)
        
        xlim([pi pe+1]); xticks([0.5:1: 7.5])
        xticklabels(PLabel);
        ylim([0 max(2,floor(max(m(pi+1:pe)))+1)])
        xlabel('Period')
        ylabel('Norm. TBP')
        title(['Norm. TBP (' session_id ',' RegionIndex '), n=' num2str(n)])
        
        
        subplot(MaxSSNum,3,(ssnum_p-1)*3+3)
                load(['MeanVelocity' session_id '-' RegionIndex '.mat']);
        mv = squeeze(nanmean(VMean(:,2:8,k)));
        sev = squeeze(nanstd(VMean(:,2:8,k)));
        errorbar(mv,sev,'MarkerSize',40,'Color','r','LineWidth',1.5)
                xlim([pi pe+1]); xticks([0.5:1: 7.5])
        xticklabels(PLabel);
         ylim([0 70])
        xlabel('Period')
        ylabel('Velocity(cm/s)')
        title(['Mean veolocity (' session_id  '), n=' num2str(n)])
        
        s=s+1;
    end
end
end