
Initial_LFP;

% mother_root = 'H:\CA1&SUB_SCSM\ephys_analysis';
mother_root = ['F:\EPhysRawData\RawData'];

Cluster_List = readtable([ROOT.Info '\ClusterList.xlsx']);

%
cd(mother_root);
% [~,inputCSV] = xlsread('D:\HPC-LFP project\Information Sheet\ClusterList.csv');

stCellRun = 1;

for cellRUN = 1 : size(Cluster_List,1)
    if strcmp(Cluster_List.experimenter{cellRUN},'JS') 
    
    thisCLUSTER = Cluster_List.ID{cellRUN};
    
    
    Spk = createParsedSpike_JM(mother_root, thisCLUSTER);
    if Spk.t_spk ==0, disp(['ERROR:' thisCLUSTER ' has no spike.']); continue; end
    
    phase_module_JM(ROOT, thisCLUSTER,Params,'theta')
    disp([thisCLUSTER ' has processed.']);
    end
end