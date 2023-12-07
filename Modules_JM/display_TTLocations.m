%%
clear all; close all; clc;
warning off
%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
DatROOT.raw = [MotherROOT '\RawData'];
DatROOT.parsed = [MotherROOT '\Parsed Data'];
SaveROOT.mat = [DatROOT.parsed '\Theta phase\mat files (new ref)'];
RatList = [232;234;295;415;561;313;425;454;471;487;553;562];
LesionGroup = {'425','454','471','553'};

ClTable = readtable([InfoROOT '\TetrodeSelection_20201221.xlsx']);
[TtTable] = readtable([InfoROOT '\TetrodeLocations.xlsx']);
[InputCSVs] = readtable([InfoROOT '\ClusterList_20201120.xlsx']);
RegionList = {'SUB','CA1','CA3','CA3_DGLesion'};

addpath(genpath([MotherROOT '\Analysis program\tools']))
%%



% c=[hex2rgb('#EC4E49');hex2rgb('#0088FF');hex2rgb('#57423F');hex2rgb('#2AC195')];
for t=1:size(TtTable,1)
        id=find(ClTable.RatID==TtTable.RatID(t) & ClTable.TTID==TtTable.TTID(t));
        if ~isempty(ClTable.Region(id))
        TtTable.Region(t) = ClTable.Region(id(1));
        end
end
%%
load([InfoROOT '\TtTable.mat'])

TempTable = TtTable(find(or(strncmp(TtTable.Region,'C',1),strncmp(TtTable.Region,'S',1))),:);
%%
% c1=distinguishable_colors(9); c2=distinguishable_colors(4);
figure; hold on
% c(1,:,:)=[hex2rgb('#EC4E49');hex2rgb('#E63E71');hex2rgb('#CF4296');hex2rgb('#A752B4');hex2rgb('#6C61C4')];
% c(2,:,:)=[hex2rgb('#0088FF');hex2rgb('#00B0FF');hex2rgb('#002887');hex2rgb('#00CEEF');hex2rgb('#97AAE0')];
% c(3,:,:)=[hex2rgb('#57423F');hex2rgb('#846474');hex2rgb('#D0A099');hex2rgb('#1D5031');hex2rgb('#737A64')];

c=distinguishable_colors(9);
% for r1=1:4
    q1=1; q2=1;
% id = find(strcmp(TtTable.Region, RegionList(r1)));
% TempTable = TtTable(id,:);
% RatTable = unique(TempTable.RatID);
for r2=1:numel(RatList)
    id = find(TempTable.RatID == RatList(r2));
    
    if ismember({num2str(RatList(r2))},LesionGroup)
        scatter(TempTable.ML(id),TempTable.AP(id),80,c(q1,:))
        q1=q1+1;
        
    else
scatter(TempTable.ML(id),TempTable.AP(id),80,c(q2,:),'filled')
q2=q2+1;
    end

end

xlabel('ML(mm)'); ylabel('AP(mm)'); ylim([-7 -2]); xlim([0 5])
legend(num2str(RatList),'location','eastoutside')

%%
c2=[hex2rgb('#EC4E49');hex2rgb('#0088FF');hex2rgb('#57423F');hex2rgb('#2AC195')];
figure; hold on
for r1=1:4
    if r1~=4
        id = find(and(strcmp(TtTable.Region, RegionList(r1)),~ismember(num2str(TtTable.RatID),LesionGroup)));
        
    else
        id = find(and(strcmp(TtTable.Region, RegionList(3)),ismember(num2str(TtTable.RatID),LesionGroup)));
    end
    TempTable = TtTable(id,:);
    histogram(TempTable.AP,'BinWidth',0.2,'FaceColor',c2(r1,:),'EdgeColor','w','Normalization','probability')
end

set(gca,'fontweight','b','fontsize',15)
xlabel('AP(mm)'); ylabel('Cell proportion')
legend(RegionList,'Interpreter','none')