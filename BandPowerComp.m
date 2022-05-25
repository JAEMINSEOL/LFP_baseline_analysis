Initial_LFP;
warning off

ROOT.Fig = [ROOT.Save '\Plots\PSD'];
SessionList = readtable([ROOT.Info '\SessionList.xlsx'],'ReadRowNames',false);
Recording_region = readtable([ROOT.Info '\Recording_region.csv'],'ReadRowNames',true);
Experimenter = {'JS'};
Regions = {'SUB','CA1', 'CA3', 'DG','V1','V2L'};
Oscillations = {'theta','gamma','ripple'};

PowStruct=struct;

for sid=1:size(SessionList,1)
    PowerTable = table;
    if ismember(SessionList.experimenter(sid),Experimenter)   & strncmp(SessionList.type{sid},'fog',3)
        try
        thisRID = jmnum2str(SessionList.rat(sid),3);
        thisSID = jmnum2str(SessionList.session(sid),2);
        ID = [jmnum2str(SessionList.rat(sid),3) '-' jmnum2str(SessionList.session(sid),2)];
        Recording_region_TT = Recording_region({ID},:);
        
        PowerTable = readtable([ROOT.Save '\Tables\PSD\' ID '.csv']);
        
        for i=1:size(PowerTable,1)
            if strncmp(PowerTable.region{i},'CA3',3) && length(PowerTable.region{i})<6
                PowerTable.region{i} = 'CA3';
            end
        end
        
        for osc = 1:numel(Oscillations)
            thisOsc = Oscillations{osc};
            if ~isfield(PowStruct,thisOsc), PowStruct.(thisOsc)=struct; end
            
            for reg = 1:numel(Regions)
                thisRegion  = Regions{reg};
                if ~isfield(PowStruct.(thisOsc),thisRegion), PowStruct.(thisOsc).(thisRegion)=[]; end
                
                for t=1:24
                    if strcmp(PowerTable.region{t},thisRegion)
                        PowStruct.(thisOsc).(thisRegion) = [PowStruct.(thisOsc).(thisRegion);...
                            [str2double(thisRID),str2double(thisSID),t,PowerTable.(thisOsc)(t)]];
                    end
                end
            end
        end
        end
    end
end
%%
figure('position',[-790 220 360 620])
thisOsc = 'theta';
dat = PowStruct.(thisOsc);
thisDat=[]; thisErr=[];
p_t=[];
for reg = 1:numel(Regions)
    try
        thisRegion  = Regions{reg};
        thisDat(reg) = [nanmean(dat.(thisRegion)(:,4))];
        thisErr(reg) = nanstd(dat.(thisRegion)(:,4)) / sqrt(length(dat.(thisRegion)(:,4)));
        for reg2 = 1:numel(Regions)
            try
            thisRegion2  = Regions{reg2};
            [~,p_t(reg,reg2)] = ttest2(dat.(thisRegion)(:,4),dat.(thisRegion2)(:,4));
            end
        end
    end
end
b = bar(thisDat([2,3,4,6]));
b.FaceColor = 'flat';
b.CData(1,:) = [0 0 1];
b.CData(2,:) = [1 0 0];
b.CData(3,:) = [0 1 0];
b.CData(4,:) = [1 1 0];

hold on
er = errorbar([1:4],thisDat([2,3,4,6]),thisErr([2,3,4,6]),thisErr([2,3,4,6]));    
er.Color = [0 0 0];                            
er.LineStyle = 'none';
er.LineWidth = 1.3;

ylabel([thisOsc ' power (Db/Hz)'])
xticklabels(Regions([2,3,4,6]))
set(gca,'fontweight','b','fontsize',15)