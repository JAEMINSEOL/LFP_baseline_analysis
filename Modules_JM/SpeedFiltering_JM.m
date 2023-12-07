% Original version by LHW
% Edited by SJM (20.09.20)

%% spike filtering by speed
clear; clc; fclose all;
addpath(genpath('D:\HPC-LFP project\SUB-CA1\'))
RATLIST.SC = {'232', '234', '295','415','561'};
RATLIST.DC = {'313','425','454','471','487','553','562'};
%% set ROOTs
MotherROOT = 'D:\HPC-LFP project';
InfoROOT = [MotherROOT '\Information Sheet'];
DataROOT = [MotherROOT '\RawData'];
ParsedROOT = [MotherROOT '\Parsed Data'];
saveROOT.mat = [ParsedROOT '\Theta phase\mat files (new ref)'];
% cd(saveROOT.mat);

%% speed filtering parameters
threshold = 20; %filtering하는 속력 최솟값
grpint = 6;  %Threshold 미만의 속력 값이 얼마나 오래 유지되어야 immobile 상태로 볼 것인지
min_duration = 1; % 두 immobile epoch 사이 시간의 최솟값 (immobile epoch 중간에 noise가 생겨도 무시하기 위함)
thisRID_old='N';
%% load clusterID list
SelectedTT = csvread([InfoROOT '\SelectedTT.csv'],1,0);
[~, inputCSVs] = xlsread([InfoROOT '\ClusterList.csv']);
Recording_region = readtable([InfoROOT '\Recording_region.csv']);
clear RatTime RatVelocity
for clRUN =225:225 %(cluster 파일에 대해서 돌렸던 모듈이라 cluster list 순서대로 진행합니다. 모든 TT에 대해 할 경우 list를 바꿔줘야 합니다)
    
    clusterID = inputCSVs{clRUN};
    
    findHYPEN = strfind(clusterID,'-');
    thisRID = clusterID(1:findHYPEN(1)-1);
    thisSID = clusterID(findHYPEN(1)+1:findHYPEN(2)-1);
    thisTTID = clusterID(findHYPEN(2)+1:findHYPEN(3)-1);
    thisCLID = clusterID(findHYPEN(3)+1:end);
    sessionID = [thisRID '-' thisSID];
    
    
    if ~strcmp(thisRID,thisRID_old)
        %         load([ParsedROOT '\7-12Hz filtered\rat' thisRID '-Theta.mat']);
        thisRID_old = thisRID;
    end
    row = find(ismember(Recording_region.SessionID,sessionID));
    col = Recording_region.(['TT' num2str(thisTTID)]);
    thisRegion = cell2mat(col(row));
    if strcmp(thisRegion,'Subiculum') thisRegion='SUB'; end
    
    
    
    disp(['rat' clusterID ' start']);
    
    
    %                 DivID = ThetaP.(['rat' thisRID '_' thisSID '_tt' num2str(thisTTID) '_index']);
    %% load spike phase data
    if exist([saveROOT.mat '\rat' clusterID '.mat'])
        load([saveROOT.mat '\rat' clusterID '.mat'],'PHASE_mat');
        
        %% load sensor timestamp data
        load([DataROOT '\variables for display' '\rat' thisRID '-' thisSID '.mat'],'sensor_timestamp');
        sensor_timestamps = array2table(sensor_timestamp,'VariableNames',{'Start','S1','S2','S3','S4','Foodwell','End'});
        
        %% load position data
        sessionROOT = [DataROOT '\rat' thisRID '\rat' thisRID '-' thisSID];
        % load([sessionROOT '\parsedPosition.mat'],'t','y','x','side','trial','correctness','area','cont','ambiguity');
        load([sessionROOT '\parsedPosition.mat'],'t','x','y','trial','area');
        
        for trial_iter3 = 1:size(trial,2)
            tstart = t(trial(:,trial_iter3));
            if isempty(find(and(mean(tstart)>=sensor_timestamp(:,1),mean(tstart)<=sensor_timestamp(:,7))))
                trial(:,trial_iter3)=0;
            end
        end
        trial(:,~max(trial,[],1))=[];
        
        y_linearized = get_linearized_position(MotherROOT,clusterID);
        
        %% get instant speed (1D)
        
%         smoothing_method = 'rlowess';
        
        velocity1D = cell(size(trial,2),1);
        stop_epoch1D = cell(size(trial,2),2); % 1: aligned timestamps / 2: raw timestamps
        PHASE_mat.run_epoch = ones(size(PHASE_mat,1),1);
        
        for trial_iter = 1 : size(sensor_timestamps,1)
            
            % get timestamp within trial outbound
            this_t = t(trial(:,trial_iter) );
            this_t = this_t - sensor_timestamps.Start(trial_iter);
            
            % get position data
            this_pos = y_linearized(trial(:,trial_iter));
            
            % linear interpolation for outlier position data
            for i = 2 : length(this_pos)-1
                if abs(this_pos(i) - this_pos(i-1))> 50
                    this_pos(i) = mean([this_pos(i+1),this_pos(i-1)]);
                end
            end
            
            % remove nan position
            this_t(isnan(this_pos)) = [];
            this_pos(isnan(this_pos)) = [];
            
            % smoothing position data (to deal with outlier)
            this_pos_raw = this_pos;
            %         this_pos = smooth(this_pos,5,smoothing_method);
            
            % get speed
            bin_size = 5;
            bin_range = [1:1:bin_size] - ceil(bin_size/2);
            
            this_speed = nan(length(this_t),1);
            for t_iter = 1 : length(this_t)
                temp_range = t_iter + bin_range;
                temp_range(temp_range<1 | temp_range>length(this_t)) = [];
                if length(temp_range) < ceil(bin_size/2)+1, continue; end % speed not assigned at both ends of position data
                
                temp_distance = this_pos(temp_range(1)) - this_pos(temp_range(end));
                temp_time = this_t(temp_range(end)) - this_t(temp_range(1));
                
                this_speed(t_iter) = (temp_distance*0.2) / temp_time; % centimeter/sec
            end
            this_velocity = abs(this_speed); %
            
            % get spike phase (개별 spike의 speed 분석에서만 사용)
            this_spk = PHASE_mat(PHASE_mat.trial==trial_iter & PHASE_mat.area>0 & PHASE_mat.area<6,:);
            this_spk_rep = this_spk; this_spk_rep.phase = this_spk.phase + 360; % for display
             this_spk_rep = [this_spk; this_spk_rep]; % for display
            
            
            %% extract immobile epochs (speed filtering)
            
            stop_idx = find(this_velocity < threshold | isnan(this_velocity));
            
            this_stop_epoch = [];
            this_stop_epoch(end+1,1) = stop_idx(1);
            for i = 2 : length(stop_idx)
                if stop_idx(i) - stop_idx(i-1) > grpint
                    this_stop_epoch(end,2) = stop_idx(i-1);
                    this_stop_epoch(end+1,1) = stop_idx(i);
                end
            end
            this_stop_epoch(end,2) = stop_idx(end);
            this_stop_epoch(this_stop_epoch(:,2)-this_stop_epoch(:,1) < min_duration,:) = [];
            
            % expand both ends of stop epoch
            this_stop_epoch(:,1) = this_stop_epoch(:,1) - 1;
            this_stop_epoch(:,2) = this_stop_epoch(:,2) + 1;
            this_stop_epoch(this_stop_epoch==0)  = 1;
            this_stop_epoch(this_stop_epoch==length(this_t)+1) = length(this_t);
            
            this_stop_epoch(:,1) = this_t(this_stop_epoch(:,1));
            this_stop_epoch(:,2) = this_t(this_stop_epoch(:,2));
            
            %% extract spike during immobile epochs
            
            filtered_spk = false(size(this_spk_rep,1),1);
            filtered_spk(this_spk_rep.aligned_ts<this_t(1)) = true;
            
            for epoch_iter = 1 : size(this_stop_epoch,1)
                this_epoch = this_stop_epoch(epoch_iter,:);
                filtered_spk(this_spk_rep.aligned_ts>=this_epoch(1) & this_spk_rep.aligned_ts<=this_epoch(2)) = true;
            end
            
            %% verification
            
            %         display_trialSpeedSheet_JM;
            %         hold on
            % %
            %         saveROOTfig = ['D:\SUB-CA1 Ephys\3. LFP Data\4. Phase\Speed filtering\Verification per trial\rat' clusterID '\' ...
            %             sprintf('thr%d gap%d bin%d',threshold,grpint,bin_size)];
            %         if ~exist(saveROOTfig,'dir'), mkdir(saveROOTfig); end
            %         saveImage(f,[saveROOTfig '\rat' clusterID '_trial' num2str(trial_iter) '.jpg'],'pixels',imagePosition);
            
            %% set variables to be saved
            
            % velocity for each trial
            velocity1D{trial_iter} = this_velocity;
            
            % filtered epoch for each trial
            stop_epoch1D{trial_iter,1} = this_stop_epoch;
            stop_epoch1D{trial_iter,2} = this_stop_epoch + sensor_timestamps.Start(trial_iter);
            
            %         filtered spikes for each trial
            PHASE_mat.run_epoch(PHASE_mat.trial==trial_iter & PHASE_mat.area>0 & PHASE_mat.area<6) = ~filtered_spk(1:length(filtered_spk)/2);
            %%
            %                 if thisSStype==2
            %                     if trial_iter<20
            %                     RatTime.STDinAMB(clRUN).(['Trial' num2str(trial_iter)]) = this_t;
            %                 RatVelocity.STDinAMB(clRUN).(['Trial' num2str(trial_iter)]) = this_velocity;
            %                     else
            %                         RatTime.AMB(clRUN).(['Trial' num2str(trial_iter)]) = this_t;
            %                 RatVelocity.AMB(clRUN).(['Trial' num2str(trial_iter)]) = this_velocity;
            %                     end
            %                 elseif thisSStype==1
            %                 RatTime.STD(clRUN).(['Trial' num2str(trial_iter)]) = this_t;
            %                 RatVelocity.STD(clRUN).(['Trial' num2str(trial_iter)]) = this_velocity;
            %                 end
            
            
            %                 VelocityMean.(['Rat' thisRID '_' thisSID])(SelectedTT(clRUN,4),trial_iter) = nanmean(this_velocity);
            %                 [VMean(trial_iter,:,thisTTID)]= Mean_Velocity_Trial_JM(DivID,this_velocity,this_t,trial_iter);
            
        end % for trial_iter
        %     save(['NormalizedPower' thisRID '-' thisSID '.mat'],'PMean')
        
        
        %% speed-filtered phase-position display
        thisPHASE = PHASE_mat(PHASE_mat.area > 0 & PHASE_mat.area < 6 & PHASE_mat.correctness==1 & PHASE_mat.run_epoch,:);
        %     thisPHASE = PHASE_mat(PHASE_mat.area > 0 & PHASE_mat.area < 6 & PHASE_mat.correctness==1,:);
        thisPHASE(thisPHASE.linearized_pos==500,:) = [];
        
        X = [thisPHASE.linearized_pos thisPHASE.phase];
        Xn = size(X,1);
        X = repmat(X,3,1);
        X(Xn+1:2*Xn,2) = X(Xn+1:2*Xn,2) + 360;
        X(2*Xn+1:3*Xn,2) = X(2*Xn+1:3*Xn,2) + 360*2;
        %
        %     %
        %     imagePosition = [2650 800 300 380];
        %     f=figure('position',imagePosition,'color','white');
        %     plot(X(:,1),X(:,2),'k.','markersize',4);
        %     set(gca,'xdir','rev','ytick',-180 : 180 : 180*4);
        %     xlim([0 480]); ylim([-180 180*5]);
        %     title(['rat' clusterID]);
        %     xlabel(['threshold = ' num2str(threshold) 'cm/s']);
        %
        %     saveROOTfig = ['D:\SUB-CA1 Ephys\3. LFP Data\4. Phase\Speed filtering\Verification theta phase\' ...
        %         sprintf('thr%d gap%d bin%d',threshold,grpint,bin_size)];
        %     if ~exist(saveROOTfig,'dir'), mkdir(saveROOTfig); end
        %     saveImage(f,[saveROOTfig '\rat' clusterID '.jpg'],'pixels',imagePosition);
        %
        %     %% save
        
        %     % parameters
        %     epoch_filtering_paramters = struct('smoothing_method',smoothing_method,'position_window',bin_size, ...
        %         'velocity_threshold',threshold,'grouping_interval',grpint,'min_duration',min_duration);
        %
        %     save([saveROOT.mat '\rat' clusterID '.mat'],'PHASE_mat','epoch_filtering_paramters','velocity1D','stop_epoch1D','-append');
        
        save([saveROOT.mat '\rat' clusterID '.mat'],'PHASE_mat');
        %
        %     %%
        disp(['rat' clusterID ' done']);
        clear PHASE_mat epoch_filtering_paramters velocity1D stop_epoch1D y_linearized;
        %     save(['D:\HPC-LFP project\SpeedAnalysis\MeanVelocity' thisRID '-' thisSID '-' thisRegion '.mat'],'VMean')
    end
end

%% Velocity histogram of each trials
% Comul_Pr=[];
% bin = [0.1:2:120.1];
% figure;
% for j=1:3
%     if j==1 Type='STD'; elseif j==2 Type='AMB'; else Type='STDinAMB'; end
% Ain = squeeze(struct2cell(RatVelocity.(Type)));
% h(j)=histogram(cell2mat(cellfun(@(x)x(:),Ain(:),'un',0)),bin,'Normalization','probability');
% Prob(j,:) = h(j).Values;
% for i = 1:length(h(j).Values)
%     Comul_Pr(j,i) = sum(h(j).Values(1:i));
% end
% % title('STD'); xlim([0 120]); xlabel('1D velocity(cm/s)'); ylim([0 0.11]); ylabel('Probability')
% end
% %%
% figure;
% for j=1:3
% plot([0:2:118],Comul_Pr(j,:),'LineWidth',2)
% hold on
% end
% %%
% figure;
% for j=1:3
% plot([0:2:118],Prob(j,:),'LineWidth',2)
% hold on
% end
% legend({'STD','AMB','AMB-Initial 20 trials'},'Location', 'northeast')
% xlim([0 120]); xlabel('1D velocity(cm/s)'); ylim([0 0.1]); ylabel('Comulative Probability')
