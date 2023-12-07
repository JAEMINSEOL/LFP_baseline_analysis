% Phase
% Original ver.

%%
clear; clc; fclose all;
warning off;

%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
ModulesROOT = [MotherROOT '\Analysis program'];
DatROOT = [MotherROOT '\RawData'];
SaveROOT = [MotherROOT '\Parsed Data\Theta phase\mat files (new ref)'];
FigROOT = [MotherROOT '\Plots'];

addpath(genpath(ModulesROOT))
rmpath(genpath([ModulesROOT '\Modules_CH']))
%% variables for loadCSC.m
% CSCfileTag = 'RateReduced_4-12filtered';
CSCfileTag = 'RateReduced_7-12filtered';
exportMODE = 0;
behExtraction = 1;
mode=1;

%% Load Cluster List
SelectedTT = csvread([InfoROOT '\SelectedTT.csv'],1,0);
[~, inputCSVs] = xlsread([InfoROOT '\ClusterList.csv']);
Recording_region = readtable([InfoROOT '\Recording_region.csv']);
%%
% for clRUN =  1:numel(inputCSVs)

for clRUN = 225:225
    clusterID = inputCSVs{clRUN};
    
    findHYPEN = strfind(clusterID,'-');
    thisRID = clusterID(1:findHYPEN(1)-1);
    thisSID = clusterID(findHYPEN(1)+1:findHYPEN(2)-1);
    thisTTID = clusterID(findHYPEN(2)+1:findHYPEN(3)-1);
    thisCLID = clusterID(findHYPEN(3)+1:end);
    sessionID = [thisRID '-' thisSID];
    
    
    row = find(ismember(Recording_region.SessionID,sessionID));
    col = Recording_region.(['TT' num2str(thisTTID)]);
    RegionIndex = cell2mat(col(row));
    if strcmp(RegionIndex,'Subiculum')
        RegionIndex='SUB'; thisRegionID = 1;
    elseif strcmp(RegionIndex, 'CA1')
        thisRegionID = 2;
    elseif strncmp(RegionIndex,'CA3',3)
        thisRegionID=3.5;
    else
        thisRegionID=0;
    end
    
    
    id = find(and(and(SelectedTT(:,1)==str2double(thisRID),SelectedTT(:,2)==str2double(thisSID)),abs(SelectedTT(:,4)-thisRegionID)<=0.5),1);
    session_type = SelectedTT(id,3);
    
    if thisRegionID~=0
        
        
        
        %% load sensor timestamps
        sensor_timestamp = get_diverging_timestamp(DatROOT,InfoROOT,thisRID,thisSID);
        sensor_timestamp_aligned = sensor_timestamp - sensor_timestamp(:,1);
        %% load SPK data
        if exist([DatROOT '\variables for display\rat' clusterID '.mat'])
            load([DatROOT '\variables for display\rat' clusterID '.mat'],'raster_plot_all','trial_set_all');
            raster_plot_all(raster_plot_all(:,1)<0,:) = [];
            trialN = size(trial_set_all,1);
            
            %% Make Selected LFP TT's 'EEG' structural variable
            LFPcscID = [thisRID '-' thisSID '-'   num2str(SelectedTT(id,5))];
            
            CSCdata = loadCSC(LFPcscID,DatROOT,CSCfileTag,exportMODE,behExtraction);
            [EEG.eeg,EEG.timestamps] = expandCSC(CSCdata);
            % get phase of eeg
            EEG.radian = angle(hilbert(EEG.eeg));
            EEG.phase = EEG.radian*(180/pi);
            
            %%
            %     try
            disp(['rat' clusterID ' start']);
            
            %% get phase of each spike
            if exist([SaveROOT '\rat' clusterID '.mat']) 
                
                proc = '(loaded)';
                load([SaveROOT '\rat' clusterID '.mat']);
%                 PHASE_mat=table2array(PHASE_mat);

            else
            
            [PHASE_mat(:,1:7)] = get_phase(EEG,raster_plot_all,sensor_timestamp);
            
            % y position linearization
            y_spk_linearized = yspk_linearization(DatROOT,InfoROOT,clusterID,sensor_timestamp,clRUN);
            
            PHASE_mat(:,8) = y_spk_linearized;
            
            % convert array to table
            if size(PHASE_mat,2)<9
                PHASE_mat = array2table(PHASE_mat,'VariableNames',{'phase','ts','aligned_ts','trial','area','scene','correctness','linearized_pos'});
            else
                PHASE_mat = array2table(PHASE_mat,'VariableNames',{'phase','ts','aligned_ts','trial','area','scene','correctness','linearized_pos','run_epoch'});
            end
            
            proc = '(made)';
                    end
            if exist([SaveROOT '\rat' clusterID '.mat'])
%                 save([SaveROOT '\rat' clusterID '.mat'],'PHASE_mat','-append');
            else
                save([SaveROOT '\rat' clusterID '.mat'],'PHASE_mat');
            end
            %     end
            % save([SaveROOT '\rat' clusterID '.mat'],'PHASE_mat');
            disp(['rat' clusterID  ' done' proc]);
            %         else
            %             disp(['rat' clusterID  ' already exist' proc]);
            %         end
            
            %     catch
            %         disp(['rat' clusterID ' : ERROR']);
            %     end
            %     clear PHASE_mat y_spk_linearized
            %     end
            % end
            if mode==1
                %% change scene number (ambiguity session only)
                
                if session_type == 2
                    %             if max(PHASE_mat.scene) < 8
                    
                    flag=1;
                    if strcmp(thisRID,'232'), last_STD = 19;
                    elseif strcmp(thisRID,'234'), last_STD = 14;
                    elseif strcmp(thisRID,'295'), last_STD = 20;
                    elseif strcmp(thisRID,'415'), last_STD = 20;
                    elseif strcmp(thisRID,'561'), last_STD = 20;
                    else, flag=0;
                    end
                    
                    if flag==1
                        PHASE_mat.scene(PHASE_mat.trial>last_STD & PHASE_mat.scene==6) = 8;
                        PHASE_mat.scene(PHASE_mat.trial>last_STD & PHASE_mat.scene==5) = 7;
                        PHASE_mat.scene(PHASE_mat.trial>last_STD & PHASE_mat.scene==4) = 6;
                        PHASE_mat.scene(PHASE_mat.trial<=last_STD & PHASE_mat.scene==4) = 5;
                        
                        PHASE_mat.scene(PHASE_mat.trial>last_STD & PHASE_mat.scene==3) = 4;
                        PHASE_mat.scene(PHASE_mat.trial>last_STD & PHASE_mat.scene==2) = 3;
                        PHASE_mat.scene(PHASE_mat.trial>last_STD & PHASE_mat.scene==1) = 2;
                        PHASE_mat.scene(PHASE_mat.trial<=last_STD & PHASE_mat.scene==1) = 1;
                    end
                    if exist([SaveROOT '\rat' clusterID '.mat'])
                        save([SaveROOT '\rat' clusterID '.mat'],'PHASE_mat','-append');
                    end
                end
                
                for loc=1:1
                    %             if loc==1
                    id1 = find(and(1,and(PHASE_mat.area>0, PHASE_mat.area<6)));
                    LocIndex='Outbound';
                    %             else
                    %                 id1 = find(and(PHASE_mat.run_epoch==1,PHASE_mat.area==6));
                    %                 LocIndex='Inbound';
                    %             end
                    
                    
                    
                    %% get 1D occ map with bin size 1
                    occMap1D = ypos_linearization(DatROOT,InfoROOT,clusterID);
                    
                    %% Gaussian smoothing
                    PHASE_matrix = phase_precession_smoothing(PHASE_mat(id1,:),occMap1D,13);
                    if exist([SaveROOT '\rat' clusterID '.mat'])
                        save([SaveROOT '\rat' clusterID '.mat'],'PHASE_matrix','-append');
                        disp('Success')
                        load([SaveROOT '\rat' clusterID '.mat'],'PHASE_matrix');
                    end
                    %% diplay polar plot
                    fig=figure('Position',[100 100 400 600]);
                    x = repmat(PHASE_mat.linearized_pos(id1),4,1);
                    y = vertcat(PHASE_mat.phase(id1),PHASE_mat.phase(id1)+360,PHASE_mat.phase(id1)+720,PHASE_mat.phase(id1)+1080);
                    scatter(x,y,4,'k','filled')
                    xlabel('Linearized Position'); ylabel('Spike Phase (deg)')
                    xlim([0 499]); ylim([-180 1000])
                    yticks([-180:180:720]);
                    if loc==1
                        set(gca, 'XDir','reverse')
                    end
                    title(['rat ' clusterID ' (' RegionIndex ',' LocIndex ')'])
                    saveImage(fig,[FigROOT '\SpikePhase_200910\rat' clusterID '(' RegionIndex ',' LocIndex ')' '.jpg'],'pixels',[100 100 400 600])
                    %                 if session_type == 1
                    %                     phase_display_std;
                    %                 elseif session_type == 2
                    %                     phase_display_amb;
                    %                 elseif session_type == 6
                    %                     phase_display_new;
                    %                 end
                    %
                    %                 phase_display_ver2;
                    %
                    %                 saveImage(f,[saveROOT.fig '\rat' clusterID '.jpg'],'pixels',imagePosition);
                    
                    %%
                end
            end
            disp(['rat' clusterID ' done']);
            
            
            %     catch
            %         disp(['rat' clusterID ' : ERROR']);
            %     end
            clear PHASE_mat y_spk_linearized
            
        end
    end
end

fclose all;
% delete(gcp);

warning on;