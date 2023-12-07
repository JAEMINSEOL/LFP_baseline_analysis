%%
clear all; close all; clc;
warning off
%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
DatROOT.raw = [MotherROOT '\RawData'];
DatROOT.parsed = [MotherROOT '\Parsed Data'];
SaveROOT.mat = [DatROOT.parsed '\Theta phase\mat files (new ref)'];

[ClusterTable] = readtable([InfoROOT '\ClusterList_20201228.xlsx'],'ReadVariableNames',true);

%%
prange=2000;
nspike=0;
%%
% ClusterTable.Filter(ClusterTable.IsoDist<14 & ClusterTable.LRatio>0.02)=0;
% IDif = (strcmp(ClusterTable.Region,'SUB') &...
%     ClusterTable.Filter);
IDif{1} = (ClusterTable.phaseSize<prange & ...
    ClusterTable.Nspikes>nspike & ...
    ClusterTable.LeftTailRatio~=0& ...
    ClusterTable.Filter_Isodist_14__Lratio_0_02);
id{1,1}=find(ClusterTable.Validation_LIA== 0 & IDif{1});
id{1,2}=find(ClusterTable.Validation_LIA~= 0 & IDif{1});
% id{3}=find(ClusterTable.Validation_FIN== 1 & IDif);
ClList = {'r','b'};
X = {'Nspikes','MeanFr','PeakFr','slope','p_slope','Sparsity','SpatialInfo','phaseSize','LeftTailRatio'};

figure; hold on

n1=9;n2=6;n3=6;
% for n11=1:1
%     for n12=6:7
%         if n1==n2, continue; end
%         subplot(7,7,(n1-1)*7+n2)
        for i=1:2
            idc=id{1,3-i};
            cc = ClList{1,3-i};
            x=ClusterTable.(X{n1})(idc);
y=ClusterTable.PeakFr(idc)./ClusterTable.MeanFr(idc);
%             y=ClusterTable.(X{n2})(idc);
            z=ClusterTable.(X{n3})(idc);
            T = [x,y]; T=sortrows(T,1);
            x=T(:,1); y=T(:,2);
           scatter(x,y,10,cc,'filled'); 
         
            
            hold on
%             p = polyfit(log(x), y, 1);
% tau = p(1);
% k = exp(p(2));
% line(x, k*x.^tau-1.1, 'color', cc,'linewidth',2)
            % line([median(x5) median(x5)], [0 70],'color','r')
            % line([0 30],[median(x6) median(x6)],'color','r')
            
        end
        if n1==1
%         set(gca,'XScale','log')

        end
        xlim([0 20]); xticks([0:2:20]); 
%         ylim([0 500]); yticks([0:40:500])
set(gca,'FontWeight','b','fontsize',15)
% xlabel(X{n1}); 
xlabel('Peak/LeftTail Fr'); 
ylabel('Peak/Mean Fr'); 
% ylabel(X{n2}) 
% legend( {'X','?','O'},'location','northwest')
%     end
% end

% line([0 500], [prange prange])
% line([0 20], [2.5 2.5])
% line([nspike nspike], [0 400])
% line([2 2], [0 16])
%%

figure('position',[100,100,1200,800]);
subplot(2,1,1)
histogram(ClusterTable.phaseSize,'BinWidth',10,'FaceColor','k')
set(gca,'fontweight','b','fontsize',15)
xlabel('Phase Range'); ylabel('Number of clusters')
ylim([0 100])

subplot(2,1,2)
hold on
histogram(ClusterTable.phaseSize(ClusterTable.Validation_LIA~=0),'BinWidth',10,'FaceColor','b')
histogram(ClusterTable.phaseSize(ClusterTable.Validation_LIA==0),'BinWidth',10,'FaceColor','r')
set(gca,'fontweight','b','fontsize',15)
xlabel('Phase Range'); ylabel('Number of clusters')
ylim([0 100])

%%
figure('position',[100,100,1200,800]); BWidth=0.1; YL = 25;
subplot(2,1,1)
histogram(ClusterTable.LeftTailRatio(ClusterTable.LeftTailRatio<5 & ClusterTable.LeftTailRatio>0),'BinWidth',BWidth,'FaceColor','k')
set(gca,'fontweight','b','fontsize',15)
xlabel('Peak/LeftTail FR'); ylabel('Number of clusters')
ylim([0 YL])
legend({'Total'})

subplot(2,1,2)
hold on
histogram(ClusterTable.LeftTailRatio(ClusterTable.LeftTailRatio<5 & ClusterTable.LeftTailRatio>0 & ClusterTable.Validation_LIA~=0),'BinWidth',BWidth,'FaceColor','b')
histogram(ClusterTable.LeftTailRatio(ClusterTable.LeftTailRatio<5 & ClusterTable.LeftTailRatio>0 & ClusterTable.Validation_LIA==0),'BinWidth',BWidth,'FaceColor','r')
set(gca,'fontweight','b','fontsize',15)
xlabel('Peak/LeftTail FR'); ylabel('Number of clusters')
ylim([0 YL])
legend({'O','X'})

%%
figure('position',[100,100,1200,800]); BWidth=0.05; YL = 25; ULimit=5;
H = ClusterTable.PeakFr./ClusterTable.MeanFr;
subplot(2,1,1)
histogram(H(H<ULimit),'BinWidth',BWidth,'FaceColor','k')
set(gca,'fontweight','b','fontsize',15)
xlabel('Peak/Mean FR'); ylabel('Number of clusters')
ylim([0 YL])
legend({'Total'})

subplot(2,1,2)
hold on
histogram(H((H<ULimit) &ClusterTable.Validation_LIA~=0),'BinWidth',BWidth,'FaceColor','b')
histogram(H((H<ULimit) & ClusterTable.Validation_LIA==0),'BinWidth',BWidth,'FaceColor','r')
set(gca,'fontweight','b','fontsize',15)
xlabel('Peak/Mean FR'); ylabel('Number of clusters')
ylim([0 YL])
legend({'O','X'})

%%
figure('position',[100,100,1200,800]); BWidth=0.05; YL = 250; ULimit=5;
H = ClusterTable.Sparsity;
subplot(2,1,1)
histogram(H(H<ULimit),'BinWidth',BWidth,'FaceColor','k')
set(gca,'fontweight','b','fontsize',15)
xlabel('Peak/Mean FR'); ylabel('Number of clusters')
ylim([0 YL])
legend({'Total'})

subplot(2,1,2)
hold on
histogram(H((H<ULimit) &ClusterTable.Validation_LIA~=0),'BinWidth',BWidth,'FaceColor','b')
histogram(H((H<ULimit) & ClusterTable.Validation_LIA==0),'BinWidth',BWidth,'FaceColor','r')
set(gca,'fontweight','b','fontsize',15)
xlabel('Sparsity'); ylabel('Number of clusters')
ylim([0 YL])
legend({'O','X'})