
clear; clc; close all;
warning off

%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
DatROOT.parsed = [MotherROOT '\Parsed Data'];
SaveROOT.mat = [DatROOT.parsed '\Theta phase\mat files (new ref)'];
[ClusterTable] = readtable([InfoROOT '\ClusterList_20201120.xlsx']);
%%
clear UnitList_temp
UnitList=table;
%%
i=1; j2=1; j=1;
while i<length(ClusterTable.UnitID)
    k=1;
    if j>length(ClusterTable.UnitID), continue; end
    j2=j;
    UnitList_temp(k,:) = ClusterTable(j,:);
    try
        while strcmp(ClusterTable.UnitID{j},ClusterTable.UnitID{j+1})
            if j>=length(ClusterTable.UnitID), continue; end
            UnitList_temp(k+1,:) = ClusterTable(j+1,:);
            k=k+1; j=j+1;
        end
    end
    UnitList.UnitID(i) = UnitList_temp{1,1};
    UnitList.Region{i} = UnitList_temp.Region{1,1};
    UnitList.MaxCluster(i) = sum(UnitList_temp.Filter & (UnitList_temp.Nspikes>=50));
    UnitList.NumTPP(i) = sum(UnitList_temp.TPPCluster);
    ClusterTable.FieldCount(j2:j)=UnitList.MaxCluster(i);
    
    clear UnitList_temp
    j=j+1; i=i+1;
end

%%

RegionList = {'SUB','CA1','CA3','CA3_DG'};
for i=1:4
    ProportionOfFields.(RegionList{i})(1,1) = length(find(strcmp(UnitList.Region,RegionList(i)) & UnitList.MaxCluster==1 & UnitList.NumTPP));
    ProportionOfFields.(RegionList{i})(1,2) = length(find(strcmp(UnitList.Region,RegionList(i)) & UnitList.MaxCluster>1 & UnitList.NumTPP));
    ProportionOfFields.(RegionList{i})(2,1) = length(find(strcmp(UnitList.Region,RegionList(i)) & UnitList.MaxCluster==1 & ~UnitList.NumTPP));
    ProportionOfFields.(RegionList{i})(2,2) = length(find(strcmp(UnitList.Region,RegionList(i)) & UnitList.MaxCluster>1 & ~UnitList.NumTPP));
end


%%
% LesionList = {'425','454','471','553'};
% for i=1:size(UnitList,1)
%     if ismember(UnitList.UnitID{i}(1:3),LesionList)
%         UnitList.Region(i) = {'CA3_DG'};
%     end
% end
%%
Phase_box = NaN(1000,6);
for i=1:3
    id = find(strcmp(ClusterTable.Region,RegionList(i)) & ClusterTable.FieldCount==1 & ClusterTable.TPPCluster);
    Phase_box(1:length(id),2*i-1) = ClusterTable.phase_start(id);
    
    id = find(strcmp(ClusterTable.Region,RegionList(i)) & ClusterTable.FieldCount>1 & ClusterTable.TPPCluster);
    Phase_box(1:length(id),2*i) = ClusterTable.phase_start(id);
end
Phase_box = wrapTo180(Phase_box)+90;

boxplot(Phase_box)
ylim([-90 270]); yticks([-90:90:270]); ylabel('Initial Theta Phase (deg)')
xticklabels({'SUB,SF','SUB,MF','CA1,SF','CA1,MF','CA3,SF','CA3,MF'})

%%
Phase_box = NaN(1000,6);
for i=1:3
    id = find(strcmp(ClusterTable.Region,RegionList(i)) & ClusterTable.FieldCount==1 & ClusterTable.TPPCluster);
    Phase_box(1:length(id),2*i-1) = ClusterTable.slope(id);
    
    id = find(strcmp(ClusterTable.Region,RegionList(i)) & ClusterTable.FieldCount>1 & ClusterTable.TPPCluster);
    Phase_box(1:length(id),2*i) = ClusterTable.slope(id);
end
Phase_box = Phase_box*(-10);
Phase_box(Phase_box>0) = NaN;
boxplot(Phase_box)
ylabel('TPP Slope(deg/cm)')
xticklabels({'SUB,SF','SUB,MF','CA1,SF','CA1,MF','CA3,SF','CA3,MF'})
set(gca,'FontSize',20,'FontWeight','b')
%%


%%
clClust=0; clusterID_old=[]; clNUM=1;
clear thisFieldMap_all RDI_all thisPHASE_stat_all
for clRUN=1:length(ClusterTable.UnitID)
    clusterID = ClusterTable.UnitID{clRUN};
    findHYPEN = strfind(clusterID,'-');
    thisRID = clusterID(1:findHYPEN(1)-1);
    thisSID = clusterID(findHYPEN(1)+1:findHYPEN(2)-1);
    thisTTID = clusterID(findHYPEN(2)+1:findHYPEN(3)-1);
    thisCLID = clusterID(findHYPEN(3)+1:end);
    
    clNUM=clNUM+1;
    
    if ~strcmp(clusterID,clusterID_old), clClust=clClust+1; clNUM=1;
        clusterID_new = [thisRID '-' thisSID '-' num2str(str2double(thisTTID)) '-' thisCLID];
        load([SaveROOT.mat '\rat' clusterID_new '.mat'],'thisFieldMap','RDI','thisPHASE_stat');
        thisFieldMap_all{clClust,1} = thisFieldMap;
        thisPHASE_stat_all{clClust,1}=thisPHASE_stat;
        RDI_all{clClust,1}=RDI;
        
        
    end
    
    
    ClusterTable.Mfr(clRUN)=thisFieldMap{clNUM,1}.onmazeAvgFR1D(1);
    ClusterTable.Pfr(clRUN)=thisFieldMap{clNUM,1}.onmazeMaxFR1D(1);
    ClusterTable.SI(clRUN)=thisFieldMap{clNUM,1}.SpaInfoScore1D(1);
    
    
    occMat = thisFieldMap{clNUM,1}.occMap1D{1,1};
    rawMat = thisFieldMap{clNUM,1}.rawMap1D{1,1};
    ClusterTable.Sparsity(clRUN) = calcSparsity(occMat, rawMat);
    
    
    clusterID_old=clusterID;
end

cd(InfoROOT)
writetable( ClusterTable,'ClusterList_20201207.xlsx','Sheet',1)
