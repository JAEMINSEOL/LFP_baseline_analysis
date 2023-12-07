close all; clear all
RATLIST = {'232', '234', '295','415','561','313','425','454','471','487','553','562'};
addpath(genpath('D:\HPC-LFP Project\SUB-CA1'))
FileROOT = ['D:\HPC-LFP project\7-12Hz filtered'];
load('D:\HPC-LFP project\VoidTrialsIndex.mat')

%%
Color_Array = {'#EF5675','#3CA01F','#009fff','#8277CE'};
DrawPlot = [0 1 0];

%%
SelectedTT = csvread(['D:\HPC-LFP project\SelectedTT.csv'],1,0);
LFPPower_Event_Mean = [];
Velocoty_Mean = nan(size(SelectedTT,1),7,4);
n=1;
for ssRUN = 1:12
    
    
    if ssRUN==5 MaxSSNum= 6; elseif ssRUN>5 MaxSSNum = 4; else MaxSSNum = 5; end
    thisRID = RATLIST{ssRUN};
%     fig = figure('Position',[100 40 1800 900]);
    for ssnum_p = 1:MaxSSNum
        cd('D:\HPC-LFP Project')
        if and(ssnum_p>=5,ssRUN~=5) ssTYPE='AMB'; else ssTYPE='STD'; end
        if strcmp(thisRID,'232') ssnum=ssnum_p+3; elseif strcmp(thisRID,'415') ssnum = ssnum_p+9; else ssnum = ssnum_p; end
        if ssnum > 9 thisSID=num2str(ssnum); else thisSID = ['0' num2str(ssnum)]; end
        
        cd(FileROOT)
        if exist(['NormalizedPower(712)' thisRID '-' thisSID '.mat'])
            load(['NormalizedPower(712)' thisRID '-' thisSID '.mat']);
            if ~isempty(PMean)
                id = find(and(SelectedTT(:,1)==str2double(thisRID),SelectedTT(:,2)==str2double(thisSID)));
                TTNum = SelectedTT(id,3:5);
                %
                cd('D:\HPC-LFP Project\NormLFPScatter(712)')
                SelectedTTScatter.(['Rat' thisRID '_' thisSID]) = DrawNorLFPScatter_JM(PMean, thisRID, thisSID,TTNum,IdxVoidTrials.(['Rat' thisRID '_' thisSID]),Color_Array,DrawPlot(1));
                [SelectedTTScatter.(['Rat' thisRID '_' thisSID '_EventParsed']),VelocityMean.(['Rat' thisRID '_' thisSID '_EventParsed'])] = ParseLFPPower_Event_JM(PMean,TTNum,[thisRID '-' thisSID]);
                
%                 DrawLFPPower_Event_JM(PMean,TTNum,ssnum_p,MaxSSNum,[thisRID '-' thisSID],[2 4])
                em_temp = squeeze(nanmean(SelectedTTScatter.(['Rat' thisRID '_' thisSID '_EventParsed']),1));
                LFPPower_Event_Mean(n,:,:) = em_temp;
                vm_temp = squeeze(nanmean(VelocityMean.(['Rat' thisRID '_' thisSID '_EventParsed']),1));
                Velocoty_Mean(n,:,1:size(vm_temp,2)) = vm_temp;
                n=n+1;
                PMean(isinf(PMean))=NaN;
                SelectedTT(id,8) = squeeze(nanmean(PMean(:,3,TTNum(:,3))));
                SelectedTT(id,9) = squeeze(nanmean(PMean(:,1,TTNum(:,3))./mean(PMean(:,3,TTNum(:,3)),1)));
                % SelectedTTScatter(j,1:length
                
                %%

                x = VelocityMean.(['Rat' thisRID '_' thisSID '_EventParsed']);
                y = SelectedTTScatter.(['Rat' thisRID '_' thisSID '_EventParsed']);
                DrawSpeedVSPowerScatter_Trial_JM(x,y,thisRID,thisSID,Color_Array)
                end
        end
    end
%     saveImage(fig, ['D:\HPC-LFP Project\NormLFPScatter(712)\' thisRID  '_parsed.jpg'],'pixels',[100 40 1800 900])
end
% TTBox = CompLFPPower_JM(SelectedTT,RATLIST);
% 
% TTBox.Event=LFPPower_Event_Mean;
% 
% DrawCompLFPPower_JM(TTBox)
% 
% %%
% clear Power Velocity
% 
% for j = 1:7
% Power(:,j) = reshape(LFPPower_Event_Mean(1:54,j,1:2),[],1);
% Velocity(:,j) = reshape(Velocoty_Mean(1:54,j,1:2),[],1);
% end
% %%
% figure('Position',[100 100 600 600]);
% 
% scatter(nanmean(Velocity(:,2:6),2),nanmean(Power(:,2:6),2),30,hex2rgb(Color_Array(1)),'filled')
% hold on
% for j=3:4
% scatter(Velocity(:,j),Power(:,j),30,hex2rgb(Color_Array(j-1)),'filled')
% end
% 
% xlabel('Velocity(cm/s)')
% ylabel('Normalized Theta Band Power')
% set(gca,'FontSize',15,'FontWeight','b')
% legend({'Start-End', 's1-s2','s2-s3'})
%%
% [h,p] = ttest2(x,y,'Vartype','unequal')

% NormalizedLFPScatter_JM(SelectedTTScatter,Color_Array, [100 100 2000 700])