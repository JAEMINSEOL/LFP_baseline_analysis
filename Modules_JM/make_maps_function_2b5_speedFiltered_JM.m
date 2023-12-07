
function make_maps_function_2b5_speedFiltered_JM(clusterID, motherROOT, saveROOT,DivPnts)
%% Define variables

% skaggs' rate map variables
imROW = 480;
imCOL = 480;
thisFRMapSCALE = 10; % bin_size = thisFRMapSCALE
fixRadius = 3;  % original
% fixRadius = 9;  % smoothing ver
videoSamplingRate = 30;
%


%% Analyze clusterID & load data
findHYPHEN = find(clusterID == '-');

thisRID = clusterID(1, 1:findHYPHEN(1) - 1);
thisSID = clusterID(1, findHYPHEN(1) + 1:findHYPHEN(2) - 1);
thisTTID = clusterID(1, findHYPHEN(2) + 1:findHYPHEN(3) - 1);
thisCLID = clusterID(1, findHYPHEN(3) + 1:end);

% Load parsed position
area=1;
load([motherROOT '\rat' thisRID '\rat' thisRID '-' thisSID '\ParsedPosition.mat']);

% Load parsed spike
if exist([motherROOT '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' thisTTID '\parsedSpike_' thisCLID '.mat'])
load([motherROOT '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' thisTTID '\parsedSpike_' thisCLID '.mat']);
else
load([motherROOT '\rat' thisRID '\rat' thisRID '-' thisSID  '\TT' thisTTID '\parsedSpike_all.' num2str(str2double(thisCLID)) '.mat']);
end

%% get epoch-filtered spikes only

load([saveROOT '\Theta phase\mat files (new ref)\rat' clusterID '.mat'],'PHASE_mat');

filtered_spk = ismember(t_spk,PHASE_mat.ts(PHASE_mat.run_epoch == 1));
t_spk = t_spk(filtered_spk); x_spk = x_spk(filtered_spk); y_spk = y_spk(filtered_spk); 
cont_spk = cont_spk(filtered_spk,:); area_spk = area_spk(filtered_spk,:); correctness_spk = correctness_spk(filtered_spk,:);
ambiguity_spk = ambiguity_spk(filtered_spk,:);

%% Set variables depend on session_type

session_type = get_sessionType(thisRID, thisSID);

if session_type == 1, ratemap_number = 5;
elseif session_type == 6, ratemap_number = 3;   % new pair learning
elseif session_type == 7, ratemap_number = 7;  % 6 scene
else ratemap_number = 10; end
%


%% change context order
% before changing : zebra = 1, pebbles = 2, bamboo = 3, mountain = 4
% after changing : zebra = 1, pebbles = 3, bamboo = 2, mountain = 4
for iter = 1:size(t, 1)
    if cont(iter,2) == true
        cont(iter,2) = false;
        cont(iter,3) = true;
    elseif cont(iter,3) == true
        cont(iter,3) = false;
        cont(iter,2) = true;
    end
end

for iter = 1:size(t_spk, 1)
    if cont_spk(iter,2) == true
        cont_spk(iter,2) = false;
        cont_spk(iter,3) = true;
    elseif cont_spk(iter,3) == true
        cont_spk(iter,3) = false;
        cont_spk(iter,2) = true;
    end
end

for iter = 1:total_trial_number
    if trial_context(iter) == 2
        trial_context(iter) = 3;
    elseif trial_context(iter) == 3
        trial_context(iter) = 2;
    end
end
%
if exist(cont_handle)
    cont_handle=~cont_handle;
else
    cont_handle=1;
end

%% Count number of trials for each condition

trial_number = [];
if session_type == 1
    for iter = 1 : 4
        trial_number(iter + 1) = length(find(trial_correctness(find(trial_context == iter), 1) == 1));
    end
    trial_number(1) = sum(trial_number(2:5));
    
elseif session_type == 6    % new learning
    for iter = 5 : 6
        trial_number(iter - 4) = length(find(trial_correctness(find(trial_context == iter), 1) == 1));
    end
    trial_number(3) = sum(trial_number(1:2));
    
elseif session_type == 7    % 6 scenes
    for iter = 1 : 6
        trial_number(iter) = length(find(trial_correctness(find(trial_context == iter), 1) == 1));
    end
    trial_number(7) = sum(trial_number(1:6));
    
elseif sum(session_type == [2 3 4 5])
    temp = logical(zeros(total_trial_number, 1));
    temp(find(trial_correctness == 1)) = 1;
    
    for iter = 1 : 3
        temp2 = logical(zeros(total_trial_number, 1));
        temp3 = logical(zeros(total_trial_number, 1));
        
        temp2(find(trial_ambiguity == iter)) = 1;
        temp3([find(trial_context == 1) find(trial_context == 2)]) = 1;
        
        trial_number(iter + 3) = sum(temp & temp2 & temp3, 1);
        
        temp3 = logical(zeros(total_trial_number, 1));
        temp3([find(trial_context == 3) find(trial_context == 4)]) = 1;
        
        trial_number(iter + 6) = sum(temp & temp2 & temp3, 1);
        
        trial_number(iter) = trial_number(iter + 3) + trial_number(iter + 6);
    end
%     trial_number(10) = total_trial_number;
    
    trial_number(10) = sum(trial_number(4:9));
end

%


%% Load diverging point

%  diverging_point = get_divergingPoint(motherROOT, thisRID, thisSID);
    sessionID = [thisRID '-' thisSID];
IndexC = strfind(DivPnts{:,1},sessionID);
Index = find(not(cellfun('isempty',IndexC)));
diverging_point = DivPnts{Index,2};
% diverging_point = [];
% 
% cd([mother_root '\diverging_points']);
% fid = fopen('diverging_points.csv', 'r');
% fline = fgetl(fid);  % read header
% 
% fline = fgetl(fid);
% while ischar(fline)
%     [session_temp, diverging_point_temp] = strtok(fline, ',');
%     
%     if strcmp(session_temp, [thisRID '-' thisSID]);
%         diverging_point = str2num(diverging_point_temp);
%         break;
%     end
%     fline = fgetl(fid);
% end
% 
% if size(diverging_point) == 0
%     error('This session has no diverging point!');
% end
%

%



%% Set boundaries depend on track_type

Boundaries;

% xEdge = [325 395 395 475 475 245 245 325 325];
% yEdge = [480 480 160 160 70 70 160 160 480];
% 
% stem_boundary = [325, 325, 395, 395; 480, diverging_point, diverging_point, 480];
% 
% corner_boundary_left = [335, 335, 370, 370; 90, diverging_point, diverging_point, 90];
% corner_boundary_right = [335, 335, 380, 380; 80, diverging_point, diverging_point, 80];

%


%% Filtering (outbound)

pos = logical([]);
spks = logical([]);

if session_type == 1
    pos(:,1) = inpolygon(x, y, xEdge, yEdge);
    pos(:,1) = pos(:,1) & correctness(:,1) & ~area(:,5);
    spks(:,1) = inpolygon(x_spk, y_spk, xEdge, yEdge);
    spks(:,1) = spks(:,1) & correctness_spk(:,1) & ~area_spk(:,5);
    
    for iter = 1:4  % run for contexts
        pos(:,iter + 1) = pos(:,1) & cont(:,iter);
        spks(:,iter + 1) = spks(:,1) & cont_spk(:,iter);
    end
    
elseif session_type == 6    % new learning
    pos(:,3) = inpolygon(x, y, xEdge, yEdge);
    pos(:,3) = pos(:,3) & correctness(:,1) & ~area(:,5);
    spks(:,3) = inpolygon(x_spk, y_spk, xEdge, yEdge);
    spks(:,3) = spks(:,3) & correctness_spk(:,1) & ~area_spk(:,5);
    
    for iter = 5 : 6  % run for contexts
        pos(:,iter - 4) = pos(:,3) & cont(:,iter);
        spks(:,iter - 4) = spks(:,3) & cont_spk(:,iter);
    end
    
elseif session_type == 7    % 6 scenes
    
    pos(:,7) = inpolygon(x, y, xEdge, yEdge);
    pos(:,7) = pos(:,7) & correctness(:,1) & ~area(:,5);
    spks(:,7) = inpolygon(x_spk, y_spk, xEdge, yEdge);
    spks(:,7) = spks(:,7) & correctness_spk(:,1) & ~area_spk(:,5);
    
    for iter = 1 : 6
        pos(:,iter) = pos(:, 7) & cont(:,iter);
        spks(:,iter) = spks(:, 7) & cont_spk(:,iter);
    end
    
elseif sum(session_type == [2 3 4 5])
    pos(:,10) = inpolygon(x, y, xEdge, yEdge);
    pos(:,10) = pos(:,10) & correctness(:,1) & ~area(:,5);
    spks(:,10) = inpolygon(x_spk, y_spk, xEdge, yEdge);
    spks(:,10) = spks(:,10) & correctness_spk(:,1) & ~area_spk(:,5);
    
    for iter = 1:3  % run for ambiguity/trace conditions
        pos(:,iter) = inpolygon(x, y, xEdge, yEdge);
        pos(:,iter) = pos(:,iter) & correctness(:,1) & ~area(:,5) & ambiguity(:,iter);
        spks(:,iter) = inpolygon(x_spk, y_spk, xEdge, yEdge);
        spks(:,iter) = spks(:,iter) & correctness_spk(:,1) & ~area_spk(:,5) & ambiguity_spk(:,iter);
        
        pos(:,iter + 3) = pos(:,iter) & (cont(:,1) | cont(:,2));
        pos(:,iter + 6) = pos(:,iter) & (cont(:,3) | cont(:,4));
        spks(:,iter + 3) = spks(:,iter) & (cont_spk(:,1) | cont_spk(:,2));
        spks(:,iter + 6) = spks(:,iter) & (cont_spk(:,3) | cont_spk(:,4));
    end
end

%


%% Check number of spikes

% if sum(sum(spks)) < 5
%     disp(['rat' thisRID '-' thisSID '-' thisTTID '-' thisCLID ' has too small number of spks!']);
% 
%     numOfSpk=-1; trial_number=-1; realAvgFR=-1; onmazeMaxFR=-1;
%     SpaInfoScore=-1; oneDr_stem=zeros(10,10); oneDr_split=zeros(10,10); RMI_stem=zeros(10,10); RMI_split=zeros(10,10);
%     oneDz_stem=zeros(10,10); oneDz_split=zeros(10,10); oneDp_stem=zeros(10,10); oneDp_split=zeros(10,10); numOfSpk_stem(1:10)=-1;
%     disp(['rat' thisRID '-' thisSID '-' thisTTID '-' thisCLID ' has too small number of spks!']);
% 
%     return;    
% end
%


%% Linearization

make_maps_linearization_2b5;

%


%% Check number of spikes for each map

whole_flag = true;
stem_flag = true;
arm_flag = true;

if sum(sum(bin_spikes)) < 5
    whole_flag = false;
    numOfSpk2D = sum(sum(bin_spikes));
    numOfSpk1D = sum(sum(bin_spikes));
end

if sum(sum(bin_spikes(1 : stem_end_index, :))) < 5
    stem_flag = false;
    numOfSpk_stem2D = sum(sum(bin_spikes(1 : stem_end_index, :)));
    numOfSpk_stem1D = sum(sum(bin_spikes(1 : stem_end_index, :)));
end

if sum(sum(bin_spikes(stem_end_index + 1 : end, :))) < 5
    arm_flag = false;
    numOfSpk_arm1D = sum(sum(bin_spikes(stem_end_index + 1 : end, :)));
end

%


%% Skaggs' rate map

make_maps_Skaggs_2b5;
%


%% Save as mat file

cd([saveROOT '\map files (outbound) epoch_filtered']);

if whole_flag && stem_flag && arm_flag    
    save(['rat' clusterID '.mat'], 'occMap2D', 'spkMap2D', 'rawMap2D', 'skaggsMap2D', ...
        'occMap_left2D', 'spkMap_left2D', 'rawMap_left2D', 'skaggsMap_left2D', ...
        'occMap_right2D', 'spkMap_right2D', 'rawMap_right2D', 'skaggsMap_right2D', ...
        'occMap_stem2D', 'spkMap_stem2D', 'rawMap_stem2D', 'skaggsMap_stem2D', ...
        'occMap_stem_left2D', 'spkMap_stem_left2D', 'rawMap_stem_left2D', 'skaggsMap_stem_left2D', ...
        'occMap_stem_right2D', 'spkMap_stem_right2D', 'rawMap_stem_right2D', 'skaggsMap_stem_right2D', ...
        'occMap1D', 'spkMap1D', 'rawMap1D', 'skaggsMap1D', ...
        'occMap_left1D', 'spkMap_left1D', 'rawMap_left1D', 'skaggsMap_left1D', ...
        'occMap_right1D', 'spkMap_right1D', 'rawMap_right1D', 'skaggsMap_right1D', ...
        'occMap_stem1D', 'spkMap_stem1D', 'rawMap_stem1D', 'skaggsMap_stem1D', ...
        'occMap_stem_left1D', 'spkMap_stem_left1D', 'rawMap_stem_left1D', 'skaggsMap_stem_left1D', ...
        'occMap_stem_right1D', 'spkMap_stem_right1D', 'rawMap_stem_right1D', 'skaggsMap_stem_right1D', ...
        'occMap_arm1D', 'spkMap_arm1D', 'rawMap_arm1D', 'skaggsMap_arm1D', ...
        'occMap_arm_left1D', 'spkMap_arm_left1D', 'rawMap_arm_left1D', 'skaggsMap_arm_left1D', ...
        'occMap_arm_right1D', 'spkMap_arm_right1D', 'rawMap_arm_right1D', 'skaggsMap_arm_right1D', ...
        'SpaInfoScore2D', 'onmazeMaxFR2D', 'onmazeAvgFR2D', 'numOfSpk2D', 'realAvgFR2D', ...
        'SpaInfoScore_left2D', 'onmazeMaxFR_left2D', 'onmazeAvgFR_left2D', 'numOfSpk_left2D', 'realAvgFR_left2D', ...
        'SpaInfoScore_right2D', 'onmazeMaxFR_right2D', 'onmazeAvgFR_right2D', 'numOfSpk_right2D', 'realAvgFR_right2D', ...
        'SpaInfoScore_stem2D', 'onmazeMaxFR_stem2D', 'onmazeAvgFR_stem2D', 'numOfSpk_stem2D', 'realAvgFR_stem2D', ...
        'SpaInfoScore_stem_left2D', 'onmazeMaxFR_stem_left2D', 'onmazeAvgFR_stem_left2D', 'numOfSpk_stem_left2D', 'realAvgFR_stem_left2D', ...
        'SpaInfoScore_stem_right2D', 'onmazeMaxFR_stem_right2D', 'onmazeAvgFR_stem_right2D', 'numOfSpk_stem_right2D', 'realAvgFR_stem_right2D', ...
        'SpaInfoScore1D', 'onmazeMaxFR1D', 'onmazeAvgFR1D', 'numOfSpk1D', 'realAvgFR1D', ...
        'SpaInfoScore_left1D', 'onmazeMaxFR_left1D', 'onmazeAvgFR_left1D', 'numOfSpk_left1D', 'realAvgFR_left1D', ...
        'SpaInfoScore_right1D', 'onmazeMaxFR_right1D', 'onmazeAvgFR_right1D', 'numOfSpk_right1D', 'realAvgFR_right1D', ...
        'SpaInfoScore_stem1D', 'onmazeMaxFR_stem1D', 'onmazeAvgFR_stem1D', 'numOfSpk_stem1D', 'realAvgFR_stem1D', ...
        'SpaInfoScore_stem_left1D', 'onmazeMaxFR_stem_left1D', 'onmazeAvgFR_stem_left1D', 'numOfSpk_stem_left1D', 'realAvgFR_stem_left1D', ...
        'SpaInfoScore_stem_right1D', 'onmazeMaxFR_stem_right1D', 'onmazeAvgFR_stem_right1D', 'numOfSpk_stem_right1D', 'realAvgFR_stem_right1D', ...
        'SpaInfoScore_arm1D', 'onmazeMaxFR_arm1D', 'onmazeAvgFR_arm1D', 'numOfSpk_arm1D', 'realAvgFR_arm1D', ...
        'SpaInfoScore_arm_left1D', 'onmazeMaxFR_arm_left1D', 'onmazeAvgFR_arm_left1D', 'numOfSpk_arm_left1D', 'realAvgFR_arm_left1D', ...
        'SpaInfoScore_arm_right1D', 'onmazeMaxFR_arm_right1D', 'onmazeAvgFR_arm_right1D', 'numOfSpk_arm_right1D', 'realAvgFR_arm_right1D', ...
        'trial_number', 'stem_end_index');
    
elseif whole_flag && stem_flag
    save(['rat' clusterID '.mat'], 'occMap2D', 'spkMap2D', 'rawMap2D', 'skaggsMap2D', ...
        'occMap_left2D', 'spkMap_left2D', 'rawMap_left2D', 'skaggsMap_left2D', ...
        'occMap_right2D', 'spkMap_right2D', 'rawMap_right2D', 'skaggsMap_right2D', ...
        'occMap_stem2D', 'spkMap_stem2D', 'rawMap_stem2D', 'skaggsMap_stem2D', ...
        'occMap_stem_left2D', 'spkMap_stem_left2D', 'rawMap_stem_left2D', 'skaggsMap_stem_left2D', ...
        'occMap_stem_right2D', 'spkMap_stem_right2D', 'rawMap_stem_right2D', 'skaggsMap_stem_right2D', ...
        'occMap1D', 'spkMap1D', 'rawMap1D', 'skaggsMap1D', ...
        'occMap_left1D', 'spkMap_left1D', 'rawMap_left1D', 'skaggsMap_left1D', ...
        'occMap_right1D', 'spkMap_right1D', 'rawMap_right1D', 'skaggsMap_right1D', ...
        'occMap_stem1D', 'spkMap_stem1D', 'rawMap_stem1D', 'skaggsMap_stem1D', ...
        'occMap_stem_left1D', 'spkMap_stem_left1D', 'rawMap_stem_left1D', 'skaggsMap_stem_left1D', ...
        'occMap_stem_right1D', 'spkMap_stem_right1D', 'rawMap_stem_right1D', 'skaggsMap_stem_right1D', ...
        'SpaInfoScore2D', 'onmazeMaxFR2D', 'onmazeAvgFR2D', 'numOfSpk2D', 'realAvgFR2D', ...
        'SpaInfoScore_left2D', 'onmazeMaxFR_left2D', 'onmazeAvgFR_left2D', 'numOfSpk_left2D', 'realAvgFR_left2D', ...
        'SpaInfoScore_right2D', 'onmazeMaxFR_right2D', 'onmazeAvgFR_right2D', 'numOfSpk_right2D', 'realAvgFR_right2D', ...
        'SpaInfoScore_stem2D', 'onmazeMaxFR_stem2D', 'onmazeAvgFR_stem2D', 'numOfSpk_stem2D', 'realAvgFR_stem2D', ...
        'SpaInfoScore_stem_left2D', 'onmazeMaxFR_stem_left2D', 'onmazeAvgFR_stem_left2D', 'numOfSpk_stem_left2D', 'realAvgFR_stem_left2D', ...
        'SpaInfoScore_stem_right2D', 'onmazeMaxFR_stem_right2D', 'onmazeAvgFR_stem_right2D', 'numOfSpk_stem_right2D', 'realAvgFR_stem_right2D', ...
        'SpaInfoScore1D', 'onmazeMaxFR1D', 'onmazeAvgFR1D', 'numOfSpk1D', 'realAvgFR1D', ...
        'SpaInfoScore_left1D', 'onmazeMaxFR_left1D', 'onmazeAvgFR_left1D', 'numOfSpk_left1D', 'realAvgFR_left1D', ...
        'SpaInfoScore_right1D', 'onmazeMaxFR_right1D', 'onmazeAvgFR_right1D', 'numOfSpk_right1D', 'realAvgFR_right1D', ...
        'SpaInfoScore_stem1D', 'onmazeMaxFR_stem1D', 'onmazeAvgFR_stem1D', 'numOfSpk_stem1D', 'realAvgFR_stem1D', ...
        'SpaInfoScore_stem_left1D', 'onmazeMaxFR_stem_left1D', 'onmazeAvgFR_stem_left1D', 'numOfSpk_stem_left1D', 'realAvgFR_stem_left1D', ...
        'SpaInfoScore_stem_right1D', 'onmazeMaxFR_stem_right1D', 'onmazeAvgFR_stem_right1D', 'numOfSpk_stem_right1D', 'realAvgFR_stem_right1D', ...
        'trial_number', 'stem_end_index', 'numOfSpk_arm1D');
    
elseif whole_flag && arm_flag
    save(['rat' clusterID '.mat'], 'occMap2D', 'spkMap2D', 'rawMap2D', 'skaggsMap2D', ...
        'occMap_left2D', 'spkMap_left2D', 'rawMap_left2D', 'skaggsMap_left2D', ...
        'occMap_right2D', 'spkMap_right2D', 'rawMap_right2D', 'skaggsMap_right2D', ...
        'occMap1D', 'spkMap1D', 'rawMap1D', 'skaggsMap1D', ...
        'occMap_left1D', 'spkMap_left1D', 'rawMap_left1D', 'skaggsMap_left1D', ...
        'occMap_right1D', 'spkMap_right1D', 'rawMap_right1D', 'skaggsMap_right1D', ...
        'occMap_arm1D', 'spkMap_arm1D', 'rawMap_arm1D', 'skaggsMap_arm1D', ...
        'occMap_arm_left1D', 'spkMap_arm_left1D', 'rawMap_arm_left1D', 'skaggsMap_arm_left1D', ...
        'occMap_arm_right1D', 'spkMap_arm_right1D', 'rawMap_arm_right1D', 'skaggsMap_arm_right1D', ...
        'SpaInfoScore2D', 'onmazeMaxFR2D', 'onmazeAvgFR2D', 'numOfSpk2D', 'realAvgFR2D', ...
        'SpaInfoScore_left2D', 'onmazeMaxFR_left2D', 'onmazeAvgFR_left2D', 'numOfSpk_left2D', 'realAvgFR_left2D', ...
        'SpaInfoScore_right2D', 'onmazeMaxFR_right2D', 'onmazeAvgFR_right2D', 'numOfSpk_right2D', 'realAvgFR_right2D', ...
        'SpaInfoScore1D', 'onmazeMaxFR1D', 'onmazeAvgFR1D', 'numOfSpk1D', 'realAvgFR1D', ...
        'SpaInfoScore_left1D', 'onmazeMaxFR_left1D', 'onmazeAvgFR_left1D', 'numOfSpk_left1D', 'realAvgFR_left1D', ...
        'SpaInfoScore_right1D', 'onmazeMaxFR_right1D', 'onmazeAvgFR_right1D', 'numOfSpk_right1D', 'realAvgFR_right1D', ...
        'SpaInfoScore_arm1D', 'onmazeMaxFR_arm1D', 'onmazeAvgFR_arm1D', 'numOfSpk_arm1D', 'realAvgFR_arm1D', ...
        'SpaInfoScore_arm_left1D', 'onmazeMaxFR_arm_left1D', 'onmazeAvgFR_arm_left1D', 'numOfSpk_arm_left1D', 'realAvgFR_arm_left1D', ...
        'SpaInfoScore_arm_right1D', 'onmazeMaxFR_arm_right1D', 'onmazeAvgFR_arm_right1D', 'numOfSpk_arm_right1D', 'realAvgFR_arm_right1D', ...
        'trial_number', 'stem_end_index', 'numOfSpk_stem2D', 'numOfSpk_stem1D');
    
else
    save(['rat' clusterID '.mat'], 'numOfSpk2D', 'numOfSpk1D');
end
%


end
