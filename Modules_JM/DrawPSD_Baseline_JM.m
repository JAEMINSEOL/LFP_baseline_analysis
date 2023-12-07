clear all; close all; clc;
RATLIST = {'232', '234', '295','415','561','313','425','454','471','487','553','562'};
addpath(genpath('D:\HPC-LFP Project\SUB-CA1'))
cd('D:\HPC-LFP project')
SelectedTT = csvread(['SelectedTT.csv'],1,0);
FigSize_PSD = [200 200 600 500];
%%
cd('D:\HPC-LFP project\7-12Hz filtered')
for RegN = 1:4
    
    k=1;
    for RatN = 1:12
        ColorArray = hsv(12);
        thisRID = RATLIST{RatN};
        
        
        SelectedTT_trimmed = SelectedTT(and(SelectedTT(:,1)==str2double(thisRID),SelectedTT(:,4)==RegN),:);
        thisSArray = unique(SelectedTT_trimmed(:,2));
        thisTTArray = SelectedTT_trimmed(:,5);
        if ~isempty(thisTTArray)
            load(['rat' thisRID '-Theta.mat']);
            load(['rat' thisRID '-Theta(findpeaks).mat']);
            RegionIndex = Region_Index2Name_JM(RegN);
            
            
            
            for SN = 1:length(thisSArray)
                thisSNum = thisSArray(SN); if thisSNum<10 thisSID = ['0' num2str(thisSNum)]; else thisSID = [num2str(thisSNum)]; end
                thisCSCID = thisTTArray(SN);
                %%
                LFPData = ThetaP.(['rat' thisRID '_' thisSID '_tt' num2str(thisCSCID) '_data']);
                DivID = ThetaP.(['rat' thisRID '_' thisSID '_tt' num2str(thisCSCID) '_index']);
                DivID = DivID(:,1:size(LFPData,2));
                %%
                LFPData_AllTrials_i = zeros(max(DivID(8,:)-DivID(7,:)+1),size(DivID,2));
                for i=1:size(DivID,2)
                    LFPData_AllTrials_i(1:DivID(8,i)-DivID(7,i)+1,i) = LFPData(DivID(7,i)-DivID(1,i)+1:DivID(8,i)-DivID(1,i)+1,i);
                end
                
                LFPData_AllTrials_b = zeros(max(DivID(2,:)-DivID(1,:)+1),size(DivID,2));
                for i=1:size(DivID,2)
                    LFPData_AllTrials_b(1:DivID(2,i)-DivID(1,i)+1,i) = LFPData(DivID(1,i)-DivID(1,i)+1:DivID(2,i)-DivID(1,i)+1,i);
                end
                
                LFPData_AllTrials = zeros(max(DivID(7,:)-DivID(2,:)+1),size(DivID,2));
                for i=1:size(DivID,2)
                    LFPData_AllTrials(1:DivID(7,i)-DivID(2,i)+1,i) = LFPData(DivID(2,i)-DivID(1,i)+1:DivID(7,i)-DivID(1,i)+1,i);
                end
                fig = figure('Position',FigSize_PSD);
                DrawPSD_JM(LFPData_AllTrials_b, 'g');
                hold on
                DrawPSD_JM(LFPData_AllTrials_i, 'b');
               DrawPSD_JM(LFPData_AllTrials, 'r');
                FigTitle = ['Rat' thisRID '_' thisSID '(TT' num2str(thisCSCID) ',' RegionIndex ')_InboundandRaw_PSD'];
                title(FigTitle,'interpreter','none');
                legend({'Start-500ms', 'Inbound', 'Track'})
                saveImage(fig, ['D:\HPC-LFP Project\PSD plot\Inbound(712)\' FigTitle '.jpg'],'pixels',FigSize_PSD)
            end
        end
    end
end