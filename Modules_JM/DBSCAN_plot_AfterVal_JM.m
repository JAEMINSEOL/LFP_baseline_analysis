
clear; clc; close all;

%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
ModulesROOT = [MotherROOT '\Analysis program'];
DatROOT.raw = [MotherROOT '\RawData'];
DatROOT.parsed = [MotherROOT '\Parsed Data'];
SaveROOT.mat = [DatROOT.parsed '\Theta phase\mat files (new ref)'];
FigROOT = [MotherROOT '\Plots'];

SPKmotherROOT = 'D:\SUB-CA1 Ephys\2. SPK Data';
LFPmotherROOT = 'D:\SUB-CA1 Ephys\3. LFP Data';

mapROOT_out = [DatROOT.parsed '\map files (outbound) epoch_filtered'];
boundaryROOT_out = [DatROOT.parsed '\boundary files\mat files (outbound) - epoch_filtered'];

imageROOT{1} = 'D:\SUB-CA1 Ephys\3. LFP Data\4. Phase\manual clustering\rater1_raw';
imageROOT{2} = 'D:\SUB-CA1 Ephys\3. LFP Data\4. Phase\manual clustering\rater2_raw';

saveROOT.mat = [LFPmotherROOT '\4. Phase\Theta phase\mat files (new ref)'];

saveROOT.fig = [LFPmotherROOT '\4. Phase\DBSCAN clustering\DBSCAN result sheet'];
if ~exist(saveROOT.fig,'dir'), mkdir(saveROOT.fig); end

addpath(genpath(ModulesROOT))
rmpath(genpath([ModulesROOT '\Modules_CH']))
%% set default figure paramters
imagePosition = [100 100 800 500];
set(groot,'defaultFigurePosition',imagePosition);

ColorSet = [1 0 0; 0.1 0.8 0.2; 0 0 1; 0 1 1; 1 0 1; 0 0 0.5; 0.5 1 0; 0 1 0.5; 0 0.5 1; 1 1 0];

overallMap_index = [1 10 0 0 0 3];
nc=1; nc2=1; nc3=1;
ClusterList_Eps=table;
%% error list
% error_list = fopen([saveROOT.fig '\DBSCAN_notClustered_rat561.txt'],'w');

%% clusterID and numbering of manual clustering
% load([LFPmotherROOT '\4. Phase\manual clustering\shuffled_list.mat'],'shuffled_list');

%% load clusterID list
[inputCSVs] = readtable([InfoROOT '\ClusterList_20201228.xlsx']);
Recording_region = readtable([InfoROOT '\Recording_region.csv']);
DivPnts = readtable([InfoROOT '\diverging_points.csv']);

%% Loop
clusterID_old=[];
for clRUN = 1:numel(inputCSVs.UnitID)
%     try
        clusterID = cell2mat(inputCSVs.UnitID(clRUN));
        if clRUN>=2
%             if strcmp(clusterID,clusterID_old), continue; end
        end
        clusterID_old = clusterID;
        
        findHYPEN = strfind(clusterID,'-');
        thisRID = clusterID(1:findHYPEN(1)-1);
        thisSID = clusterID(findHYPEN(1)+1:findHYPEN(2)-1);
        thisTTID = num2str(str2double(clusterID(findHYPEN(2)+1:findHYPEN(3)-1)));
        if str2double(thisTTID) < 10
            thisTTID_new = ['0' thisTTID];
        else
             thisTTID_new = [thisTTID];
        end
%         thisCLID = clusterID(findHYPEN(3)+1:end);
thisCLID = clusterID(findHYPEN(3)+1:end);
        sessionID = [thisRID '-' thisSID];
        clusterID_new = [thisRID '-' thisSID '-' thisTTID_new '-' thisCLID];
        clusterID = [thisRID '-' thisSID '-' thisTTID '-' thisCLID];
        
        %     if strcmp(clusterID(1:3),'295'), continue; end
        disp([clusterID ' start']);
        
        row = find(ismember(Recording_region.SessionID,sessionID));
        col = Recording_region.(['TT' num2str(thisTTID)]);
%         RegionIndex = cell2mat(col(row));
RegionIndex = cell2mat(inputCSVs.Region(clRUN));
RegionIndex_d=RegionIndex;
        if or(strcmp(RegionIndex,'Subiculum'),strcmp(RegionIndex,'SUB'))
            RegionIndex_d='SUB'; RegionIndex_r=1;
        elseif strncmp(RegionIndex,'CA3',3)
            RegionIndex_d='CA3'; RegionIndex_r=3;
        elseif strcmp(RegionIndex,'CA1')
            RegionIndex_d='CA1'; RegionIndex_r=2;
        end
        
        session_type = get_sessionType(clusterID(1:3),clusterID(5:6));
        if session_type==3, session_type=2; session_type_old=3; 
        else, session_type_old=2; end
        %     if strcmp(clusterID(1:3),'295'), continue; end
        %     if session_type~=1, continue; end
        
        %% load spike phase data
        thisPHASE = getDBSCAN(clusterID,SaveROOT,0);
        if isempty(thisPHASE), continue; end
        
        load([SaveROOT.mat '\rat' clusterID '.mat'],'thisPHASE_backup','thisPHASE','thisFieldMap','PHASE_matrix','nCluster','Cluster_quality','DBSCAN_parameter','thisPHASE_stat','RDI');
        if  ~(size(thisPHASE_backup,1)/3<50)
        %% 1D rate map
        IndexC = strfind(DivPnts{:,1},sessionID);
        Index = find(not(cellfun('isempty',IndexC)));
        DivPt = DivPnts{Index,2};
        
        load([boundaryROOT_out '\rat' clusterID '.mat'],'field_count','end_index','start_index');
 
        load([mapROOT_out '\rat' clusterID '.mat'],'skaggsMap1D','skaggsMap_left1D','skaggsMap_right1D','stem_end_index');
        display_skaggs = skaggsMap1D{overallMap_index(session_type)};
        max_position = size(display_skaggs,1);
        max_rates = max(max(cell2mat(skaggsMap1D)));
        
CLid = find(strcmp(inputCSVs.UnitID,clusterID_new));
Val = inputCSVs.Validation_LIA(CLid);
%%
if length(thisFieldMap{inputCSVs.ClustNum(clRUN)}.onmazeAvgFR1D)<10
idx=1;
else
 idx=10;
end
inputCSVs.MeanFR(clRUN) = thisFieldMap{inputCSVs.ClustNum(clRUN)}.onmazeAvgFR1D(idx);
inputCSVs.PeakFR(clRUN) = thisFieldMap{inputCSVs.ClustNum(clRUN)}.onmazeMaxFR1D(idx);
rawMat =  thisFieldMap{inputCSVs.ClustNum(clRUN)}.rawMap1D{idx};
occMat =  thisFieldMap{inputCSVs.ClustNum(clRUN)}.occMap1D{idx};
inputCSVs.Sparsity(clRUN) = calcSparsity(occMat, rawMat);
inputCSVs.SpatialInfo(clRUN) = thisFieldMap{inputCSVs.ClustNum(clRUN)}.SpaInfoScore1D(idx);

%%


%%
      display_DBSCANSummary_JM;
%       display_conditionSheet_JM;
%%

        clear thisPHASE_backup thisPHASE PHASE_matrix nCluster DBSCAN_parameter display_skaggs RDI
        end
%       catch
%           disp(['DBSCAN plotting failed'])
%     end
     close all
       
end


%%
% figure;
% x=cell2mat(CQual(:,5)); y = cell2mat(CQual(:,6));
% c=[[0 0 0];[1 0 0];[0 0 1]];
% list_temp = {'SUB','CA1','CA3'};
% for i=1:3
% id = find(strcmp(cell2mat(CQual(:,4)),list_temp(i)));
% scatter(x(id),y(id),10,c(i,:),'filled')
% hold on
% end
% % set(gca, 'YScale', 'log','XScale', 'log')
% set(gca, 'FontWeight','b','FontSize',20)
% xlabel('Isolation Distance'); ylabel('L-Ratio')
% axis ij
% line([14 14],[0 max(y)],'Color','r')
% line([0 max(x)],[0.02 0.02],'Color','r')
% xlim([0 250])
% ylim([0 0.2])
% legend({'SUB','CA1','CA3'})
% 
% fclose all;
