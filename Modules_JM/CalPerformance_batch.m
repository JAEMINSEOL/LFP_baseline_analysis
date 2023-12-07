clear; clc; close all;
warning off

%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
DatROOT.raw = [MotherROOT '\RawData'];
DatROOT.parsed = [MotherROOT '\Parsed Data'];
SaveROOT.mat = [DatROOT.parsed '\Theta phase\mat files (new ref)'];
[SessionTable] = readtable([InfoROOT '\Session info.xlsx']);

%%
LesionGroup={'425','454','471','553'};
LCHGroup = {'313','425','454','471','487','553','562'};

STDCode = {'Zebra','Bamboo','Pebbles','Mountain'};
AMBCode = {'NORMAL','AMB1','AMB2';'NORMAL','30 Blr','50 Blr'};

SessionNum = length(SessionTable.x_Session);
%%
clear id 
AMBCorr=NaN(SessionNum,4);
STDCorr=NaN(SessionNum,4);
Corr=NaN(SessionNum,4);
LesionID = zeros(SessionNum,1);
for i=1:length(SessionTable.x_Session)
    thisRID = SessionTable.x_Session{i}(1:3);
    thisSID = SessionTable.x_Session{i}(5:6);
    thisSType = SessionTable.SessionType{i}(1:3);
    [TrialTable] = readtable([DatROOT.raw '\rat' thisRID '\rat' SessionTable.x_Session{i} '\behaviorData.csv']);
    LesionID(i) = ismember(thisRID,LesionGroup);
    
    CorrRaw = strcmp(TrialTable.Correctness,'CORRECT');
    idx = find(strcmp(TrialTable.TrialVoid,'NO'));
    OverAllCorr(i) = nanmean(CorrRaw(idx));
    if strcmp(thisSType,'AMB')
        % AMB session correctness
        
        a = ismember(thisRID, LCHGroup)+1;
        
        for j=1:4
            if j==1
                id{j} = (1:find(~strcmp(TrialTable.Ambiguity,AMBCode{a,1}) & strcmp(TrialTable.TrialVoid,'NO'), 1,'first' )-1);
            else
                id{j} = find(strcmp(TrialTable.Ambiguity,AMBCode{a,j-1}) & TrialTable.Trial_ >max(id{1}) & strcmp(TrialTable.TrialVoid,'NO'));
            end
            AMBCorr(i,j) = nanmean(CorrRaw(id{j}));
            NumTrials(i,j) = length(id{j});
        end

    else
        % STD session correctness
        for j=1:4
            id{j} = find(strcmp(TrialTable.Context,STDCode{j}) & strcmp(TrialTable.TrialVoid,'NO'));
            STDCorr(i,j) = nanmean(CorrRaw(id{j}));
            NumTrials(i,j) = length(id{j});
        end

    end
    for j=1:4
        Corr(i,j) = nanmean(CorrRaw(id{j}));
        NumTrials(i,j) = length(id{j});
    end
     Corr(i,5) = str2double(thisRID);
   Corr(i,6) = str2double(thisSID);
end
Corr(isnan(Corr(:,1)),1:4)=NaN;
STDCorr(isnan(Corr(:,1)),1:4)=NaN;
AMBCorr(isnan(Corr(:,1)),1:4)=NaN;
%%
for i=0:1
    for j=1:4
AMBCorr_m(i+1,j) = nanmean(AMBCorr(LesionID==i,j));
AMBCorr_se(i+1,j) = nanstd(AMBCorr(LesionID==i,j))/sqrt(sum(LesionID==i & ~isnan(AMBCorr(:,1))));
    end
end

%%
figure; 
hold on

errorbar(AMBCorr_m(1,:),AMBCorr_se(1,:),'b')
errorbar(AMBCorr_m(2,:),AMBCorr_se(2,:),'r')

p2 = plot(AMBCorr_m(1,:),'b','LineWidth',2);
p3 = plot(AMBCorr_m(2,:),'r','LineWidth',2);

title('AMB session correctness')
xticks([1:1:4]); xticklabels({'STD','No','Lo','Hi'})
xlim([0.5 4.5])
ylabel('Correctness'); ylim([0.5 1])
set(gca,'FontSize',15,'FontWeight','b')
legend([p2 p3],{'Control','Lesion'})
%%
figure; hold on
boxplot(STDCorr(:,1:4))

for i=1:4
    x=ones(length(find(~LesionID)),1)*(i-0.1);
    y = (STDCorr(find(~LesionID),i));
scatter(x,y,10,'b','filled')
end

for i=1:4
    x=ones(length(find(LesionID)),1)*(i+0.1);
    y = (STDCorr(find(LesionID),i));
scatter(x,y,10,'r','filled')
end

title('STD session correctness')
xticks([1:1:4]); xticklabels({'Z','B','P','M'})
xlim([0.5 4.5])
ylabel('Correctness'); ylim([0.5 1.1])
set(gca,'FontSize',15,'FontWeight','b')

%% 
x1=AMBCorr(find(LesionID),1);
x2=AMBCorr(find(LesionID),2);
x3=AMBCorr(find(LesionID),4);
x4=AMBCorr(find(~LesionID),4);

X = [x1,x2,x3,x4];
X(isnan(X(:,1)),:)=[];
[h,p,sigPairs] = ttest_bonf(X,[1 4; 2 4; 3 4],0.016,0);

anova1([x1,x2,x3,x4]);

x1=AMBCorr(find(~LesionID),4);
x2=AMBCorr(find(LesionID),4);
[h,p,ci,stats]=ttest2(x4, x3)



