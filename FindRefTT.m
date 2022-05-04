Initial_LFP;
warning off

ROOT.Fig = [ROOT.Save '\Plots\PSD'];
SessionList = readtable([ROOT.Info '\SessionList.xlsx'],'ReadRowNames',false);
Recording_region = readtable([ROOT.Info '\Recording_region.csv'],'ReadRowNames',true);
Experimenter = {'JS','LSM','SEB'};
Regions = {'SUB','CA1', 'CA3', 'DG','V1','V2L'};
Oscillations = {'theta','gamma','ripple'};

RefTT = struct; RefTT.theta = table; RefTT.gamma = table; RefTT.ripple = table;
PowT = struct; PowT.theta = table; PowT.gamma = table; PowT.ripple = table;
PowStruct=struct;

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
            PowerTable.theta(PowerTable.theta==0) = nan;
            PowerTable.gamma(PowerTable.gamma==0) = nan;
            PowerTable.ripple(PowerTable.ripple==0) = nan;
            
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
                    
                    
                    PowerTable.(thisOsc)(t);
                    m = maxk(thisPowTable.(thisOsc),2);
                    
                    if isempty(m)
                        thisRefTT.([thisRegion '_1'])= nan;
                        thisRefTT.([thisRegion '_2'])= nan;
                    elseif size(m,1)==1
                        thisRefTT.([thisRegion '_1']) =find( m(1)== PowerTable.(thisOsc));
                        thisRefTT.([thisRegion '_2'])= nan;
                    else
                        thisRefTT.([thisRegion '_1']) =find( m(1)== PowerTable.(thisOsc));
                        thisRefTT.([thisRegion '_2']) =find( m(2)== PowerTable.(thisOsc));
                    end
                end
                
                RefTT.(thisOsc) = [RefTT.(thisOsc);thisRefTT];
                
                thisPowT = table;
                thisPowT.ID = ID;
                for t=1:24
                    
                    thisPowT.(['TT' num2str(t)]) = PowerTable.(thisOsc)(t);
                end
                PowT.(thisOsc) = [PowT.(thisOsc); thisPowT];
                
            end
            
        end
    end
end


%%

writetable(PowT.theta,[ROOT.Save '\Tables\PowerTable_theta.xlsx'],'WriteMode', 'overwrite')
writetable(PowT.gamma,[ROOT.Save '\Tables\PowerTable_gamma.xlsx'],'WriteMode', 'overwrite')
writetable(PowT.ripple,[ROOT.Save '\Tables\PowerTable_ripple.xlsx'],'WriteMode', 'overwrite')

writetable(RefTT.theta,[ROOT.Save '\Tables\RefTT_theta.xlsx'],'WriteMode', 'overwrite')
writetable(RefTT.gamma,[ROOT.Save '\Tables\RefTT_gamma.xlsx'],'WriteMode', 'overwrite')
writetable(RefTT.ripple,[ROOT.Save '\Tables\RefTT_ripple.xlsx'],'WriteMode', 'overwrite')
