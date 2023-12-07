clear all; close all; clc;
RATLIST = {'232', '234', '295','415','561','313','425','454','471','487','553','562'};
addpath(genpath('D:\HPC-LFP Project\SUB-CA1'))
SelectedTT = csvread(['SelectedTT.csv'],1,0);
FigSize_PSD = [200 200 600 500];
%%
movingwin = [1 0.02];
params.pad =3;
params.tapers = [3 5];
params.Fs = 2000;
params.fpass = [3 13];
params.pad = 2;
params.trialave=1;

%%
for RegN = 1:4
                fig = figure('Position',FigSize_PSD);
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
            

%              for SN = 1:length(thisSArray)
SN = randi([1 length(thisSArray)],1);
                
                thisSNum = thisSArray(SN); if thisSNum<10 thisSID = ['0' num2str(thisSNum)]; else thisSID = [num2str(thisSNum)]; end
                thisCSCID = thisTTArray(SN);
                %%
                LFPData = ThetaP.(['rat' thisRID '_' thisSID '_tt' num2str(thisCSCID) '_data']);
                DivID = ThetaP.(['rat' thisRID '_' thisSID '_tt' num2str(thisCSCID) '_index']);
                DivID = DivID(:,1:size(LFPData,2));
                %%
                LFPData_AllTrials = zeros(max(DivID(7,:)-DivID(1,:)+1),size(DivID,2));
                for i=1:size(DivID,2)
                    LFPData_AllTrials(1:DivID(7,i)-DivID(2,i)+1,i) = LFPData(DivID(2,i)-DivID(1,i)+1:DivID(7,i)-DivID(1,i)+1,i);
                end
                [S,f] = mtspectrumc(LFPData_AllTrials, params);
                plot(f,S,'Color',ColorArray(RatN,:),'LineWidth',2)
                hold on
                RATLIST_trimmed{k} = RATLIST{RatN};
                k=k+1;
         end
    end               
                
%             end
            set(gca, 'YScale', 'log','FontSize',12)
            ylim([0 100000])
%             title(['PSD-rat' thisRID '(' RegionIndex ')'])
 title(['PSD-' RegionIndex ])
            xlim([4 12])
            xlabel('Frequency(Hz)'); ylabel('LFP Power')
            cd(['D:\HPC-LFP project\PSD plot'])
%             saveImage(fig, ['PSD_rat' thisRID '(' RegionIndex ')_overlap.jpg'],'pixels',FigSize_PSD)
legend(RATLIST_trimmed,'Location','eastoutside')
 saveImage(fig, ['PSD_' RegionIndex '_overlap.jpg'],'pixels',FigSize_PSD)
            hold off

end