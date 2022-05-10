
function Spk = createParsedSpike_JM(mother_root, thisCLUSTER)
microSEC=10^6;
findHYPHEN = find(thisCLUSTER == '-');

thisRID = (thisCLUSTER(1, 1:findHYPHEN(1) - 1));
thisSID = (thisCLUSTER(1, findHYPHEN(1) + 1:findHYPHEN(2) - 1));
thisTTID = num2str(str2double((thisCLUSTER(1, findHYPHEN(2) + 1:findHYPHEN(3) - 1))));
thisCLID = num2str(str2double((thisCLUSTER(1, findHYPHEN(3) + 1:end))));

%Load Epoch information
cd([mother_root '\rat' thisRID]);
% if str2double(thisRID) > 400
%     thisEPOCH = ['behaviorEpoch_rat' thisRID '.xlsx'];
%     epochST = xlsread(thisEPOCH, ['A' thisSID ':' 'A' thisSID]);
%     epochED = xlsread(thisEPOCH, ['B' thisSID ':' 'B' thisSID]);
% else
    thisEPOCH = readmatrix(['behaviorEpoch_rat' thisRID '.xlsx']);
    epochST = thisEPOCH(str2double(thisSID),1);
    epochED = thisEPOCH(str2double(thisSID),2);
%     epochST = csvread(thisEPOCH, str2double(thisSID)-1, 0, [str2double(thisSID)-1, 0, str2double(thisSID)-1, 0]);
%     epochED = csvread(thisEPOCH, str2double(thisSID)-1, 1, [str2double(thisSID)-1, 1, str2double(thisSID)-1, 1]);
% end

%Load cluster file
cd([mother_root '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' thisTTID]);
if exist(['TT' thisTTID '_beh_SS_' thisCLID '.ntt'],'file')
    if epochED-epochST < microSEC
        epochST = epochST*microSEC;
        epochED = epochED*microSEC;
    end
    thisEpochCLTS = Nlx2MatSpike(['TT' thisTTID '_beh_SS_' thisCLID '.ntt'], [1 0 0 0 0], 0, 4, [epochST, epochED]);
    thisEpochCLTS = thisEpochCLTS/microSEC;
    spkN = length(thisEpochCLTS);
    area=[];
    %Load position parsing result
    load([mother_root '\rat' thisRID '\rat' thisRID '-' thisSID '\ParsedPosition.mat']);
    areaN = 5;
    posN = length(x);
    if ~exist('ambiguity'), ambiguity = ones(posN,1); end
    if ~exist('cont'), cont = [side,zeros(posN,4)]; end    
    if ~exist('correctness')
        eval([genvarname('correctness'), '= corr;']);
        clear corr
    end
    
    a_spk = zeros(spkN, 1);
    t_spk = zeros(spkN, 1);
    x_spk = zeros(spkN, 1);
    y_spk = zeros(spkN, 1);
    trial_spk = logical(zeros(spkN, size(trial,2)));
    area_spk = logical(zeros(spkN, areaN));
    correctness_spk = logical(zeros(spkN, 2));
    cont_spk = logical(zeros(spkN, 6));
    side_spk = logical(zeros(spkN, 2));
    ambiguity_spk = logical(zeros(spkN, 3));
    %     void_spk = logical(zeros(spkN, 1));
    
    clRUN = 1;
    posRUN = 1;
    while posRUN <= posN
        if t(posRUN,1) >= thisEpochCLTS(clRUN) && posRUN == 1
            a_spk(clRUN) = a(posRUN);
            %         t_spk(clRUN) = t(posRUN);
            t_spk(clRUN) = thisEpochCLTS(clRUN);
            x_spk(clRUN) = x(posRUN);
            y_spk(clRUN) = y(posRUN);
            trial_spk(clRUN,:) = trial(posRUN,:);
%             area_spk(clRUN,:) = area(posRUN,:);
            correctness_spk(clRUN,:) = correctness(posRUN,:);
            cont_spk(clRUN,:) = cont(posRUN,:);
            side_spk(clRUN,:) = side(posRUN,:);
            ambiguity_spk(clRUN,:) = ambiguity(posRUN,:);
            %         void_spk(clRUN) = void(posRUN);
            clRUN = clRUN + 1;
        elseif t(posRUN,1) >= thisEpochCLTS(clRUN)
            if t(posRUN,1)-thisEpochCLTS(clRUN) < thisEpochCLTS(clRUN)-t(posRUN-1,1)
                 a_spk(clRUN) = a(posRUN);
                %             t_spk(clRUN) = t(posRUN);
                t_spk(clRUN) = thisEpochCLTS(clRUN);
                x_spk(clRUN) = x(posRUN);
                y_spk(clRUN) = y(posRUN);
                trial_spk(clRUN,:) = trial(posRUN,:);
%                 area_spk(clRUN,:) = area(posRUN,:);
                correctness_spk(clRUN,:) = correctness(posRUN,:);
                cont_spk(clRUN,:) = cont(posRUN,:);
                side_spk(clRUN,:) = side(posRUN,:);
                ambiguity_spk(clRUN,:) = ambiguity(posRUN,:);
                %             void_spk(clRUN) = void(posRUN);
                posRUN = posRUN - 1; clRUN = clRUN + 1;
            else
                a_spk(clRUN) = a(posRUN-1);
                %             t_spk(clRUN) = t(posRUN-1);
                t_spk(clRUN) = thisEpochCLTS(clRUN);
                x_spk(clRUN) = x(posRUN-1);
                y_spk(clRUN) = y(posRUN-1);
                trial_spk(clRUN,:) = trial(posRUN-1,:);
%                 area_spk(clRUN,:) = area(posRUN-1,:);
                correctness_spk(clRUN,:) = correctness(posRUN-1,:);
                cont_spk(clRUN,:) = cont(posRUN-1,:);
                side_spk(clRUN,:) = side(posRUN-1,:);
                ambiguity_spk(clRUN,:) = ambiguity(posRUN-1,:);
                %             void_spk(clRUN) = void(posRUN-1);
                posRUN = posRUN - 1; clRUN = clRUN + 1;
            end
        end
        
        if clRUN > length(thisEpochCLTS)
            break;
        end
        
        posRUN = posRUN + 1;
    end
    
    if clRUN <= length(thisEpochCLTS)   % spikes after last position sampling.
        posRUN = posRUN - 1;
        
        for iter = clRUN : length(thisEpochCLTS)
            a_spk(iter) = a(posRUN);
            %         t_spk(clRUN) = t(posRUN);
            t_spk(iter) = thisEpochCLTS(iter);
            x_spk(iter) = x(posRUN);
            y_spk(iter) = y(posRUN);
            trial_spk(iter,:) = trial(posRUN,:);
%             area_spk(iter,:) = area(posRUN,:);
            correctness_spk(iter,:) = correctness(posRUN,:);
            cont_spk(iter,:) = cont(posRUN,:);
            side_spk(iter,:) = side(posRUN,:);
            ambiguity_spk(iter,:) = ambiguity(posRUN,:);
            %         void_spk(clRUN) = void(posRUN);
            
        end
    end
    
Spk = struct('t_spk',t_spk, 'x_spk',x_spk, 'y_spk', y_spk, 'a_spk', a_spk,'cont_spk',cont_spk, ...
        'correctness_spk',correctness_spk, 'trial_spk', trial_spk, 'side_spk',side_spk,...
        'ambiguity_spk', ambiguity_spk, 'area_spk',area_spk);
    
    save([mother_root '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' thisTTID '\parsedSpike_' thisCLID '.mat'],'-struct','Spk');

    
    
end % if exist
end