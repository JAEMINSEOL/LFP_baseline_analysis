
clear all; clc; fclose all;

motherROOT = 'D:\ongoing\CA3_recording\CA3_DG\LE553\CheetahData\newpair\2018-07-22_17-32-31';
saveROOT = 'D:\ongoing\CA3_recording\CA3_DG\LE553\CheetahData\newpair\2018-07-22_17-32-31';

%% set variables
% define frequency
Fs = 2000;  % sampling frequency
Fn = Fs/2;  % Nyquist frequency
F0 = 60/Fn; % notch frequency

% define loadCSC variable
CSCfileTag = '_RateReduced';
exportMODE = 1;
behExtraction = 0;

% switch
noiseFilteringSwitch = 1;
saveSwitch = 1;
exportSwitch = 1;

% define data duration
freqN = 2048;
freqLimit = 450;
freqBin = ceil(freqLimit/Fs * freqN);


%% load CSC data
cd(motherROOT);
   
    cscID = 'CSC21_RateReduced.ncs';
   
    %% load csc data    
    CSCdata = loadCSC(cscID, motherROOT, CSCfileTag, exportMODE, behExtraction);
    thiseeg = CSCdata.eeg(:);
    
    
    %% butterworth filter - bandpass
    CSCdata_filtered.eeg = zeros(size(thiseeg));    
    
    Wp = [145 405];   % passband edge frequencies
    Ws = [120 420];   % stopband edge frequencies    
    Rp = 3;         % passband ripple of no more than Rp dB, When Rp is chosen as 3 dB, the Wn in BUTTER is equal to Wp in buttord.
    Rs = 15;        % stopband attenuation of at least Rs dB
    ftype = 'bandpass';
    
    % frequency normalization
    Wp = Wp/Fn;
    Ws = Ws/Fn;
    
    [n,Wn] = buttord(Wp,Ws,Rp,Rs);  % n: order of filter, Wn: cutoff frequency      
    [z,p,k] = butter(n,Wn,ftype);
    [sos,g] = zp2sos(z,p,k);
    
    CSCdata_filtered.eeg = filtfilt(sos, g, thiseeg);
    
    
    %% butterworth filter - stopband
    if noiseFilteringSwitch
        
        % 180hz filtering
        Wp = [178 182];   % passband edge frequencies
        Ws = [176 184];   % stopband edge frequencies
        Rp = 3;         % passband ripple of no more than Rp dB, When Rp is chosen as 3 dB, the Wn in BUTTER is equal to Wp in buttord.
        Rs = 10;        % stopband attenuation of at least Rs dB
        ftype = 'stop';
        
        % frequency normalization
        Wp = Wp/Fn;
        Ws = Ws/Fn;
        
        [n,Wn] = buttord(Wp,Ws,Rp,Rs);  % n: order of filter, Wn: cutoff frequency
        [z,p,k] = butter(n,Wn,ftype);
        [sos,g] = zp2sos(z,p,k);
        
        CSCdata_filtered.eeg = filtfilt(sos, g, CSCdata_filtered.eeg);
        
        % 300hz filtering
        Wp = [298 302];   % passband edge frequencies
        Ws = [296 304];   % stopband edge frequencies
        Rp = 3;         % passband ripple of no more than Rp dB, When Rp is chosen as 3 dB, the Wn in BUTTER is equal to Wp in buttord.
        Rs = 10;        % stopband attenuation of at least Rs dB
        ftype = 'stop';
        
        % frequency normalization
        Wp = Wp/Fn;
        Ws = Ws/Fn;
        
        [n,Wn] = buttord(Wp,Ws,Rp,Rs);  % n: order of filter, Wn: cutoff frequency
        [z,p,k] = butter(n,Wn,ftype);
        [sos,g] = zp2sos(z,p,k);
%         
%         sos = zp2sos(z,p,k);
% fvtool(sos,'Analysis','freq')
        
        CSCdata_filtered.eeg = filtfilt(sos, g, CSCdata_filtered.eeg);
        
    end % if 0
    
    
    %% display PSD plot
    if saveSwitch
        [PSD_beforeFiltering, f] = getPSD(thiseeg, Fs, freqN, freqLimit);
        [PSD_afterFiltering, f] = getPSD(CSCdata_filtered.eeg, Fs, freqN, freqLimit);
        
        cscID_tag = [cscID ' 150-400 noise filtered'];
        plotPSD_SWRfiltering(cscID_tag, f, PSD_beforeFiltering, PSD_afterFiltering, SaveROOT);
    end
    
    
    %% export filtered data to ncs file
    if exportSwitch
        % reshape
        dataN = size(CSCdata_filtered.eeg,1) * size(CSCdata_filtered.eeg,2);
        colN = floor(dataN/512);
        CSCdata_filtered.eeg = reshape(CSCdata_filtered.eeg, 512, colN);
        
        % export
        sessionROOT = [motherROOT '\rat' CSCdata.thisRID '\rat' CSCdata.thisRID '-' CSCdata.thisSID];
        Switch = 'butterSwitch_export';
        filename_tail = '_RateReduced_SWRfiltered150-400';
        export_Mat2NlxCSC(CSCdata, CSCdata_filtered, sessionROOT, filename_tail, Switch)
    end
    
    
    %% ----
    disp([cscID ' has been done!']);
    
   % clear CSCdata thiseeg filtered_eeg PSD_afterFiltering PSD_beforeFiltering f
        

