function [phase_SPK] = get_phase_JM(EEG,SpkTime, Wp)
    %% butterworth filter - bandpass
    
%     Wp = [4 12];   % passband edge frequencies
    Ws = [Wp(1)-2 Wp(2)+2];   % stopband edge frequencies    
    Rp = Wp(1)-1;         % passband ripple of no more than Rp dB, When Rp is chosen as 3 dB, the Wn in BUTTER is equal to Wp in buttord.
    Rs = Wp(2)+1;        % stopband attenuation of at least Rs dB
    ftype = 'bandpass';
    Fn = 1000;
    
    % frequency normalization
    Wp = Wp/Fn;
    Ws = Ws/Fn;
    
    [n,Wn] = buttord(Wp,Ws,Rp,Rs);  % n: order of filter, Wn: cutoff frequency      
    [z,p,k] = butter(n,Wn,ftype);
    [sos,g] = zp2sos(z,p,k);
    
    EEG.eeg = filtfilt(sos, g, EEG.eeg);
    
    % get phase of eeg
    EEG.radian = angle(hilbert(EEG.eeg));
    EEG.phase = EEG.radian*(180/pi);
    
    %% get phase of spikes
    phase_SPK = [];
    for spikeRUN = 1 : length(SpkTime)
        
        index1 = find(EEG.timestamps <= SpkTime(spikeRUN),1,'last');
        index2 = find(EEG.timestamps > SpkTime(spikeRUN),1,'first');
        
        ts1 = EEG.timestamps(index1);
        ts2 = EEG.timestamps(index2);
        
        phase1 = EEG.phase(index1);
        phase2 = EEG.phase(index2);
        
        % get approximated phase (linear interpolation)
        phase_SPK(spikeRUN,1) = (phase2 - phase1) * (SpkTime(spikeRUN)-ts1) / (ts2-ts1) + phase1;
    end
    phase_SPK = [phase_SPK SpkTime];
end
