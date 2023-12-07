
clear; clc; close all;

% phase matrix index
% PHASE = 1; TS = 2; TS_ALIGNED = 3; TRIAL = 4; ZONE = 5; SCENE = 6;
% CORRECTNESS = 7; yPos = 8; speed = 9;
%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
ModulesROOT = [MotherROOT '\Analysis program'];
DatROOT = [MotherROOT '\RawData'];
SaveROOT.mat = [MotherROOT '\Parsed Data\Theta phase\mat files (new ref)'];
SaveROOT.fig = [MotherROOT '\Plots\DBSCAN\DBSCAN(Epsilon_Var)'];

addpath(genpath(ModulesROOT))
rmpath(genpath([ModulesROOT '\Modules_CH']))

%% Load Cluster List
DivPnts = readtable([InfoROOT '\diverging_points.csv']);
SelectedTT = csvread([InfoROOT '\SelectedTT.csv'],1,0);
[inputCSVs] = readcell([InfoROOT '\ClusterList.csv']);

Recording_region = readtable([InfoROOT '\Recording_region.csv']);
Epsilon_Check = readtable([InfoROOT '\FilterOutClusterList.xlsx']);
clusterID_old=[];
%% Loop
% for clRUN =  997:numel(inputCSVs)
for clRUN =  1:numel(Epsilon_Check.UnitID)
% for clRUN =  415:numel(inputCSVs)
    clusterID = Epsilon_Check.UnitID{clRUN};
    if strcmp(clusterID, clusterID_old), continue; end
%     if ~strcmp(Epsilon_Check.Region(clRUN),'CA3'), continue; end
    clusterID_old=clusterID;
    ide = find(strcmp(clusterID,Epsilon_Check.UnitID));
    if isempty(ide), continue; end
    if Epsilon_Check.Filter(ide(1)), continue; end
    findHYPEN = strfind(clusterID,'-');
    thisRID = clusterID(1:findHYPEN(1)-1);
    thisSID = clusterID(findHYPEN(1)+1:findHYPEN(2)-1);
    thisTTID = clusterID(findHYPEN(2)+1:findHYPEN(3)-1);
    thisCLID = clusterID(findHYPEN(3)+1:end);
    sessionID = [thisRID '-' thisSID];
        row = find(ismember(Recording_region.SessionID,sessionID));
    col = Recording_region.(['TT' num2str(thisTTID)]);
    RegionIndex = cell2mat(col(row));
    
    if strcmp(RegionIndex,'Subiculum') || strcmp(RegionIndex,'CA1') || strncmp(RegionIndex,'CA3',3)
    
 IndexC = strfind(DivPnts{:,1},sessionID);
Index = find(not(cellfun('isempty',IndexC)));
DivPt = DivPnts{Index,2};
%     if strcmp(RegionIndex,'Subiculum') RegionIndex='SUB'; end
    
    try
    clear idx_DBSCAN
    clusterID = Epsilon_Check.UnitID{clRUN};
    load([SaveROOT.mat '\rat' clusterID '.mat'],'PHASE_mat'); % DBSCAN_parameter
    PHASE_mat.IdxDBSCAN = zeros(size(PHASE_mat,1),1);
        %% DBSCAN 
         load([DatROOT '\variables for display\rat' clusterID '.mat'],'raster_plot_all')
         id = knnsearch(raster_plot_all(:,1),PHASE_mat.aligned_ts);
   
%     PHASE_mat.area = raster_plot_all(id,3);
    thisPHASE = PHASE_mat(PHASE_mat.area > 0 &PHASE_mat.area < 6 & PHASE_mat.correctness==1 & PHASE_mat.run_epoch,:);
    thisPHASE(thisPHASE.linearized_pos==500,:) = [];
   
   if size(thisPHASE,1)<10
       disp([clusterID ': less #spikes']);
       continue;
   end
%       X = [PHASE_mat.linearized_pos PHASE_mat.phase];
    X = [thisPHASE.linearized_pos thisPHASE.phase];
    Xn = size(X,1);
    X = repmat(X,3,1);
    X(Xn+1:2*Xn,2) = X(Xn+1:2*Xn,2) + 360;
    X(2*Xn+1:3*Xn,2) = X(2*Xn+1:3*Xn,2) + 360*2;
    
    imagePosition = [100 600 300 380];
    f=figure('position',[100 100 300 380],'color','white');
    plot(X(:,1),X(:,2),'k.','markersize',4);
    set(gca,'xdir','rev','ytick',-180 : 180 : 180*4);
    xlim([0 480]); ylim([-180 180*5]);
    title(['rat' clusterID]);
    
    % clustering
    load([SaveROOT.mat '\rat' clusterID '.mat'],'DBSCAN_parameter');
    if exist('DBSCAN_parameter')
        epsilon=DBSCAN_parameter.epsilon; 
        MinPts=DBSCAN_parameter.MinPts;  
        minSize=DBSCAN_parameter.minSize;
        
        idx_DBSCAN.temp = DBSCAN(X,epsilon(1),MinPts(1));
        
        for i = 1 : max(idx_DBSCAN.temp)
            if sum(idx_DBSCAN.temp == i) < minSize(1)
                idx_DBSCAN.temp(idx_DBSCAN.temp == i) = 0;
            end
        end
        
        
        f = figure('position',imagePosition,'color','white');
        PlotClusterinResult(X, idx_DBSCAN.temp);
        hold on
        if length(epsilon)>=2 && epsilon(2)~=0
            idx_DBSCAN.temp2 = DBSCAN(X(~idx_DBSCAN.temp,:),epsilon(2),MinPts(2));
            for i = 1 : max(idx_DBSCAN.temp2)
                if sum(idx_DBSCAN.temp2 == i) < minSize(2)
                    idx_DBSCAN.temp2(idx_DBSCAN.temp2 == i) = 0;
                end
            end
        PlotClusterinResult(X(~idx_DBSCAN.temp,:), idx_DBSCAN.temp2);
        end
        set(gca,'xdir','rev','ytick',-180 : 180 : 180*4);
        xlim([0 480]); ylim([-180 180*5]);
        xlabel(['e=' num2str(epsilon) ', minPts=' num2str(MinPts)]);
        title(['rat' clusterID ' (' RegionIndex ')']);
        
%         flag = input('Edit Params(y1/n0): ','s');
    else
        flag = 'y';
    end
    
    if ~or(strcmp(flag,'n'),strcmp(flag,'0'))
%     for t=1:2
if Epsilon_Check.MinPts1(clRUN)<10, alpha=20; else alpha=0; continue; end
for eps=20:Epsilon_Check.Epsilon1(clRUN)+alpha
    t=1;
    if t==2
        flag = 'y';
        X2=X(~idx_DBSCAN.prep,:);
    else
        X2=X;
        end
%         while ~or(strcmp(flag,'n'),strcmp(flag,'0'))
            
%             epsilon(t) =   str2double(input(['epsilon #' num2str(t) ': '],'s'));
%             MinPts(t) =   str2double(input(['MinPts #' num2str(t) ': '],'s'));
%             minSize(t) =  str2double(input(['MinSz #' num2str(t) ': '],'s'));
            
            epsilon(1) =   eps;
            MinPts(1) =   10;
            minSize(1) =  10;
            
            if epsilon(t)==0
                break;
            end
            idx_DBSCAN.prep = DBSCAN(X2,epsilon(t),MinPts(t));
            for i = 1 : max(idx_DBSCAN.prep)
                if sum(idx_DBSCAN.prep == i) < minSize(t)
                    idx_DBSCAN.prep(idx_DBSCAN.prep == i) = 0;
                end
            end
            
            f = figure('position',imagePosition,'color','white');
            PlotClusterinResult(X2, idx_DBSCAN.prep);
            set(gca,'xdir','rev','ytick',-180 : 180 : 180*4);
            xlim([0 480]); ylim([-180 180*5]);
            xlabel(['e=' num2str(epsilon(t)) ', minPts=' num2str(MinPts(t))]);
            title(['rat' clusterID ' (DBSCAN: k=' num2str(max(idx_DBSCAN.prep)) ')']);
            
            
%             flag = input('Edit Params(y/n): ','s');
%         end
        cd([SaveROOT.fig '\' cell2mat(Epsilon_Check.Region(clRUN))])
        if ~exist(clusterID), mkdir(clusterID); end
        saveas(f,[clusterID '\' 'E' num2str(epsilon(1)) '_' num2str(t) '.jpg']);  
                 Epsilon_Check.(['Epsilon' num2str(t+2)])(ide) = epsilon(t);
   Epsilon_Check.(['MinPts' num2str(t+2)])(ide) = MinPts(t);
    end
      

    end
 
    
    DBSCAN_parameter.epsilon = epsilon;
    DBSCAN_parameter.MinPts = MinPts;
    DBSCAN_parameter.minSize = minSize;
 
    % save
        idx_DBSCAN.temp = DBSCAN(X,epsilon(1),MinPts(1));
        idx_DBSCAN.final = zeros(length(idx_DBSCAN.temp),1);
        j=1;
        for i = 1 : max(idx_DBSCAN.temp)
            if sum(idx_DBSCAN.temp == i) < minSize(1)
                idx_DBSCAN.temp(idx_DBSCAN.temp == i) = 0;
                idx_DBSCAN.final(idx_DBSCAN.temp == i) = 0;
            else
                idx_DBSCAN.final(idx_DBSCAN.temp == i) = j;
                j=j+1;
            end
        end
        
        
%         f = figure('position',imagePosition,'color','white');
% %         PlotClusterinResult(X, idx_DBSCAN.temp);
%         id2 = find(~idx_DBSCAN.temp);
%         hold on
%         if length(epsilon)>=2 && epsilon(2)~=0
%             idx_DBSCAN.temp2 = DBSCAN(X(~idx_DBSCAN.temp,:),epsilon(2),MinPts(2));
%             for i = 1 : max(idx_DBSCAN.temp2)
%                 if sum(idx_DBSCAN.temp2 == i) < minSize(2)
%                     idx_DBSCAN.temp2(idx_DBSCAN.temp2 == i) = 0;
%                     idx_DBSCAN.final(id2(idx_DBSCAN.temp2 == i)) = 0;
%                 else
%                     idx_DBSCAN.final(id2(idx_DBSCAN.temp2 == i)) = j;
%                     j=j+1;
%                 end
%             end
%         
%         else
%             epsilon(2)=[]; MinPts(2)=[];
%         end
%         PlotClusterinResult(X, idx_DBSCAN.final);
%         set(gca,'xdir','rev','ytick',-180 : 180 : 180*4,'xtick',[0 DivPt 480]);
%         xticklabels({'FW', 'DivPnt', 'Start'})
%         xlim([0 480]); ylim([-180 180*5]);
%         xlabel(['e=' num2str(epsilon) ', minPts=' num2str(MinPts)]);
%         title(['rat' clusterID ' (' RegionIndex ')']);

      

        
%         saveImage(f,[SaveROOT.fig '\rat' clusterID '_DBSCAN.jpg'],'pixels',imagePosition);      
    
%     save([SaveROOT.mat '\rat' clusterID '.mat'],'thisPHASE','DBSCAN_parameter','-append');

   
    clear epsilon MinPts minSize DBSCAN_parameter
    close all
    catch
        disp([clusterID ' DBSCAN failed']);
    end
    end
end