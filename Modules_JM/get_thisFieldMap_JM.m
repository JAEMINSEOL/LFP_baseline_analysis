%% extract clustered spikes using predefined DBSCAN parameters
% if sum(ismember(inputCSVs,clusterID))
%     thisPHASE = getDBSCAN(clusterID,SaveROOT,1);
%     
%     thisPHASE.cluster(thisPHASE.cluster > 1) = 1;
%     
% elseif sum(ismember(inputCSVs3,clusterID))
%     thisPHASE = getDBSCAN(clusterID,saveROOT,0);
%     
%     % match the phase ranges between two clusters
%     base_cluster = inputCSVn3(ismember(inputCSVs3,clusterID),1);
%     change_cluster = inputCSVn3(ismember(inputCSVs3,clusterID),2);
%     phase_range = [min(thisPHASE.phase(thisPHASE.cluster==base_cluster)) max(thisPHASE.phase(thisPHASE.cluster==base_cluster))];
%     
%     phase_under_range = thisPHASE.phase(thisPHASE.phase < phase_range(1) & thisPHASE.cluster == change_cluster);
%     
%     thisPHASE.cluster(ismember(thisPHASE.phase,phase_under_range + 360)) = change_cluster;
%     thisPHASE.cluster(ismember(thisPHASE.phase,phase_under_range)) = 0;
%     
% elseif strcmp(clusterID,'234-04-18-06')
%     thisPHASE = getDBSCAN(clusterID,saveROOT,1);
%     
%     thisPHASE.cluster(thisPHASE.cluster ~= 0 & thisPHASE.phase >= 80 & thisPHASE.phase < 440) = 3;
%     thisPHASE.cluster(thisPHASE.cluster==1) = 0;
%     thisPHASE.cluster(thisPHASE.cluster==2) = 0;
%     thisPHASE.cluster(thisPHASE.cluster==3) = 1;
%     
% elseif strcmp(clusterID,'415-13-13-01')
%     thisPHASE = getDBSCAN(clusterID,saveROOT,0);
%     
%     thisPHASE.phase(thisPHASE.cluster ~= 0 & thisPHASE.phase >= 500) = thisPHASE.phase(thisPHASE.cluster ~= 0 & thisPHASE.phase >= 500) - 360;
%     
% elseif strcmp(clusterID,'234-04-20-01')
%     thisPHASE = getDBSCAN(clusterID,saveROOT,0);
%     
%     thisPHASE.cluster(thisPHASE.cluster > 1) = 1;
%     
% elseif strcmp(clusterID,'232-05-19-03')
%     thisPHASE = getDBSCAN(clusterID,saveROOT,1);
%     
%     thisPHASE.cluster(thisPHASE.cluster == 1) = 0;
%     thisPHASE.cluster(thisPHASE.cluster == 3) = 1;
%     
% elseif strcmp(clusterID,'232-07-4-05')
%     thisPHASE = getDBSCAN(clusterID,saveROOT,0);
%     
%     thisPHASE.cluster(ismember(thisPHASE.phase,thisPHASE.phase(thisPHASE.cluster == 2 & thisPHASE.phase < 130) + 360)) = 2;
%      thisPHASE.cluster(thisPHASE.cluster == 2 & thisPHASE.phase < 130) = 0;     
%     
% elseif strcmp(clusterID,'232-07-4-06')
%     thisPHASE = getDBSCAN(clusterID,saveROOT,1);
%     thisPHASE.cluster(thisPHASE.cluster == 1) = 0;
%     thisPHASE.cluster(thisPHASE.cluster == 2) = 1;
%     thisPHASE.cluster(thisPHASE.cluster == 3) = 2;
%     
% elseif strcmp(clusterID,'232-07-20-08')
%     thisPHASE = getDBSCAN(clusterID,saveROOT,0);
%     thisPHASE.cluster(thisPHASE.linearized_pos>370 & thisPHASE.cluster>0) = 4;
%     
% else
    thisPHASE = getDBSCAN(clusterID,SaveROOT,0);
    
% end

%% extract valid clusters
if ~isempty(thisPHASE)
    
    thisPHASE_backup = thisPHASE; % for display
    thisPHASE(thisPHASE.cluster==0,:) = [];
    nCluster = max(thisPHASE.cluster);
    if isempty(nCluster), nCluster = 0; end
    
    % get thisFieldMap
    thisFieldMap = cell(nCluster,1);
    
    for field_iter = 1 : nCluster
        
        thisField = thisPHASE(thisPHASE.cluster == field_iter,:);
        %         if max(thisField.phase) > 270, thisField.phase = thisField.phase - 360; end
        
        %% 1D rate map and basic firing properties
        
        thisFieldMap{field_iter} = getFieldMaps_JM(clusterID,thisField,'session',DatROOT.raw,InfoROOT,clRUN);
        
        field_skaggs = thisFieldMap{field_iter}.skaggsMap1D{overallMap_index(session_type)};
        field_skaggs(field_skaggs==0) = nan;
        
        temp_field_rate = thisFieldMap{field_iter}.onmazeMaxFR1D(overallMap_index(session_type));
        temp_field_index = find(field_skaggs==temp_field_rate,1);
        
        %% spatial field size
        %     threshold = temp_field_rate * 0.25;
        %     temp_range = find(field_skaggs >= threshold);
        %     temp_range = [temp_range(1) temp_range(end)];
        
        thisFieldMap{field_iter}.field_size = (max(thisField.linearized_pos) - min(thisField.linearized_pos) + 1) * 0.2; % cm
        thisFieldMap{field_iter}.field_range = 48 - [round(max(thisField.linearized_pos)/10) round(min(thisField.linearized_pos)/10)];
        
        %     field_skaggs_filtered = field_skaggs;
        %     field_skaggs_filtered( (thisFieldMap{field_iter}.field_range(1) : thisFieldMap{field_iter}.field_range(end))) = nan;
        
        %% phase precession properties
        
        % phase range
        thisFieldMap{field_iter}.phase_size = max(thisField.phase) - min(thisField.phase) + 1; % degree
        thisFieldMap{field_iter}.phase_range = [min(thisField.phase) max(thisField.phase)]; % degree
        
        
        %% phase precession rate (slope) & strength%% get a linear regression line
            y = thisField.phase;
            x = thisField.linearized_pos;
            X = [ones(size(x)) x];
            B = X\y;
            Rsq = 1 - sum((y - X*B).^2)/sum((y - mean(y)).^2);
            thisFieldMap{field_iter}.slope = B(2) * 1/0.2;  % deg/cm
        
        modelspec = 'phase ~ linearized_pos';
        mdl = fitlm(thisField(:,{'phase','linearized_pos'}),modelspec);
        
        thisFieldMap{field_iter}.linear_mdl = mdl;
        
%         x = linspace(0,max_position*10)';
%         y = predict(mdl,x);
        
        % both methods have same results
        
    end
    
    %% get RDI
    
    load([rasterROOT '\rat' clusterID '.mat'],'trial_set_all');
    sample_idx = [];

    
    if max(trial_set_all(:,2))<=4
    % get RID_std
    for scene_iter = 1 : 4
        sample_idx(:,scene_iter) = trial_set_all(:,2) == scene_iter & trial_set_all(:,3) == 1;
    end
    sample_idx = logical(sample_idx);
    sample_idx_cond = {[sample_idx(:,1) sample_idx(:,2)],[sample_idx(:,3) sample_idx(:,4)],[sample_idx(:,1)|sample_idx(:,2) sample_idx(:,3)|sample_idx(:,4)]};
    
    d = nan(nCluster,3); p = nan(nCluster,3);
    d_shuffled_array = cell(1,nCluster); d_shuffled = nan(nCluster,3);
    for field_iter = 1 : nCluster
            if thisFieldMap{field_iter}.field_range(1)==0, thisFieldMap{field_iter}.field_range(1)=1;end
        thisField = thisPHASE(thisPHASE.cluster == field_iter,:);
        thisFieldMap1D_trial = getFieldMaps(clusterID,thisField,'trial',MotherROOT);
        thisFieldMap1D_trial =  thisFieldMap1D_trial(thisFieldMap{field_iter}.field_range(1):thisFieldMap{field_iter}.field_range(2),:);
        
        for cond_iter = 1 : 3                        
            sample1 = nanmean(thisFieldMap1D_trial(:,sample_idx_cond{cond_iter}(:,1)));
            sample2 = nanmean(thisFieldMap1D_trial(:,sample_idx_cond{cond_iter}(:,2)));
            
            d(field_iter,cond_iter) = computeCohen_d(sample1, sample2);
            
            [~, p(field_iter,cond_iter)] = ttest2(sample1,sample2);
        end
        
        thisFieldMap{field_iter}.d = d(field_iter,:);
        thisFieldMap{field_iter}.p = p(field_iter,:);
%         
%         % shuffled RDI
%         
%         for cond_iter = 1 : 3
%             for shuffle_iter = 1 : 10000
%                 
%                 sample1 = nanmean(thisFieldMap1D_trial(:,sample_idx_cond{cond_iter}(:,1)));
%                 sample2 = nanmean(thisFieldMap1D_trial(:,sample_idx_cond{cond_iter}(:,2)));
%                 
%                 temp_sample = [sample1 sample2; ones(size(sample1))*1 ones(size(sample2))*2];
%                 temp_rand = randperm(size(temp_sample,2));
%                 temp_sample(1,:) = temp_sample(1,temp_rand);
%                 
%                 temp_sample1 = temp_sample(1,temp_sample(2,:)==1);
%                 temp_sample2 = temp_sample(1,temp_sample(2,:)==2);
%                 
%                 d_shuffled_array{field_iter}(shuffle_iter,cond_iter) = calculate_cohensD_function(temp_sample1, temp_sample2);
%                 
%             end
%             
%             d_shuffled(field_iter,cond_iter) = prctile(d_shuffled_array{field_iter}(:,cond_iter),95);
%         end
%         
    end
%     
    RDI.d = d; RDI.p = p; 
% RDI.d_shuffled = d_shuffled;  RDI.d_shuffled_array = d_shuffled_array;
%     

    else
% get RDI_amb

       for scene_iter = 1 : 6
           sample_idx(:,scene_iter) = mod(trial_set_all(:,2),10) == scene_iter & trial_set_all(:,3) == 1;
       end
       sample_idx = logical(sample_idx);
       sample_idx_cond = {[sample_idx(:,1) sample_idx(:,6)],[sample_idx(:,2) sample_idx(:,5)],[sample_idx(:,3) sample_idx(:,4)],...
           [sample_idx(:,1)|sample_idx(:,2)|sample_idx(:,3) sample_idx(:,4)|sample_idx(:,5)|sample_idx(:,6)]};
       
       
       d = nan(nCluster,4); p = nan(nCluster,4); m = nan(nCluster,6); sd = nan(nCluster,6);
       d_shuffled_array = cell(1,nCluster); d_shuffled = nan(nCluster,3);
        for field_iter = 1 : nCluster
            if thisFieldMap{field_iter}.field_range(1)==0, thisFieldMap{field_iter}.field_range(1)=1;end
        thisField = thisPHASE(thisPHASE.cluster == field_iter,:);
        thisFieldMap1D_trial = getFieldMaps(clusterID,thisField,'trial',MotherROOT);
        thisFieldMap1D_trial =  thisFieldMap1D_trial(thisFieldMap{field_iter}.field_range(1):thisFieldMap{field_iter}.field_range(2),:);
         for cond_iter = 1 : 6                     
            sample = nanmean(thisFieldMap1D_trial(:,sample_idx(:,cond_iter)));
            m(field_iter,cond_iter) = nanmean(sample);
            sd(field_iter,cond_iter) = nanstd(sample);
         end
         for cond_iter = 1 : 4
             sample1 = nanmean(thisFieldMap1D_trial(:,sample_idx_cond{cond_iter}(:,1)));
             sample2 = nanmean(thisFieldMap1D_trial(:,sample_idx_cond{cond_iter}(:,2)));
             
             d(field_iter,cond_iter) = computeCohen_d(sample1, sample2);
             
             [~, p(field_iter,cond_iter)] = ttest2(sample1,sample2);
         end
         
         thisFieldMap{field_iter}.d = d(field_iter,:);
         thisFieldMap{field_iter}.p = p(field_iter,:);
        end
            RDI.d = d; RDI.p = p;     RDI.m = m; RDI.sd = sd; 
    end
    clear sample_idx
    %% field sorting
    field_index = [];
    for field_iter = 1 : nCluster
        temp_field = thisFieldMap{field_iter}.skaggsMap1D{overall_map};
        field_index(field_iter,1) = find(temp_field == max(temp_field),1); % peak index
        field_index(field_iter,2) = thisFieldMap{field_iter}.field_range(1); % start index
    end
    
    if ~isempty(field_index)
        [~, field_order] = sortrows(field_index,[1 2]);
        
        thisFieldMap = thisFieldMap(field_order);
        RDI.d = RDI.d(field_order,:);
        RDI.p = RDI.p(field_order,:);
        
        thisPHASE_backup.cluster = thisPHASE_backup.cluster + 10;
        thisPHASE.cluster = thisPHASE.cluster + 10;
        for field_iter = 1 : nCluster
            thisPHASE_backup.cluster(thisPHASE_backup.cluster == field_iter+10) = find(field_order == field_iter);
            thisPHASE.cluster(thisPHASE.cluster == field_iter+10) = find(field_order == field_iter);
        end
        thisPHASE_backup.cluster(thisPHASE_backup.cluster == 10) = 0;
        thisPHASE.cluster(thisPHASE.cluster == 10) = 0;
    end
%     
%     %% get COM
%     getCOM;
    
    %% check cluster quality
    
    IsolDist = nan(nCluster,1); Lratio = nan(nCluster,1);
%     
    for field_iter = 1 : nCluster
        Fet = [thisPHASE_backup.phase thisPHASE_backup.linearized_pos];
        ClusterSpikes = find(thisPHASE_backup.cluster == field_iter);
        
        IsolDist(field_iter) = IsolationDistance(Fet, ClusterSpikes);
        [L, Lratio(field_iter), df] = L_Ratio(Fet, ClusterSpikes);
        
        thisFieldMap{field_iter}.IsolDist = IsolDist(field_iter);
        thisFieldMap{field_iter}.Lratio = Lratio(field_iter);
    end
    
    Cluster_quality.IsolDist = IsolDist;
    Cluster_quality.Lratio = Lratio;
    
     %% theta phase modulation strength
     for field_iter=1:nCluster
     PHASE_radian = thisPHASE_backup.phase(thisPHASE_backup.cluster==field_iter) * (pi/180); % change into radian
    
    thisPHASE_stat{field_iter} = [];
    
    % Rayleight's test for uniformity of phase distibution
    [thisPHASE_stat{field_iter}.pval,thisPHASE_stat{field_iter}.z] = circ_rtest(PHASE_radian);
    
    % preferred phase
    [thisPHASE_stat{field_iter}.mean] = circ_mean(PHASE_radian);
    [thisPHASE_stat{field_iter}.median] = circ_median(PHASE_radian);
    
    thisPHASE_stat{field_iter}.mean = thisPHASE_stat{field_iter}.mean / (pi/180);
    thisPHASE_stat{field_iter}.median = thisPHASE_stat{field_iter}.median / (pi/180);
    
    % mean resultant length
    thisPHASE_stat{field_iter}.MRL = circ_r(PHASE_radian);
     end
end % if ~isempty(thisPHASE)

