Initial_LFP
ROOT.fig = [ROOT.Save '\Plots\Phase\JSReplicate'];
ROOT.table = [ROOT.Save '\Tables\Phase\JSReplicate'];
Recording_region = readtable([ROOT.Info '\Recording_region.csv']);
RemapCellsList = load([ROOT.Save '\Tables\sorted_by_bootstrapping_fog.mat']);
Osc = 'theta';
UseJSRef = 1;
mod = 'winC';
Phase_summ = nan(1,9);
Phase_summT = array2table(Phase_summ,'variablenames',{'CellID','Region','ReMap','PreNumSpks','PreAngle','PreRayleighP',...
    'PostNumSpks','PostAngle','PostRayleighP'});

Cluster_List = readtable([ROOT.Info '\ClusterList.xlsx']);

for cellRUN = 1 : size(Cluster_List,1)
    if strcmp(Cluster_List.experimenter{cellRUN},'JS') && strcmp(Cluster_List.session_type{cellRUN},'fog')
        try
            thisCLUSTER = Cluster_List.ID{cellRUN};
            find_hypen = find(thisCLUSTER=='-');
            thisRID = thisCLUSTER(1:find_hypen(1)-1);
            thisSID = thisCLUSTER(find_hypen(1)+1:find_hypen(2)-1);
            thisTTID = thisCLUSTER(find_hypen(2)+1:find_hypen(3)-1);
            thisCLID = thisCLUSTER(find_hypen(3)+1:end);
            clusterID = [thisRID '-' thisSID '-' num2str(str2double(thisTTID)) '-' thisCLID];
            
            thisRegion = Recording_region.(['TT' num2str(str2double(thisTTID))]){strcmp(Recording_region.SessionID,[thisRID '-' thisSID])};
            if strncmp(thisRegion, 'CA3',3) && length(thisRegion)<6, thisRegion2 = 'CA3'; else, thisRegion2 = thisRegion; end
         if strncmp(thisRegion, 'CA1',3), thisRegion2 = 'CA1'; end
            
            SpkPhase = load([ROOT.table '\' thisCLUSTER 'phase.mat']);
            if (SpkPhase.stdSpks>=30 || SpkPhase.amb0Spks>= 30)
                if ismember(clusterID,RemapCellsList.(['grp' thisRegion2 '_ID'])), ReMap=1;
                elseif ismember(clusterID,RemapCellsList.(['stb' thisRegion2 '_ID'])), ReMap=0; 
                else, ReMap = -1; end
                Phase_summT = [Phase_summT ; {clusterID,thisRegion,ReMap,...
                    SpkPhase.stdSpks,SpkPhase.Stdphasestats.m*180/pi,SpkPhase.Stdphasestats.p,...
                    SpkPhase.amb0Spks,SpkPhase.amb0phasestats.m*180/pi,SpkPhase.amb0phasestats.p}];
            
            end
    end
    end
end

%%
figure('position',[-1300,326,955,635]);
data =Phase_summT( strncmp(Phase_summT.Region,'CA1',3)& Phase_summT.ReMap==1,:);

hax =  subplot(2,2,1);

r = circ_plot(circ_ang2rad(data.PreAngle(data.PreRayleighP<0.05)),'hist','b',20,true,true,'linewidth',2,'color','b');

hold on
r2 = circ_plot(circ_ang2rad(data.PostAngle(data.PostRayleighP<0.05)),'hist','r',20,true,true,'linewidth',2,'color','r');

h     = findall(gca,'type','text');
legit = {'0','90','180','270',''};
idx   = ~ismember(get(h,'string'),legit);
set(h(idx),'string','')
title(['CA1, remapping'])
set(gca, 'fontsize',12,'fontweight','b')


hax =  subplot(2,2,3);
[amb0phasedistros,phasebins,ps]=CircularDistribution(data.PreAngle(data.PreRayleighP<0.05)*pi/180,'nBins',20);
% histogram([data.PreAngle(data.PreRayleighP<0.05),data.PreAngle(data.PreRayleighP<0.05)+360],'NumBins',40)
% hax =  subplot(2,2,4);
bar([(phasebins*180/pi)' ((phasebins*180/pi)+360)'],[amb0phasedistros' amb0phasedistros'],'b')
title('pre-fog')
xlim([0 720])
set(hax,'XTick',[0 90 180 270 360 450 540 630 720])
hold on;
plot([0:720],cos((pi/180*([0:720]+180)))*0.25*max(amb0phasedistros)+0.5*max(amb0phasedistros),'color',[.7 .7 .7],'linewidth',2)
ylim([0 max(amb0phasedistros)*1.2]); ylabel('proportion'); xlabel('phase(deg)')
set(gca, 'fontsize',12,'fontweight','b')
m1 = ps.m;

hax =  subplot(2,2,4);
[amb0phasedistros,phasebins,ps]=CircularDistribution(circ_ang2rad(data.PostAngle(data.PostRayleighP<0.05)),'nBins',20);
bar([(phasebins*180/pi)' ((phasebins*180/pi)+360)'],[amb0phasedistros' amb0phasedistros'],'r')
title('post-fog')
xlim([0 720])
set(hax,'XTick',[0 90 180 270 360 450 540 630 720])
hold on;
plot([0:720],cos((pi/180*([0:720]+180)))*0.25*max(amb0phasedistros)+0.5*max(amb0phasedistros),'color',[.7 .7 .7],'linewidth',2)
ylim([0 max(amb0phasedistros)*1.2]); ylabel('proportion'); xlabel('phase(deg)')
set(gca, 'fontsize',12,'fontweight','b')
m2 = ps.m;

subplot(6,2,4)
plot([0:720],cos((pi/180*([0:720]+180))),'color',[.7 .7 .7],'linewidth',2)
axis off
hold on
scatter(circ_rad2ang(m1)+360,cos((pi/180*(circ_rad2ang(m1)+360+180))),40,'b','filled')
scatter(circ_rad2ang(m2)+360,cos((pi/180*(circ_rad2ang(m2)+360+180))),40,'r','filled')
text(0,-1,'| 0'); text(180,-1,'| 180'); text(360,-1,'| 360','fontweight','b'); text(540,-1,'| 540'); text(720,-1,'| 720')
set(gca, 'fontsize',12,'fontweight','b')


%%

