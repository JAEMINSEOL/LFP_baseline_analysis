function [pxx, f] = DrawPSD_JM(data, c,range)

%%
params.fs = 2000;
    Wp = [3 300];   % passband edge frequencies
    Ws = [2 310];   % stopband edge frequencies    
    Rp = 3;         % passband ripple of no more than Rp dB, When Rp is chosen as 3 dB, the Wn in BUTTER is equal to Wp in buttord.
    Rs = 15;        % stopband attenuation of at least Rs dB
    ftype = 'bandpass';
    Fn = params.fs/2;
    
    % frequency normalization
    Wp = Wp/Fn;
    Ws = Ws/Fn;
    
    [n,Wn] = buttord(Wp,Ws,Rp,Rs);  % n: order of filter, Wn: cutoff frequency      
    [z,p,k] = butter(4,Wn,ftype);
    [sos,g] = zp2sos(z,p,k);
    
    FilteredEEG.eeg = filtfilt(sos, g, data);
    



winsize = Fn; % 0.5-second window
hannw = .5 - cos(2*pi*linspace(0,1,winsize))./2; % 
% number of FFT points (frequency resolution)
nfft = Fn*2*3;
[pxx, f] = pwelch(FilteredEEG.eeg,hannw,round(winsize/2),nfft,Fn*2);

plot(f,smoothdata(10*log10(pxx),'Movmean',10),c,'linewidth',2) % power2db = 10log10


% ylim([1 100000])
set(gca,'FontSize',15,'fontweight','b')
xlim(range)
ylim([-10 50])
xticks([0:20:range(2)])
xlabel('Frequency(Hz)'); ylabel('PSD(dB/Hz)')

%%
% movingwin = [0.3 0.15];
% params.pad =2;
% [S,t,f]=mtspecgramc(data,movingwin,params);
% plot_matrix(S,t,f);
% colormap('jet')

