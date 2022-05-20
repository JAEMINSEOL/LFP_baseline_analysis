Initial_LFP
ROOT.fig = [ROOT.Save '\Plots\Phase\JSReplicate'];
ROOT.table = [ROOT.Save '\Tables\Phase\JSReplicate'];
Recording_region = readtable([ROOT.Info '\Recording_region.csv']);
RemapCellsList = load([ROOT.Save '\Tables\sorted_by_bootstrapping_fog.mat']);
Osc = 'theta';
UseJSRef = 1;
mod = 'winC';
Phase_summ = zeros(1,10);
Phase_summT = array2table(Phase_summ,'variablenames',{'CellID','Region','PreNumSpks','PreAngle','PreMRL','PreRayleighP',...
    'PostNumSpks','PostAngle','PostMRL','PostRayleighP'});

Cluster_List = readtable([ROOT.Info '\ClusterList.xlsx']);
load([ROOT.Save '\Tables\bootFog_Filtered.mat'])

ClusterList = [FilteredCA1', FilteredCA3']';

for cellRUN = 1 : size(ClusterList,1)
   
        thisCLUSTER = ClusterList{cellRUN};
        find_hypen = find(thisCLUSTER=='-');
        thisRID = thisCLUSTER(1:find_hypen(1)-1);
        thisSID = thisCLUSTER(find_hypen(1)+1:find_hypen(2)-1);
        thisTTID = thisCLUSTER(find_hypen(2)+1:find_hypen(3)-1);
        thisCLID = thisCLUSTER(find_hypen(3)+1:end);
        clusterID = [thisRID '-' thisSID '-' jmnum2str(str2double(thisTTID),2) '-' thisCLID];
        
        
        SpkPhase = load([ROOT.table '\' clusterID 'phase.mat']);
       if isempty(SpkPhase.Stdphasestats.r), SpkPhase.Stdphasestats.r=nan; end
       if isempty(SpkPhase.amb0phasestats.r), SpkPhase.amb0phasestats.r=nan; end
        
        
            if ismember(thisCLUSTER,RemapCellsList.grpCA1_ID), ReMap=1;
            elseif ismember(thisCLUSTER,RemapCellsList.(['stbCA1_ID'])), ReMap=0;
            else, ReMap = -1; end
            Phase_summT = [Phase_summT ; [{thisCLUSTER},{'CA1'},...
                SpkPhase.stdSpks,SpkPhase.Stdphasestats.m*180/pi,SpkPhase.Stdphasestats.r,SpkPhase.Stdphasestats.p,...
                SpkPhase.amb0Spks,SpkPhase.amb0phasestats.m*180/pi,SpkPhase.amb0phasestats.r,SpkPhase.amb0phasestats.p]];
            
       

end

%%

thisRegion = 'CA1';
rm = 'grp';

data0 =Phase_summT;
data0(1,:) = [];
% DPre = data.PreAngle(  data.PreNumSpks>=30 & data.PostNumSpks>=30);
% DPost = data.PostAngle( data.PostNumSpks>=30 & data.PreNumSpks>=30);
data = data0;
data.PreAngle(data0.PreRayleighP>0.05)=nan;
Grp = cellfun(@(x) find(strcmp(x,data.CellID)),RemapCellsList.([rm thisRegion '_ID']));
DPre = data.PreAngle(intersect(find( data.PreNumSpks>=30 & data.PostNumSpks>=30),Grp));
data = data0;
data.PostAngle(data0.PostRayleighP>0.05)=nan;
Grp = cellfun(@(x) find(strcmp(x,data.CellID)),RemapCellsList.([rm thisRegion '_ID']));
DPost = data.PostAngle(intersect(find(data.PostNumSpks>=30 & data.PreNumSpks>=30),Grp));



figure('position',[-1300,326,955,635]);

hax =  subplot(2,2,3);
histogram([DPre,DPre+360],'BinWidth',20,'Normalization','probability','facecolor','b')
title('pre-fog')
xlim([0 720])
ylim([0 0.125])
set(hax,'XTick',[0:180:720])
hold on;
plot([0:720],cos((pi/180*([0:720]+180)))*0.02+0.03,'color',[.7 .7 .7],'linewidth',2)
ylabel('probability'); xlabel('phase(deg)')
set(gca, 'fontsize',15,'fontweight','b')


hax =  subplot(2,2,4);
histogram([DPost,DPost+360],'BinWidth',20,'Normalization','probability','facecolor','r')
title('post-fog')
xlim([0 720])
ylim([0 0.125])
set(hax,'XTick',[0:180:720])
hold on;
plot([0:720],cos((pi/180*([0:720]+180)))*0.02+0.03,'color',[.7 .7 .7],'linewidth',2)
ylabel('probability'); xlabel('phase(deg)')
set(gca, 'fontsize',15,'fontweight','b')

Grp = cellfun(@(x) find(strcmp(x,data0.CellID)),RemapCellsList.([rm thisRegion '_ID']));
DPre = data0.PreAngle(intersect(find(data0.PreNumSpks>=30 & data0.PostNumSpks>=30),Grp));
DPost = data0.PostAngle(intersect(find(data0.PreNumSpks>=30 & data0.PostNumSpks>=30),Grp));

hax =  subplot(2,2,1);
r = circ_plot(deg2rad(DPre),'hist','b',20,true,true,'linewidth',4,'color','b');
hold on
r2 = circ_plot(deg2rad(DPost),'hist','r',20,true,true,'linewidth',4,'color','r');
h     = findall(gca,'type','text');
legit = {'0','90','180','270',''};
idx   = ~ismember(get(h,'string'),legit);
set(h(idx),'string','', 'fontsize',15,'fontweight','b')
set(h(~idx), 'fontsize',15,'fontweight','b')
if strcmp(rm,'stb')
    sgtitle([thisRegion ', stable(rate remapping) (Fog sessions)'], 'fontsize',15,'fontweight','b')
else
    sgtitle([thisRegion ', global remapping (Fog sessions)'], 'fontsize',15,'fontweight','b')
end
view([90 -90])

subplot(6,2,6)
m1 = circ_mean(deg2rad(DPre)); m2=circ_mean(deg2rad(DPost));
r1 = circ_r(deg2rad(DPre)); r2 = circ_r(deg2rad(DPost));

axis off
text(0,0,['MRL ' num2str(r1)],'color','b')
text(2,0,['MRL ' num2str(r2)],'color','r')
xlim([0 5])

subplot(6,2,4)
plot([0:720],cos((pi/180*([0:720]+180))),'color',[.7 .7 .7],'linewidth',2)
axis off
hold on
scatter(circ_rad2ang(m1)+360,cos((pi/180*(circ_rad2ang(m1)+360+180))),80,'b','filled')
scatter(circ_rad2ang(m2)+360,cos((pi/180*(circ_rad2ang(m2)+360+180))),80,'r','filled')
text(0,-1,'| 0', 'fontsize',15,'fontweight','b'); text(180,-1,'| 180', 'fontsize',15,'fontweight','b');
text(360,-1,'| 360', 'fontsize',15,'fontweight','b'); text(540,-1,'| 540', 'fontsize',15,'fontweight','b');
text(720,-1,'| 720', 'fontsize',15,'fontweight','b')

subplot(6,2,2)
axis off
Grp = cellfun(@(x) find(strcmp(x,data0.CellID)),RemapCellsList.([rm thisRegion '_ID']));
DPre = data0.PreAngle(intersect(find(data0.PreNumSpks>=30 & data0.PostNumSpks>=30),Grp));
DPost = data0.PostAngle(intersect(find(data0.PreNumSpks>=30 & data0.PostNumSpks>=30),Grp));
[p,h,stats] = signrank(DPre,DPost);
text(0,0,['p=' jjnum2str(p,3) ' (Wilcoxon signed-rank test)'], 'fontsize',12)

% DPre = data0.PreMRL(intersect(find(data0.PreRayleighP<=0.05 & data0.PreNumSpks>=30 & data0.PostNumSpks>=30),Grp));
% DPost = data0.PostMRL(intersect(find(data0.PostRayleighP<=0.05 & data0.PreNumSpks>=30 & data0.PostNumSpks>=30),Grp));
% [p,h,stats] = ranksum(DPre,DPost)
% [stdphasedistros,phasebins,ps]=CircularDistribution(circ_ang2rad(DPre),'nBins',20);
% [amb0phasedistros,phasebins,ps]=CircularDistribution(circ_ang2rad(DPost),'nBins',20);
% [h,p,stats] =  kstest2(stdphasedistros, amb0phasedistros)
