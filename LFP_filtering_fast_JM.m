Initial_LFP;

thisRID = '511';
thisSID = '07';
thisTTID = 22;

cscID = [thisRID '-' thisSID '-' num2str(thisTTID)];



% load CSC data
%         tic;
cscData = loadCSC(cscID, ROOT.Raw.Mother, Params.CSCfileTag, Params.exportMODE, Params.behExtraction,'CSC');
[eeg_expand,Timestamps_expand] = expandCSC(cscData);

Wp = [4 12];   % passband edge frequencies
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

eeg_expand_reduced= filtfilt(sos, g, eeg_expand);

cscData_reduced = cscData;
colN = ceil(numel(eeg_expand_reduced)/512);
eeg_expand_reduced_add = [eeg_expand_reduced; zeros(colN*512-numel(eeg_expand_reduced),1)];
cscData_reduced.eeg = reshape(eeg_expand_reduced_add, 512, colN);

Switch = 'butterSwitch_export';
filename_tail = '4-12Hz filtered';
export_Mat2NlxCSC(cscData_reduced, cscData_reduced, [ROOT.Raw.Mother '\rat' thisRID '\rat' thisRID '-' thisSID], filename_tail, Switch)