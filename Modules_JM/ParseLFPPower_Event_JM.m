function [Selected,VMMean] = ParseLFPPower_Event_JM(PMean,TTNum,sessionID)
Selected = nan(size(PMean,1),7,4);

for k=1:size(PMean,3)
    if ~isempty(find(TTNum(:,3)==k))
        r = TTNum(find(TTNum(:,3)==k),2);
        %%
                    thisRegion =  Region_Index2Name_JM(r);
                    cd('D:\HPC-LFP project\SpeedAnalysis')
                    load(['MeanVelocity' sessionID '-' thisRegion '.mat']);

        
        %%
        for j=1:7
            Selected(:,j,r)= PMean(:,j+1,k)/mean(PMean(:,end,k));
             VMMean(:,j,r) = VMean(:,j+1,k);
        end
    end
end