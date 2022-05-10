function [EEG]=LoadEEGData(ROOT, thisSID, TargetTT,Params,Params_Ripple)

for i=1:length(TargetTT)
    try
        thisTTID=TargetTT(i);
        cscID = [thisSID '-' num2str(thisTTID)];
        
        
        
        % load CSC data
        %         tic;
        cscData = loadCSC(cscID, ROOT.Raw.Mother, Params.CSCfileTag, Params.exportMODE, Params.behExtraction,'CSC');
        [eeg_expand,Timestamps_expand] = expandCSC(cscData);
        EEG.(['TT' num2str(thisTTID)]).Raw = eeg_expand(:);
        
        if ~isempty(Timestamps_expand),EEG.timestamps = Timestamps_expand; end
        
        
        %         toc;
        %%
        % 150-250Hz filtering
        %         LocalP = [Params.CSCfileTag '_' num2str(Params.cRange(1)) '-' num2str(Params.cRange(2)) 'filtered'];
        
        %         EEG.(['TT' num2str(thisTTID)]).Filtered = FiltLFP(EEG.(['TT' num2str(thisTTID)]).Raw,Params.Ripple,Params.Fn,'bandpass');
        
        % 4-10Hz filtering
        %         EEG.(['TT' num2str(thisTTID)]).Theta = FiltLFP(EEG.(['TT' num2str(thisTTID)]).Raw,Params.Theta,Params.Fn,'bandpass');
        
        
        %% get Gaussian-smoothed envelope of eeg
        if ~isempty(Params_Ripple)
            cscData = loadCSC(cscID, ROOT.Raw.Mother, [Params.CSCfileTag '_150-250filtered'], Params.exportMODE, Params.behExtraction,'CSC');
            [eeg_expand,Timestamps_expand] = expandCSC(cscData);
            EEG.(['TT' num2str(thisTTID)]).Filtered = eeg_expand(:);
            
            EEG.(['TT' num2str(thisTTID)]).Envelope = abs(hilbert(EEG.(['TT' num2str(thisTTID)]).Filtered));
            EEG.(['TT' num2str(thisTTID)]).Envelope_smoothed = smoothdata(EEG.(['TT' num2str(thisTTID)]).Envelope, 'gaussian', Params_Ripple.gaussianSTD);
        end
    catch
    end
    
end