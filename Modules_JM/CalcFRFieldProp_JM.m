%%
clear all; close all; clc;
warning off
%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
DatROOT.raw = [MotherROOT '\RawData'];
DatROOT.parsed = [MotherROOT '\Parsed Data'];
SaveROOT.mat = [DatROOT.parsed '\Theta phase\mat files (new ref)'];
[ClusterTable] = readtable([InfoROOT '\ClusterList_20201120.xlsx']);
addpath(genpath([MotherROOT '\Analysis program\tools']))
addpath(genpath([MotherROOT '\Analysis program\Modules_JM']))
addpath(genpath([MotherROOT '\Analysis program\Modules_SM']))

LesionGroup = {'425','454','471','553'};
RegionList = {'SUB','CA1','CA3','CA3_DGLesion'};
clusterID_old =[]; t=1;
FRFieldProp=table;

% set variables
LF_burst = [1 6];
LF_baseline = [1 50];
SR_burst = [1 10];
SR_baseline = [40 50];

for clRUN = 1:numel(ClusterTable.UnitID)
    
    clusterID = cell2mat(ClusterTable.UnitID(clRUN));
    if strcmp(clusterID_old,clusterID), continue; end
    clusterID_old = clusterID;
    
    findHYPEN = strfind(clusterID,'-');
    thisRID = clusterID(1:findHYPEN(1)-1);
    thisSID = clusterID(findHYPEN(1)+1:findHYPEN(2)-1);
    thisTTID = num2str(str2double(clusterID(findHYPEN(2)+1:findHYPEN(3)-1)));
    thisCLID = clusterID(findHYPEN(3)+1:end);
    
    clusterID_new = [thisRID '-' thisSID '-' thisTTID '-' thisCLID];
    
    burst_index_JM;
    
    save([DatROOT.parsed '\map files (outbound) epoch_filtered\rat' clusterID_new], 'LF_burstIndex','-append')
    
    load([DatROOT.parsed '\map files (outbound) epoch_filtered\rat' clusterID_new])
    FRFieldProp.UnitID{t} = clusterID;
    FRFieldProp.Region{t} = cell2mat(ClusterTable.Region(clRUN));
    if ismember(thisRID,LesionGroup)
        FRFieldProp.Region{t} = 'CA3_DGLesion';
    end
    
    FRFieldProp.BurstIndex(t) = LF_burstIndex;
    FRFieldProp.SpatialInfo(t) = SpaInfoScore1D(1);
    FRFieldProp.MeanFR(t) = onmazeAvgFR1D(1);
    FRFieldProp.PeakFR(t) = onmazeMaxFR1D(1);
    t=t+1;
end

%%
figure('position',[362,143,868,744]);
view(24,27)
c=[hex2rgb('#EC4E49');hex2rgb('#0088FF');hex2rgb('#57423F');hex2rgb('#2AC195')];
% c=[hex2rgb('#EC4E49');hex2rgb('#0088FF');hex2rgb('#57423F');hex2rgb('#BFA6A2')];
hold on
grid on
for i = 1:4
    id = find(strcmp(RegionList{i},FRFieldProp.Region));
    scatter3(FRFieldProp.BurstIndex(id),FRFieldProp.SpatialInfo(id),...
        FRFieldProp.MeanFR(id),40,c(i,:),'filled')
end

xlabel('BurstIndex'); xticks([0:0.1:0.6])
ylabel('Spatial Info'); set(gca,'Ydir','reverse'); yticks([0:1:3])
zlabel('Mean FR')
legend(RegionList,'Interpreter','none','location','eastoutside')
alpha(1)

%%

figure('position',[362,143,868,744]);

% c=[hex2rgb('#EC4E49');hex2rgb('#0088FF');hex2rgb('#00A466');hex2rgb('#57423F')];
hold on
grid on
for i = 1:4
    id = find(strcmp(RegionList{i},FRFieldProp.Region));
    scatter(FRFieldProp.MeanFR(id),...
        FRFieldProp.PeakFR(id),20,c(i,:),'filled')
end

xlabel('Mean FR');
ylabel('Peak FR');

legend(RegionList,'Interpreter','none','location','eastoutside')
alpha(.6)