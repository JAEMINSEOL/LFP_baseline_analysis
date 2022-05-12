
Osc = 'theta';
thisCLUSTER = '477-02-20-04';
find_hypen = find(thisCLUSTER=='-');
thisRID = thisCLUSTER(1:find_hypen(1)-1);
thisSID = thisCLUSTER(find_hypen(1)+1:find_hypen(2)-1);
thisTTID = thisCLUSTER(find_hypen(2)+1:find_hypen(3)-1);
thisCLID = thisCLUSTER(find_hypen(3)+1:end);
thisRegion = Recording_region.(['TT' num2str(str2double(thisTTID))]){strcmp(Recording_region.SessionID,[thisRID '-' thisSID])};
if strncmp(thisRegion, 'CA3',3) && length(thisRegion)<6, thisRegion2 = 'CA3'; else, thisRegion2 = thisRegion; end

RefTT = readtable([ROOT.Save '\Tables\RefTT_' Osc '.xlsx'],'ReadRowNames',false);
if ~ismember([thisRegion2 '_1'],RefTT.Properties.VariableNames), disp([thisRegion2 ' is not the target region']); return; end
TargetTT = RefTT.([thisRegion2 '_1'])(strcmp(RefTT.ID,[thisRID '-' thisSID]));
%%
Spk = load([ROOT.Raw.Mother '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' num2str(str2double(thisTTID))...
    '\parsedSpike_' num2str(str2double(thisCLID)) '.mat']);
fig = display_phase_common(Spk,thisCLUSTER,thisRegion, TargetTT);

cd([ROOT.Save '\Plots\Phase'])
if ~exist([thisRID '-' thisSID]), mkdir([thisRID '-' thisSID]); end
saveas(fig,[ROOT.Save '\Plots\Phase\' thisRID '-' thisSID '\' thisCLUSTER '.png'])
close all

%%