Initial_LFP;

ROOT.Fig = [ROOT.Save '\Plots\PSD'];
SessionList = readtable([ROOT.Info '\SessionList.xlsx'],'ReadRowNames',false);
Recording_region = readtable([ROOT.Info '\Recording_region.csv'],'ReadRowNames',true);
Experimenter = {'LSM','JS','SEB'};
rang = [0 300];


fd = dir(ROOT.Save);


for sid=1:size(SessionList,1)
    PowerTable = table;
    if ismember(SessionList.experimenter(sid),Experimenter)
        try
        thisRID = jmnum2str(SessionList.rat(sid),3);
        thisSID = jmnum2str(SessionList.session(sid),2);
        
        ID = [jmnum2str(SessionList.rat(sid),3) '-' jmnum2str(SessionList.session(sid),2)];
        Recording_region_TT = Recording_region({ID},:);
        
        TargetTT = [1:24]';
        
        %% EEG
        
        EEG = LoadEEGData(ROOT, [thisRID '-' thisSID], TargetTT,Params,[]);
        cd(ROOT.Fig)
        if ~exist(ID)
            mkdir(ID)
        end
        cd(ID)

        for thisTTID=1:24
            f = figure('position',[-1630 150 1200 760]);
            [pxx, f] = DrawPSD_JM(EEG.(['TT' num2str(thisTTID)]).Raw, 'k',rang);
            title([ID '-TT' num2str(thisTTID) '(' cell2mat(Recording_region_TT.(['TT' num2str(thisTTID)])) ')'])
             saveas(f,[ROOT.Fig '\' ID '\TT' num2str(thisTTID) '.png'])
             close all
             
             theta = [knnsearch(f,Params.Theta(1)) knnsearch(f,Params.Theta(2))];
             gamma = [knnsearch(f,Params.Gamma(1)) knnsearch(f,Params.Gamma(2))];
             ripple = [knnsearch(f,Params.Ripple(1)) knnsearch(f,Params.Ripple(2))];
             
             thetaPower = nanmean(10*log10(pxx(theta(1):theta(2))));
             gammaPower = nanmean(10*log10(pxx(gamma(1):gamma(2))));
             ripplePower = nanmean(10*log10(pxx(ripple(1):ripple(2))));
             
             PowerTable.theta(thisTTID) = thetaPower;
             PowerTable.gamma(thisTTID) = gammaPower;
             PowerTable.ripple(thisTTID) = ripplePower;
             
        end
        
        writematrix(PowerTable,[ROOT.Save '\Tables\PSD\' ID '.csv'],'WriteMode', 'overwrite')
        catch
            disp([ID ' has no LFP data'])
        end
    end
end