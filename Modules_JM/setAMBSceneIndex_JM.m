clear; clc; close all;
warning off;

%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
ModulesROOT = [MotherROOT '\Analysis program'];
DatROOT.raw = [MotherROOT '\RawData'];
DatROOT.parsed = [MotherROOT '\Parsed Data'];
SaveROOT.mat = [DatROOT.parsed '\Theta phase\mat files (new ref)'];
FigROOT = [MotherROOT '\Plots'];
rasterROOT = [DatROOT.raw '\variables for display'];

SPKmotherROOT = 'D:\SUB-CA1 Ephys\2. SPK Data';
LFPmotherROOT = 'D:\SUB-CA1 Ephys\3. LFP Data';

mapROOT_out = [DatROOT.parsed '\map files (outbound) epoch_filtered'];
boundaryROOT_out = [DatROOT.parsed '\boundary files\mat files (outbound) - epoch_filtered'];
SPKmotherROOT = 'D:\SUB-CA1 Ephys\2. SPK Data';
LFPmotherROOT = 'D:\SUB-CA1 Ephys\3. LFP Data';

addpath(genpath(ModulesROOT))
rmpath(genpath([ModulesROOT '\Modules_CH']))


%%
% RatList = {'313','425','454','471','487','553','562'};
RatList = {'232-08','234-05','295-05','425-14','561-06'};
[inputCSVs] = readcell([InfoROOT '\ClusterList.csv']);

%%

for clRUN = 1: numel(inputCSVs)
    try

        clusterID = inputCSVs{clRUN};
        
        findHYPEN = strfind(clusterID,'-');
        thisRID = clusterID(1:findHYPEN(1)-1);
        thisSID = clusterID(findHYPEN(1)+1:findHYPEN(2)-1);
        thisTTID = clusterID(findHYPEN(2)+1:findHYPEN(3)-1);
        thisCLID = clusterID(findHYPEN(3)+1:end);
        sessionID = [thisRID '-' thisSID];
        
        if ~ismember(sessionID,RatList), continue; end
%         if and(~strcmp(thisSID,'03'), ~strcmp(thisSID,'04')), continue; end
        
        if ~exist([rasterROOT '\rat' clusterID '.mat'])
            disp([clusterID ' is not exist!'])
        end
        load([rasterROOT '\rat' clusterID '.mat'])
        TrialList = readcell([DatROOT.raw '\rat' thisRID '\rat' sessionID '\behaviorData.csv']);
        j=1; trial_set_all=[];
        for i=1:size(TrialList,1)-1
            
            
            if (strcmp(TrialList{i+1,10},'YES')), continue; end
            if TrialList{i+1,5}>6, continue; end
            if or(strcmp(TrialList{i+1,2},'Zebra'),strcmp(TrialList{i+1,2},'Pebbles'))
                IndexCxt=0;
            else
                IndexCxt=10;
            end
            
            if or(strcmp(TrialList{i+1,2},'Zebra'),strcmp(TrialList{i+1,2},'Bamboo'))
                switch TrialList{i+1,12}
                    case 'NORMAL'
                        IndexAMB=1;
                    case 'AMB1'
                        IndexAMB=2;
                    case 'AMB2'
                        IndexAMB=3;
                    case '40 Blr'
                        IndexAMB=7;
                    case '70 Blr'
                        IndexAMB=8;
                    otherwise
                end
            else
                switch TrialList{i+1,12}
                    case 'NORMAL'
                        IndexAMB=6;
                    case 'AMB1'
                        IndexAMB=5;
                    case 'AMB2'
                        IndexAMB=4;
                    case '40 Blr'
                        IndexAMB=10;
                    case '70 Blr'
                        IndexAMB=9;
                    otherwise
                end
                
            end
            
            Index=IndexCxt + IndexAMB ;
            trial_set_all(j,1)=TrialList{i+1,1};
            trial_set_all(j,2)=Index;
            trial_set_all(j,3) = strcmp(TrialList{i+1,4},'WRONG')+1;
            j=j+1;
        end
        trial_set_all(trial_set_all(:,1)==0,:)=[];
        save([rasterROOT '\rat' clusterID '.mat'],'trial_set_all','-append');
        save([rasterROOT '\rat' thisRID '-' thisSID '.mat'],'trial_set_all','-append');
        disp([clusterID ' is finished'])
    catch
        disp([clusterID ' is failed'])
    end
end



