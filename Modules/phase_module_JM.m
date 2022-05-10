function phase_module_JM(ROOT, thisCLUSTER,Params,Osc)

find_hypen = find(thisCLUSTER=='-');
thisRID = thisCLUSTER(1:find_hypen(1)-1);
thisSID = thisCLUSTER(find_hypen(1)+1:find_hypen(2)-1);
thisTTID = thisCLUSTER(find_hypen(2)+1:find_hypen(3)-1);
thisCLID = thisCLUSTER(find_hypen(3)+1:end);

Recording_region = readtable([ROOT.Info '\Recording_region.csv']);
thisRegion = Recording_region.(['TT' num2str(str2double(thisTTID))]){strcmp(Recording_region.SessionID,[thisRID '-' thisSID])};
if strncmp(thisRegion, 'CA3',3) && length(thisRegion)<6, thisRegion = 'CA3'; end

RefTT = readtable([ROOT.Save '\Tables\RefTT_' Osc '.xlsx'],'ReadRowNames',false);
TargetTT = RefTT.([thisRegion '_1'])(strcmp(RefTT.ID,[thisRID '-' thisSID]));

Spk = load([ROOT.Raw.Mother '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' num2str(str2double(thisTTID))...
    '\parsedSpike_' num2str(str2double(thisCLID)) '.mat']);

EEG = LoadEEGData(ROOT, [thisRID '-' thisSID], TargetTT,Params,[]);
EEG.eeg = EEG.(['TT' num2str(TargetTT)]).Raw;

phase_SPK = get_phase_JM(EEG,Spk.t_spk, Params.(Osc));

Spk.phase_spk = phase_SPK(:,1);

save([ROOT.Raw.Mother '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' num2str(str2double(thisTTID))...
    '\parsedSpike_' num2str(str2double(thisCLID)) '.mat'],'-struct','Spk');

disp([thisCLUSTER ' _add phase info_ is finished!'])