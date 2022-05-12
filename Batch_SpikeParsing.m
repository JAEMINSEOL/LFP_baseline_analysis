
Initial_LFP;

% mother_root = 'H:\CA1&SUB_SCSM\ephys_analysis';
mother_root = ['F:\EPhysRawData\RawData'];

Cluster_List = readtable([ROOT.Info '\ClusterList.xlsx']);
Recording_region = readtable([ROOT.Info '\Recording_region.csv']);
RegionList = {'CA1','CA3','DG','V2L'};
%
cd(mother_root);
% [~,inputCSV] = xlsread('D:\HPC-LFP project\Information Sheet\ClusterList.csv');

stCellRun = 1;
thisSID_old='';
for cellRUN = 1 : size(Cluster_List,1)
    if strcmp(Cluster_List.experimenter{cellRUN},'JS')
        
        thisCLUSTER = Cluster_List.ID{cellRUN};
        find_hypen = find(thisCLUSTER=='-');
        thisRID = thisCLUSTER(1:find_hypen(1)-1);
        thisSID = thisCLUSTER(find_hypen(1)+1:find_hypen(2)-1);
        thisTTID = thisCLUSTER(find_hypen(2)+1:find_hypen(3)-1);
        thisCLID = thisCLUSTER(find_hypen(3)+1:end);
        thisRegion = Recording_region.(['TT' num2str(str2double(thisTTID))]){strcmp(Recording_region.SessionID,[thisRID '-' thisSID])};
        if strncmp(thisRegion, 'CA3',3) && length(thisRegion)<6, thisRegion = 'CA3'; end
        if ~ismember(thisRegion,RegionList), disp(['ERROR 1:' thisCLUSTER 'is not in a target region']); continue; end
        
        
        try
            Spk = createParsedSpike_JM(mother_root, thisCLUSTER);
            if length(Spk.t_spk) <50 , disp(['ERROR 2:' thisCLUSTER ' has less spike.']); continue; end
            if  isfield(Spk,'phase_spk'), if size(Spk.phase_spk,2)==24 , disp(['ERROR 3:' thisCLUSTER ' has already done.']); continue; end, end
            
            if ~strcmp(thisSID, thisSID_old)
                disp(['load' thisRID '-' thisSID ' LFP data....']);
                for t=1:24
                    try
                        EEG_temp = LoadEEGData(ROOT, [thisRID '-' thisSID], [t],Params,[]);
                        EEG.(['TT' num2str(t)]).eeg = EEG_temp.(['TT' num2str(t)]).Raw;
                        EEG.(['TT' num2str(t)]).timestamps = EEG_temp.timestamps;
                    end
                end
                thisSID_old = thisSID;
            end
            clear EEG_temp
            
            phase_module_JM(ROOT, thisCLUSTER,EEG,Params,'theta')
            disp([thisCLUSTER ' has processed.']);
        catch
            disp(['ERROR 0:' thisCLUSTER ]);
        end
    end
end
