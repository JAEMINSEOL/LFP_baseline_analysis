
function thisFieldMap = getFieldMaps_JM(clusterID,thisField,option,DatROOT,InfoROOT,clRUN )

% ROOT = 'D:\SUB-CA1 Ephys\2. SPK Data';

% skaggs' rate map variables
imROW = 480;
imCOL = 480;
thisFRMapSCALE = 10;
fixRadius = 3;  % original
videoSamplingRate = 30;

area=[];
%%
findHYPHEN = find(clusterID == '-');
thisRID = clusterID(1, 1:findHYPHEN(1) - 1);
thisSID = clusterID(1, findHYPHEN(1) + 1:findHYPHEN(2) - 1);
thisTTID = clusterID(1, findHYPHEN(2) + 1:findHYPHEN(3) - 1);
thisCLID = clusterID(1, findHYPHEN(3) + 1:end);

%
load([DatROOT '\rat' thisRID '\rat' thisRID '-' thisSID '\ParsedPosition.mat']);

% Load parsed spike
if clRUN<=900
load([DatROOT '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' thisTTID '\parsedSpike_' thisCLID '.mat'],'t_spk','y_spk','x_spk','side_spk','area_spk','cont_spk','ambiguity_spk');
else
load([DatROOT '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' thisTTID '\parsedSpike_all.' num2str(str2double(thisCLID)) '.mat'],'t_spk','y_spk','x_spk','side_spk','area_spk','cont_spk','ambiguity_spk');
end

%% Set variables depend on session_type
session_type = get_sessionType(thisRID, thisSID);
% session_type = 1;
if session_type == 1, ratemap_number = 5; overallmap_idx = 1;
elseif session_type == 6, ratemap_number = 3; overallmap_idx = 3;  % new pair learning
else ratemap_number = 10; overallmap_idx = 10; end

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
    trial_number(10) = sum(trial_number(4:9));
end

%%
diverging_point = get_divergingPoint(InfoROOT, thisRID, thisSID);

Boundaries;

%% Filtering (outbound)
pos = logical([]); spks = logical([]);

if session_type == 1
    pos(:,1) = inpolygon(x, y, xEdge, yEdge);
    pos(:,1) = pos(:,1) & correctness(:,1) & ~area(:,5);
    spks(:,1) = ismember(t_spk,thisField.ts);
    
    for iter = 1:4  % run for contexts
        pos(:,iter + 1) = pos(:,1) & cont(:,iter);
        spks(:,iter + 1) = spks(:,1) & cont_spk(:,iter);
    end
    
elseif session_type == 6    % new learning
    pos(:,3) = inpolygon(x, y, xEdge, yEdge);
    pos(:,3) = pos(:,3) & correctness(:,1) & ~area(:,5);
    spks(:,3) = ismember(t_spk,thisField.ts);
    
    for iter = 5 : 6  % run for contexts
        pos(:,iter - 4) = pos(:,3) & cont(:,iter);
        spks(:,iter - 4) = spks(:,3) & cont_spk(:,iter);
    end
    
elseif sum(session_type == [2 3 4 5])
    pos(:,10) = inpolygon(x, y, xEdge, yEdge);
    pos(:,10) = pos(:,10) & correctness(:,1) & ~area(:,5);
    spks(:,10) = ismember(t_spk,thisField.ts);
    
    for iter = 1:3  % run for ambiguity/trace conditions
        pos(:,iter) = inpolygon(x, y, xEdge, yEdge);
        pos(:,iter) = pos(:,iter) & correctness(:,1) & ~area(:,5) & ambiguity(:,iter);
        spks(:,iter) = spks(:,10) & ambiguity_spk(:,iter);
        
        pos(:,iter + 3) = pos(:,iter) & (cont(:,1) | cont(:,2));
        pos(:,iter + 6) = pos(:,iter) & (cont(:,3) | cont(:,4));
        spks(:,iter + 3) = spks(:,iter) & (cont_spk(:,1) | cont_spk(:,2));
        spks(:,iter + 6) = spks(:,iter) & (cont_spk(:,3) | cont_spk(:,4));
    end
end


if strcmp(option,'session')
    %% Linearization
    
    make_maps_linearization_2b5;
    
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
    
    %% Skaggs' rate map
    
    make_maps_Skaggs_2b5;
    
elseif strcmp(option,'trial')
    
    pos(:,2:end) = []; spks(:,2:end) = [];
    
    rawMap1D_trial = {};
    for trial_iter = 1 : total_trial_number
        getFieldMaps_trial;
    end
       
    map_size = min(cellfun('size',rawMap1D_trial,1));
    for trial_iter = 1 : total_trial_number 
        if size(rawMap1D_trial{trial_iter},1) > map_size
            rawMap1D_trial{trial_iter}(map_size+1:end) = [];
        end
    end
    rawMap1D_trial = cat(2,rawMap1D_trial{:});
    
end


%% output

if strcmp(option,'session')
    thisFieldMap.occMap1D = occMap1D;
    thisFieldMap.spkMap1D = spkMap1D;
    thisFieldMap.rawMap1D = rawMap1D;
    thisFieldMap.skaggsMap1D = skaggsMap1D;
    
    thisFieldMap.numOfSpk1D = numOfSpk1D;
    thisFieldMap.onmazeAvgFR1D = onmazeAvgFR1D;
    thisFieldMap.onmazeMaxFR1D = onmazeMaxFR1D;
    thisFieldMap.SpaInfoScore1D = SpaInfoScore1D;
    
    thisFieldMap.skaggsMap_left1D = skaggsMap_left1D;
    thisFieldMap.skaggsMap_right1D = skaggsMap_right1D;
    
elseif strcmp(option,'trial')
    thisFieldMap = rawMap1D_trial;
    
else
    disp('Select an option: session or trial');
end


end

