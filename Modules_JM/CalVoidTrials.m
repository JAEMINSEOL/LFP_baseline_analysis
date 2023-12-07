% clear; clc; close all;
warning off;
rmpath(genpath('D:\'))
%% set ROOTs
MotherROOT = 'D:\HPC-LFP Project';
SessionROOT = [MotherROOT '\DG-CA3'];



addpath(genpath('D:\HPC-LFP Project\SUB-CA1'))

%% variables for loadCSC.m
% CSCfileTag = 'RateReduced_4-12filtered';
CSCfileTag_Theta412 = 'RateReduced_4-12filtered';
CSCfileTag_Theta712 = 'RateReduced_7-12filtered';
CSCfileTag = 'RateReduced';
exportMODE = 0;
behExtraction = 1;
load('D:\HPC-LFP Project\VoidTrialsIndex.mat');
%% set parameters
Crit.Noise = [0 0.1 0.3];

%% indexing
% % event order in sensor_timestamp
Start=1; Sensor1=2; Sensor2=3; Sensor3=4; divPnt=5; Touch=7; End=8;

%% channel selected for analysis

SelectedTT = csvread(['D:\HPC-LFP project\SelectedTT.csv'],1,0);

%% Recording region list
Recording_region = readtable([MotherROOT '\Recording_region.csv']);

%% session list
ratList = {'313','425','454','471','487','553','562'};
% ratList = {'232','234','295','415','561'};

%% Set parameters
Periodicity_R=zeros(5,24); Periodicity_A=zeros(5,24); Periodicity_B=zeros(5,24);
FigSize_LFP = [1800 500 1500*0.75 640*0.75];
FigSize_PSD = [1000,800,600,500];
FigSize_P2PWidth = [1800 500 800 500];
%%

NumVoidTrials = [];
k=1;

for ssRUN = 1:7
    thisRID = ratList{ssRUN};
    cd([SessionROOT])
    
%     if ssRUN==5 MaxSSNum=6; else MaxSSNum=5; end
    for ssNUM = 1:4
        ratID = ratList{ssRUN};
                   if ssNUM<3 ssTYPE='STD'; else ssTYPE='AMB'; end
%         if and(ssNUM_p>=5,ssRUN~=5) ssTYPE='AMB'; else ssTYPE='STD'; end
%         if ssRUN==4 ssNUM=ssNUM_p+9; elseif ssRUN==1 ssNUM=ssNUM_p+3;  else ssNUM=ssNUM_p; end
        
        if ssNUM>9
            sessionID = [ratID '-' num2str(ssNUM)];
        else
            sessionID=[ratID '-0' num2str(ssNUM)];
        end
        
        LFPmotherROOT = [SessionROOT '\' ssTYPE '\3. LFP Data'];
        SPKmotherROOT = [SessionROOT '\' ssTYPE '\2. SPK Data'];
        saveROOTM = [SessionROOT '\' ssTYPE '\3. LFP Data\rawEEG'];
        rasterROOT = [SPKmotherROOT '\variables for display (original)'];
        
        findHYPEN = strfind(sessionID,'-');
        thisRID = sessionID(1:findHYPEN(1)-1);
        thisSID = sessionID(findHYPEN(1)+1:end);
        diverging_point = get_divergingPoint(SPKmotherROOT, thisRID, thisSID);
        
        
        
        %% load sensor timestamps
        
        sensor_timestamp = get_diverging_timestamp(SPKmotherROOT,LFPmotherROOT,thisRID,thisSID);
        sensor_timestamp_aligned = sensor_timestamp - sensor_timestamp(:,1);
        load([LFPmotherROOT '\rat' thisRID '\rat' thisRID '-' thisSID '\ParsedPosition.mat'],'x','y', 't');
        %% load SPK data
        
        load([rasterROOT '\rat' sessionID '.mat'],'trial_set_all');
        trialNum = size(trial_set_all,1);
        
        %% load selected TT
        id = find(and(SelectedTT(:,1)==str2double(thisRID),SelectedTT(:,2)==str2double(thisSID)));
        TTNum = SelectedTT(id,3:5);
        %% load theta band filtered LFP data
        
        for tt = 1:size(TTNum,1)
            thisCSCID = TTNum(tt,3);
            RegionIndex = Region_Index2Name_JM(TTNum(tt,2));
            data=[];
            ThetaPeaks_All = [];
            
            cd(saveROOTM)
            if ~isfolder(['rat' thisRID])
                mkdir(['rat' thisRID])
            end
            cd(['rat' thisRID])
            if ~isfolder(['rat' sessionID])
                mkdir(['rat' sessionID])
            end
            cd(['rat' sessionID])
            if ~isfolder([RegionIndex '-TT' num2str(thisCSCID)])
                mkdir([RegionIndex '-TT' num2str(thisCSCID)])
            end
            cd([RegionIndex '-TT' num2str(thisCSCID)])
            saveROOT = pwd;
            
            cscID = [thisRID '-' thisSID '-' num2str(thisCSCID)];
            
            
            CSCdata = loadCSC(cscID,LFPmotherROOT,CSCfileTag,exportMODE,behExtraction);
            [EEG.eeg,EEG.timestamps] = expandCSC(CSCdata);
            
            CSCdata_Theta712 = loadCSC(cscID,LFPmotherROOT,CSCfileTag_Theta712,exportMODE,behExtraction);
            [EEG_Theta712.eeg,EEG_Theta712.timestamps] = expandCSC(CSCdata_Theta712);
            
            CSCdata_Theta412 = loadCSC(cscID,LFPmotherROOT,CSCfileTag_Theta412,exportMODE,behExtraction);
            [EEG_Theta412.eeg,EEG_Theta412.timestamps] = expandCSC(CSCdata_Theta412);
            
            
            
            %% verification
            TrialInfo.VoidIndex = zeros(trialNum,3);
            for trial_iter = 1 : trialNum
                trialNum_iter = trial_set_all(trial_iter,1);
                ThetaPeaks =[];
                
                index = [];
                
                
                % 3-300Hz LFP
                % get event
                ts_trial = [sensor_timestamp(trial_iter,Start) sensor_timestamp(trial_iter,Sensor1), sensor_timestamp(trial_iter,Sensor2), sensor_timestamp(trial_iter,Sensor3), ...
                    sensor_timestamp(trial_iter,divPnt) sensor_timestamp(trial_iter,Touch) sensor_timestamp(trial_iter,End)];
                for iter2 = 1 : 7
                    index.event(iter2) = find(EEG.timestamps <= ts_trial(iter2),1,'last');
                end
                
                % get LFP index for this trial
                index.eeg = find(EEG.timestamps >= ts_trial(1)-0.5 & EEG.timestamps <= ts_trial(end-1));
                %                     if index.eeg(3)
                if min(diff(index.event))>0
                    TrialTime.total = length(EEG.eeg(index.event(1):index.event(end)))/2000;
                    TrialTime.noise(1)=length(find(EEG.eeg(index.event(1):index.event(end))>=1000))/2000;
                    TrialTime.noise(2)=length(find(EEG.eeg(index.event(1):index.event(end))>=1500))/2000;
                    TrialTime.noise(3)=length(find(EEG.eeg(index.event(1):index.event(end))>=2000))/2000;
                    
                    if TrialTime.noise(1)/TrialTime.total > 0
                        TrialInfo.VoidIndex(trial_iter,1) = 1;
                        
                    end
                    if TrialTime.noise(2)/TrialTime.total > 0
                        TrialInfo.VoidIndex(trial_iter,1) = 2;
                        
                    end
                    if TrialTime.noise(3)/TrialTime.total > 0
                        TrialInfo.VoidIndex(trial_iter,1) = 3;
                    end
                    
                    TrialTime.noise(1)=length(find(EEG_Theta712.eeg(index.event(1):index.event(end))>=1000))/2000;
                    TrialTime.noise(2)=length(find(EEG_Theta712.eeg(index.event(1):index.event(end))>=1500))/2000;
                    TrialTime.noise(3)=length(find(EEG_Theta712.eeg(index.event(1):index.event(end))>=2000))/2000;
                    for j=1:6
                        Noise_Event.(['rat' thisRID '_' thisSID '_' num2str(thisCSCID) '_1000'])(trial_iter,j) = length(find(abs(EEG_Theta712.eeg(index.event(j):index.event(j+1)))>=1000))/length(find(EEG_Theta712.eeg(index.event(j):index.event(j+1))));
                   Noise_Event.(['rat' thisRID '_' thisSID '_' num2str(thisCSCID) '_1500'])(trial_iter,j) = length(find(abs(EEG_Theta712.eeg(index.event(j):index.event(j+1)))>=1500))/length(find(EEG_Theta712.eeg(index.event(j):index.event(j+1))));
                   Noise_Event.(['rat' thisRID '_' thisSID '_' num2str(thisCSCID) '_2000'])(trial_iter,j) = length(find(abs(EEG_Theta712.eeg(index.event(j):index.event(j+1)))>=2000))/length(find(EEG_Theta712.eeg(index.event(j):index.event(j+1))));
                    end
                   if TrialTime.noise(1)/TrialTime.total > 0
                        TrialInfo.VoidIndex(trial_iter,2) = 1;
                        
                    end
                    if TrialTime.noise(2)/TrialTime.total > 0
                        TrialInfo.VoidIndex(trial_iter,2) = 2;
                        
                    end
                    if TrialTime.noise(3)/TrialTime.total > 0
                        TrialInfo.VoidIndex(trial_iter,2) = 3;
                    end
                    
                    TrialTime.noise(1)=length(find(EEG_Theta412.eeg(index.event(1):index.event(end))>=1000))/2000;
                    TrialTime.noise(2)=length(find(EEG_Theta412.eeg(index.event(1):index.event(end))>=1500))/2000;
                    TrialTime.noise(3)=length(find(EEG_Theta412.eeg(index.event(1):index.event(end))>=2000))/2000;
                    
                    if TrialTime.noise(1)/TrialTime.total > 0
                        TrialInfo.VoidIndex(trial_iter,3) = 1;
                        
                    end
                    if TrialTime.noise(2)/TrialTime.total > 0
                        TrialInfo.VoidIndex(trial_iter,3) = 2;
                        
                    end
                    if TrialTime.noise(3)/TrialTime.total > 0
                        TrialInfo.VoidIndex(trial_iter,3) = 3;
                    end
                else
                    TrialInfo.VoidIndex(trial_iter,:) = -1;
                end
            end
            NumVoidTrials(k,3) = length(TrialInfo.VoidIndex);
            NumVoidTrials(k,4) = length(find(TrialInfo.VoidIndex(:,1)>=1));
            NumVoidTrials(k,5) = length(find(TrialInfo.VoidIndex(:,1)>=2));
            NumVoidTrials(k,6) = length(find(TrialInfo.VoidIndex(:,1)>=3));
            NumVoidTrials(k,7) = length(find(TrialInfo.VoidIndex(:,2)>=1));
            NumVoidTrials(k,8) = length(find(TrialInfo.VoidIndex(:,2)>=2));
            NumVoidTrials(k,9) = length(find(TrialInfo.VoidIndex(:,2)>=3));
            NumVoidTrials(k,10) = length(find(TrialInfo.VoidIndex(:,3)>=1));
            NumVoidTrials(k,11) = length(find(TrialInfo.VoidIndex(:,3)>=2));
            NumVoidTrials(k,12) = length(find(TrialInfo.VoidIndex(:,3)>=3));
            NumVoidTrials(k,1) = str2double(thisRID);
            NumVoidTrials(k,2) = str2double(thisSID);
            k=k+1;
            IdxVoidTrials.(['Rat' thisRID '_' thisSID]) = find(TrialInfo.VoidIndex(:,2)>=3);
        end
    end
end
%%
fns = fieldnames(Noise_Event);
cd('D:\HPC-LFP project\NoiseAnalysis')
for n=1:numel(fns)/3
    for l=1:3
        id=3*(n-1)+l;
thisField = GetFieldByIndex(Noise_Event, id);
thisFName = fns{id};
m(id,:)= nanmean(thisField,1);
se(id,:) = nanstd(thisField,1)/sqrt(size(thisField,1));
f=figure('Position',[100 100 400 300]);
errorbar(m(id,:),se(id,:),'-s','MarkerSize',10,'MarkerEdgeColor','red','MarkerFaceColor','red')
xticks([0.5:1:6.5]); ylim([0 0.1]); xlim([0 7])
ylabel(['>' num2str(500+l*500) 'uV time proportion'])
xticklabels({'Start', 's1', 's2', 's3', 'DivPnt', 'FW','End'})
title(thisFName,'Interpreter','none')
saveImage(f,[thisFName '.jpg'],'pixels',[100 100 400 300]);
    end

end