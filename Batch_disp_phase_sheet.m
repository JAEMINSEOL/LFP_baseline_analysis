Initial_LFP
ROOT.fig = [ROOT.Save '\Plots\Phase\JSReplicate'];
Recording_region = readtable([ROOT.Info '\Recording_region.csv']);
Osc = 'theta';
UseJSRef = 1;
mod = 'winC';

Cluster_List = readtable([ROOT.Info '\ClusterList.xlsx']);

for cellRUN = 1 : size(Cluster_List,1)
    if strcmp(Cluster_List.experimenter{cellRUN},'JS') && strcmp(Cluster_List.session_type{cellRUN},'fog')
        try
        thisCLUSTER = Cluster_List.ID{cellRUN};
        find_hypen = find(thisCLUSTER=='-');
        thisRID = thisCLUSTER(1:find_hypen(1)-1);
        thisSID = thisCLUSTER(find_hypen(1)+1:find_hypen(2)-1);
        thisTTID = thisCLUSTER(find_hypen(2)+1:find_hypen(3)-1);
        thisCLID = thisCLUSTER(find_hypen(3)+1:end);
        
        thisRegion = Recording_region.(['TT' num2str(str2double(thisTTID))]){strcmp(Recording_region.SessionID,[thisRID '-' thisSID])};
        if strncmp(thisRegion, 'CA3',3) && length(thisRegion)<6, thisRegion2 = 'CA3'; else, thisRegion2 = thisRegion; end
        
        RefTT = readtable([ROOT.Save '\Tables\RefTT_' Osc '.xlsx'],'ReadRowNames',false);
        if ~ismember([thisRegion2 '_1'],RefTT.Properties.VariableNames), disp([thisRegion2 ' is not the target region']); continue; end
        if ~isnan(RefTT.(['JS_1'])(strcmp(RefTT.ID,[thisRID '-' thisSID]))) && UseJSRef
            TargetTT = RefTT.(['JS_1'])(strcmp(RefTT.ID,[thisRID '-' thisSID]));
        else
            TargetTT = RefTT.([thisRegion2 '_1'])(strcmp(RefTT.ID,[thisRID '-' thisSID]));
        end
        %% for parsed pos.
        if strcmp(mod,'pars')
            Spk = load([ROOT.Raw.Mother '\rat' thisRID '\rat' thisRID '-' thisSID '\TT' num2str(str2double(thisTTID))...
                '\parsedSpike_' num2str(str2double(thisCLID)) '.mat']);
            fig = display_phase_common(Spk,thisCLUSTER,thisRegion, TargetTT);
            
            cd(ROOT.fig)
            if ~exist([thisRID '-' thisSID]), mkdir([thisRID '-' thisSID]); end
            saveas(fig,[ROOT.fig '\' thisRID '-' thisSID '\' thisCLUSTER '.png'])
            close all
        end
        %% for raw winclust
        if strcmp(mod,'winC')
            fig = display_phase_JS(ROOT,thisCLUSTER,thisRegion, TargetTT);
            if ~exist([ROOT.fig '\' thisRID '-' thisSID],'dir'), mkdir([ROOT.fig '\' thisRID '-' thisSID]); end
            saveas(fig, [ROOT.fig '\' thisRID '-' thisSID '\rat' thisCLUSTER '.jpg']);
            close all
        end
        %%
        catch
            close all
            disp([thisCLUSTER ' is failed!'])
        end
    end
end