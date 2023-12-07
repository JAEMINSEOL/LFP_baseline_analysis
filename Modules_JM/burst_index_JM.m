%Load Epoch information
    cd([DatROOT.raw '\rat' thisRID]);
        thisEPOCH = ['behaviorEpoch_rat' thisRID '.csv'];
        epochST = csvread(thisEPOCH, str2double(thisSID)-1, 0, [str2double(thisSID)-1, 0, str2double(thisSID)-1, 0]);
        epochED = csvread(thisEPOCH, str2double(thisSID)-1, 1, [str2double(thisSID)-1, 1, str2double(thisSID)-1, 1]);



%Load cluster file
    cd([DatROOT.raw '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' thisTTID]);
    if exist(['TT' thisTTID '_beh_SS_' thisCLID '.ntt'])
    [thisEpochCLTS] = Nlx2MatSpike(['TT' thisTTID '_beh_SS_' thisCLID '.ntt'], [1 0 0 0 0], 0, 4, [epochST, epochED]);
    elseif exist(['parsedSpike_' thisCLID '.mat'])
        load(['parsedSpike_' thisCLID '.mat'],'t_spk')
        [thisEpochCLTS] = t_spk' * 10^6;
    elseif exist(['parsedSpike_all.' num2str(str2double(thisCLID)) '.mat'])
        load(['parsedSpike_all.' num2str(str2double(thisCLID)) '.mat'],'t_spk')
        [thisEpochCLTS] = t_spk' * 10^6;
    end
    nSPKS = size(thisEpochCLTS, 2);
    
    %Auto-correlogram
    [correlogram corrXlabel] = CrossCorr(transpose(thisEpochCLTS) ./ 100, transpose(thisEpochCLTS) ./ 100, 1, 1000);
    correlogram((length(corrXlabel)+1)/2) = 0; % to adjust y limit
    
    % get burst index
    
    % % Loren Frank group
    if 1
        burst_power = sum(correlogram((length(corrXlabel)+1)/2+LF_burst(1):(length(corrXlabel)+1)/2+LF_burst(2)));
        normalization_power = sum(correlogram((length(corrXlabel)+1)/2+LF_baseline(1):(length(corrXlabel)+1)/2+LF_baseline(2)));
        LF_burstIndex = burst_power / normalization_power;
    end