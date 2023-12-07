%%
clear all; close all; clc;
addpath(genpath('D:\HPC-LFP project'))
cd('D:\HPC-LFP project')
Recording_region = readtable(['\Recording_region.csv']);
TTQualTable = {};
%% set params
Theta_lowcut = 4;
Theta_highcut = 12;

FileROOT = ['D:\HPC-LFP project\Parsed Data\' num2str(Theta_lowcut) '-' num2str(Theta_highcut) 'Hz filtered'];
cd(FileROOT)


movingwin = [1 0.02];
params.pad =3;
params.tapers = [3 5];
params.Fs = 2000;
params.fpass = [num2str(Theta_lowcut) Theta_highcut];
params.pad = 2;
params.trialave=1;
               TBefDiv = 1.5*params.Fs;
TAftDiv = 1*params.Fs;
Norm = 0;
 NumList = 1;

%%
% RATLIST = {'313','425','454','471','487','553','562'};
RATLIST = {'232', '234', '295','415','561','313','425','454','471','487','553','562'};
MaxSSNum = 5;
for ssRUN = 1:5
   if ssRUN==5 MaxSSNum = 6; elseif ssRUN>5 MaxSSNum = 4; else MaxSSNum = 5; end
    thisRID = RATLIST{ssRUN};
    load(['rat' thisRID '-Theta.mat']);
    load(['rat' thisRID '-Theta(findpeaks).mat']);
    for ssnum_p = 1:MaxSSNum
PMean = [];
        x=zeros(1,24); y=x; y2=x; r=x; BinnedPerioQual_TT=zeros(24,2);
        tt=[];
        if and(ssnum_p>=5,ssRUN~=5) ssTYPE='AMB'; else ssTYPE='STD'; end
        if strcmp(thisRID,'232') ssnum=ssnum_p+3; elseif strcmp(thisRID,'415') ssnum = ssnum_p+9; else ssnum = ssnum_p; end
        if ssnum > 9 thisSID=num2str(ssnum); else thisSID = ['0' num2str(ssnum)]; end
        for thisCSCID=1:24
            clear LFPData_aligned
            tt(thisCSCID)=thisCSCID;
            if isfield(ThetaP,['rat' thisRID '_' thisSID '_tt' num2str(thisCSCID) '_data'])
                
                %% find recording region
                sessionID = [thisRID '-' thisSID];
                row = find(ismember(Recording_region.SessionID,sessionID));
            col = Recording_region.(['TT' num2str(thisCSCID)]);
            RegionIndex = cell2mat(col(row)); if strcmp(RegionIndex,'Subiculum') RegionIndex='SUB';  end
            
            if strcmp(RegionIndex,'SUB') regionindex = 1;
            elseif strcmp(RegionIndex,'CA1') regionindex = 2;
            elseif strncmp(RegionIndex,'CA3',3) regionindex = 3; 
            else regionindex = 0;
            end
            if regionindex~=0
            %% Load LFP PSD data
                LFPData = ThetaP.(['rat' thisRID '_' thisSID '_tt' num2str(thisCSCID) '_data']);
                DivID = ThetaP.(['rat' thisRID '_' thisSID '_tt' num2str(thisCSCID) '_index']);
                DivID = DivID(:,1:size(LFPData,2));
%                 VoidID = find(DivID>10*params.Fs); VoidID(find(VoidID>size(LFPData,2)))=[];
%                 if ~isempty(VoidID)
%                     LFPData(:,VoidID)=[]; DivID(:,VoidID)=[];
%                 end
%                 MAXLFP = max(LFPData,[],2); MINLFP = min(LFPData,[],2); STDLFP = std(LFPData,[],2);
%                 
%                 RID = find(and(and(MAXLFP(:,1)==0,MINLFP(:,1)==0),STDLFP(:,1)==0));
%                 
%                 j=1; RID_trimmed=[];
%                 for i=1:size(RID,1)-1
%                     if RID(i)==RID(i+1)-1
%                         RID_trimmed(j,1)=RID(i);
%                         j=j+1;
%                     end
%                 end
                LFPData_trimmed = LFPData;
%                 LFPData_trimmed(RID_trimmed,:)=[];
%                 FigSize = [600 200 800 600];
                DivIDMax = max(DivID(1,1:size(LFPData_trimmed,2)));
                
                 %%
                for i = 36000:size(LFPData_trimmed,1)
                    for j= 1:size(LFPData_trimmed,2)
                        LFPData_aligned(i+(DivIDMax - DivID(1,j)),j) = LFPData_trimmed(i,j);
                    end
                end
                %%
                DrawSpectrogram_JM(LFPData_aligned, movingwin,params,thisRID,thisSID, thisCSCID,RegionIndex,Norm,DivIDMax)
%%
[PMean(:,:,thisCSCID)] = Norm_LFP_Trial_JM(LFPData,DivID,params);

                %%
%                  [S(thisCSCID),f] = mtspectrumc(LFPData, params);
%                 P2PWidth = ThetaPeak.(['rat' thisRID '_' thisSID '_tt' num2str(thisCSCID)]);
%                 %                 P2PWidth_AllTTs = cat(1,P2PWidth_AllTTs,P2PWidth);
%                 y(thisCSCID) = mean(S);
%                 x(thisCSCID) = std(P2PWidth(:,3));
%                 tt(thisCSCID)=thisCSCID;
%                 r(thisCSCID) = regionindex;
%                 
%                 
%                 BinnedP2PWidth = Binning_JM(20,P2PWidth(:,2),P2PWidth(:,3),320);
%                 BinnedPerioQual_TT(thisCSCID,1) = nanmean(BinnedP2PWidth(:,3));
%                 BinnedPerioQual_TT(thisCSCID,2) = nanstd(BinnedP2PWidth(:,3));
                %%
%                 
%              Avg_Pos=[];
% for i=  1:size(LFPData_aligned,2)
% idx = min(find(LFPData_aligned(:,i)~=0));
% if isempty(idx)
%     Avg_Pos(:,i) = zeros(1,1000);
% else
% Avg_Pos(:,i) = LFPData_aligned(idx:idx+999,i);
% end
% end
% [S_Baseline,f_Baseline] = mtspectrumc(Avg_Pos, params);
% Baseline_P = trapz(linspace(4,12,20),S_Baseline);


%%
% scatter(ones(size(PMean(2,:))),PMean(2,:),20,'r','filled')
% xticks(1)
% xticklabels({'TT02'})
% xlabel('TTNum'); ylabel('Normalized Power')
%%
%                 sessionID = [thisRID '-' num2str(ssnum)];
% %                 fig3 = figure('Position',[200 200 700 600]);
% %                 plot(f,S/Baseline_P,'r','LineWidth',2)
% %                  ylim([0 3])
% % %                 set(gca, 'YScale', 'log','FontSize',12)
% %                 title(['PSD-rat' thisRID '-' num2str(ssnum) '-TT' num2str(thisCSCID) '(' RegionIndex ')'])
% %                 xlim([4 12])
% %                 xlabel('Frequency(Hz)'); ylabel('Normalized Power')
% %                 hold on
%                 [pks,locs] = findpeaks(S);
%                 locs(or(f(locs)<6,f(locs)>10))=[];
%                 locs(S(locs)~=max(S(locs)))=[];
% %                 if ~isempty(locs) locs = locs(1); end
% %                 scatter(f(locs),S(locs)/Baseline_P,50,'k','LineWidth',2)
% %                 cd(['D:\HPC-LFP project\PSD plot'])
% %                 saveImage(fig3,['rat' thisRID '-' num2str(ssnum)  '_TT' num2str(thisCSCID) '(' RegionIndex ')_PSD(Normalized_500).jpg'],'pixels',[200 200 700 600]);
%                 if ~isempty(locs)
%                 y2(thisCSCID) = S(locs);
%                 else
%                     y2(thisCSCID) = 0;
%                 end
                
                %%
%                NumList = (ssRUN-1)*(6*24)+(ssnum_p-1)*(24)+thisCSCID;
%                 TTQualTable{NumList,1} = thisRID;
%                 TTQualTable{NumList,2} = thisSID;
%                 TTQualTable{NumList,3} = ssTYPE;
%                 TTQualTable{NumList,4} = thisCSCID;
%                 TTQualTable{NumList,5} = RegionIndex;
%                 TTQualTable{NumList,6} = nanmean(S);
%                 TTQualTable{NumList,7} = S(locs);
%                 TTQualTable{NumList,8} = f(locs);
%                 TTQualTable{NumList,9} = nanstd(P2PWidth(:,3));
%                 TTQualTable{NumList,10} = nanmean(P2PWidth(:,3));
%                 TTQualTable{NumList,11} = BinnedPerioQual_TT(thisCSCID,2);
            end
           
            else
%                 tt(thisCSCID)=0;
            end
            
        end
        
        %%
save(['NormalizedPower' thisRID '-' thisSID '.mat'],'PMean')
        %% tetrode power-periodicity scatter plots
%         if ~isempty(tt)
%             % PSD mean
%             fig2 = figure('Position',[200 200 700 600]);
%             idr = find(tt==0);
%             x(idr)=[]; y(idr)=[]; tt(idr)=[]; r(idr)=[];
%             if ~isempty(x)
%                 scatter(x(r==1),y((r==1)),40,'r','filled')
%                 hold on
%                 scatter(x(r==2),y((r==2)),40,'b','filled')
%                 hold on
%                 scatter(x(r==3),y((r==3)),40,'g','filled')
%                 legend({'SUB', 'CA1', 'CA3'},'Location','eastoutside')
%                 xlabel('stdev. of peak-to-peak width (s)')
%                 ylabel('Mean LFP power (4-12Hz)')
%                 set(gca,'FontSize',12)
%                 for i=1:size(x,2)
%                     text(x(i)*1.01,y(i),[num2str(tt(i))]);
%                 end
%                 title(['Power(mean)-Periodicity-rat' thisRID '-' thisSID])
%             end
%             cd(['D:\HPC-LFP project\PP plot'])
%             saveImage(fig2,['rat' thisRID '_' thisSID '_PP plot(mean power).jpg'],'pixels',[200 200 700 600])
%             
%             % PSD peaks
%             fig2 = figure('Position',[200 200 700 600]);
%             y2(idr)=[];
%             if ~isempty(x)
%                 scatter(x(r==1),y2((r==1)),40,'r','filled')
%                 hold on
%                 scatter(x(r==2),y2((r==2)),40,'b','filled')
%                 hold on
%                 scatter(x(r==3),y2((r==3)),40,'g','filled')
%                 legend({'SUB', 'CA1', 'CA3'},'Location','eastoutside')
%                 xlabel('stdev. of peak-to-peak width (s)')
%                 ylabel('Peak LFP power (4-12Hz)')
%                 set(gca,'FontSize',12)
%                 for i=1:size(x,2)
%                     if r(i)~=0
%                     text(x(i)*1.01,y2(i),[num2str(tt(i))]);
%                     end
%                 end
%                 title(['Power(peak)-Periodicity-rat' thisRID '-' thisSID])
%             end
%             cd(['D:\HPC-LFP project\PP plot'])
%             saveImage(fig2,['rat' thisRID '_' thisSID '_PP plot(peak power).jpg'],'pixels',[200 200 700 600])
%             
%             % PSD mean-peak
%             fig = figure('Position',[200 200 700 600]);
%             if ~isempty(y)
%                 scatter(y(r==1),y2((r==1)),40,'r','filled')
%                 hold on
%                 scatter(y(r==2),y2((r==2)),40,'b','filled')
%                 hold on
%                 scatter(y(r==3),y2((r==3)),40,'g','filled')
%                 legend({'SUB', 'CA1', 'CA3'})
%                 xlabel('Mean LFP power (4-12Hz)')
%                 ylabel('Peak LFP power (4-12Hz)')
%                 set(gca,'FontSize',12)
%                 for i=1:size(x,2)
%                     text(y(i)*1.01,y2(i),[num2str(tt(i))]);
%                 end
%                 title(['Power(peak)-Power(Mean)-rat' thisRID '-' thisSID])
%             end
%             cd(['D:\HPC-LFP project\PP plot'])
%             saveImage(fig,['rat' thisRID '_' thisSID '_peak_mean LFP Power.jpg'],'pixels',[200 200 700 600])
%             %% Peak-to-peak width mean and stdev. of all TTs in a session
%             BinnedPerioQual_TT(idr,:)=[];
%             x= BinnedPerioQual_TT(:,1); y = BinnedPerioQual_TT(:,2);
%             fig3 = figure('Position',[200 200 700 600]);
%             if ~isempty(x)
%             scatter(x(r==1),y((r==1)),40,'r','filled')
%                 hold on
%                 scatter(x(r==2),y((r==2)),40,'b','filled')
%                 hold on
%                 scatter(x(r==3),y((r==3)),40,'g','filled')
%                 legend({'SUB', 'CA1', 'CA3'},'Location','eastoutside')
%                 xlabel('mean of peak-to-peak width stdev.')
%                 ylabel('stdev. of peak-to-peak width stdev.')
%                 set(gca,'FontSize',12)
%                 for i=1:min(length(tt),length(x))
%                     text(x(i)*1.01,y(i),[num2str(tt(i))]);
%                 end
%                 title(['P2PVar-rat' thisRID '-' thisSID])
%             end
%             cd(['D:\HPC-LFP project\PP plot'])
%             saveImage(fig3,['rat' thisRID '_' thisSID '_P2PVar.jpg'],'pixels',[200 200 700 600])
%         end
    end
end
