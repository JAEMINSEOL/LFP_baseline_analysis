Initial_LFP;
warning off

ROOT.Fig = [ROOT.Save '\Plots\PSD'];
SessionList = readtable([ROOT.Info '\SessionList.xlsx'],'ReadRowNames',false);
Recording_region = readtable([ROOT.Info '\Recording_region.csv'],'ReadRowNames',true);
Experimenter = {'JS'};
rang = [0 300];

CSCfileTag = 'RateReduced';
exportMODE = 0;
behExtraction = 1;

fd = dir(ROOT.Save);


for sid=1:size(SessionList,1)
    PowerTable = table;
    if ismember(SessionList.experimenter(sid),Experimenter) && strcmp(SessionList.type{sid},'fog') 
        try
            thisRID = jmnum2str(SessionList.rat(sid),3);
            thisSID = jmnum2str(SessionList.session(sid),2);
            [TTL1Time]  = get_ttl(thisSID, thisRID);
            epochST = TTL1Time(1);
            epochED = TTL1Time(end);
            
            
            ID = [jmnum2str(SessionList.rat(sid),3) '-' jmnum2str(SessionList.session(sid),2)];
            
            Recording_region_TT = Recording_region({ID},:);
            
            TargetTT = [1:24]';
            
            %% EEG
            cd(ROOT.Fig)
            if ~exist(ID)
                mkdir(ID)
            end
            cd(ID)
            
            for thisTTID=1:24
                try
                    cscID = [thisRID '-' thisSID '-' num2str(thisTTID)];
                    dsLFP = [ROOT.Raw.Mother '\Rat' thisRID '\Rat' thisRID '_' thisSID];
                    
                    CSCdata = loadCSC_JS(cscID,ROOT.Raw.Mother,CSCfileTag,exportMODE,behExtraction,epochST,epochED);
                    [EEG.eeg,EEG.timestamps] = expandCSC(CSCdata);
                    
                    fig = figure('position',[-1630 150 1200 760]);
                    [pxx, f] = DrawPSD_JM(EEG.eeg, 'k',rang);
                    
                    x = [Params.theta];
                    p = patch([x(1) x(2) x(2) x(1)], [-10 -10 50 50],'r');
                    p.FaceAlpha = 0.2;
                    p.EdgeAlpha = 0;
                    
                    x = [Params.gamma];
                    p = patch([x(1) x(2) x(2) x(1)], [-10 -10 50 50],'r');
                    p.FaceAlpha = 0.2;
                    p.EdgeAlpha = 0;
                    
                    x = [Params.ripple];
                    p = patch([x(1) x(2) x(2) x(1)], [-10 -10 50 50],'r');
                    p.FaceAlpha = 0.2;
                    p.EdgeAlpha = 0;
                    
                    
                    title([ID '-' cell2mat(SessionList.type(sid)) '-d' num2str(SessionList.day(sid))...
                        '-TT' num2str(thisTTID) '(' cell2mat(Recording_region_TT.(['TT' num2str(thisTTID)])) ')'])
                    
                    
                    
                    theta = [knnsearch(f,Params.theta(1)) knnsearch(f,Params.theta(2))];
                    gamma = [knnsearch(f,Params.gamma(1)) knnsearch(f,Params.gamma(2))];
                    ripple = [knnsearch(f,Params.ripple(1)) knnsearch(f,Params.ripple(2))];
                    
                    thetaPower = nanmean(10*log10(pxx(theta(1):theta(2))));
                    gammaPower = nanmean(10*log10(pxx(gamma(1):gamma(2))));
                    ripplePower = nanmean(10*log10(pxx(ripple(1):ripple(2))));
                    
                    text(0.01, 0.98, ['theta Power =' jjnum2str(thetaPower,4) '      gamma Power =' jjnum2str(gammaPower,4) '           ripple Power =' jjnum2str(ripplePower,4)],'FontSize',15,'Units','normalized');
                    
                    
                    
                    saveas(fig,[ROOT.Fig '\' ID '\TT' num2str(thisTTID) '.png'])
                    close all
                    
                    
                    PowerTable.region{thisTTID} = cell2mat(Recording_region_TT.(['TT' num2str(thisTTID)]));
                    PowerTable.theta(thisTTID) = thetaPower;
                    PowerTable.gamma(thisTTID) = gammaPower;
                    PowerTable.ripple(thisTTID) = ripplePower;
                catch
                    PowerTable.theta(thisTTID) = nan;
                    PowerTable.gamma(thisTTID) = nan;
                    PowerTable.ripple(thisTTID) = nan;
                    disp([ID '-TT' num2str(thisTTID) ' doesnt exist'])
                end
            end
            
            writetable(PowerTable,[ROOT.Save '\Tables\PSD\' ID '.csv'],'WriteMode', 'overwrite')
        catch
            disp([ID ' has no LFP data'])
        end
    end
end