Initial_LFP;
warning off

ROOT.Fig = [ROOT.Save '\Plots\PSD'];
SessionList = readtable([ROOT.Info '\SessionList.xlsx'],'ReadRowNames',false);
Recording_region = readtable([ROOT.Info '\Recording_region.csv'],'ReadRowNames',true);
Experimenter = {'LSM','SEB','JS'};
Regions = {'SUB','CA1', 'CA3', 'DG'};
Oscillations = {'theta','gamma','ripple'};

RefTT = struct;
RefTT.theta = table;
RefTT.gamma = table;
RefTT.ripple = table;

for sid=1:size(SessionList,1)
    PowerTable = table;
    if ismember(SessionList.experimenter(sid),Experimenter)
        try
            thisRID = jmnum2str(SessionList.rat(sid),3);
            thisSID = jmnum2str(SessionList.session(sid),2);
            ID = [jmnum2str(SessionList.rat(sid),3) '-' jmnum2str(SessionList.session(sid),2)];
            Recording_region_TT = Recording_region({ID},:);
            
            TargetTT = [1:24]';
            PowerTable = readtable([ROOT.Save '\Tables\PSD\' ID '.csv']);
            
            for i=1:size(PowerTable,1)
                if strncmp(PowerTable.region{i},'CA3',3) && length(PowerTable.region{i})<6
                    PowerTable.region{i} = 'CA3';
                end
            end
            
            for osc = 1:numel(Oscillations)
                thisOsc = Oscillations{osc};
                
                thisRefTT = table;
                thisRefTT.ID = ID;
                for reg = 1:numel(Regions)
                    thisRegion  = Regions{reg};
                    thisPowTable = PowerTable(strcmp(PowerTable.region,thisRegion),:);
                    
                    m = max(thisPowTable.(thisOsc));
                    
                    if isempty(m)
                        thisRefTT.(thisRegion) = nan;
                    else
                        thisRefTT.(thisRegion) =find( m== PowerTable.(thisOsc));
                    end
                end
                
                RefTT.(thisOsc) = [RefTT.(thisOsc);thisRefTT];
            end
            
        end
    end
end

 writetable(RefTT.theta,[ROOT.Save '\Tables\RefTT_theta.xlsx'],'WriteMode', 'overwrite')
 writetable(RefTT.gamma,[ROOT.Save '\Tables\RefTT_gamma.xlsx'],'WriteMode', 'overwrite')
 writetable(RefTT.ripple,[ROOT.Save '\Tables\RefTT_ripple.xlsx'],'WriteMode', 'overwrite')