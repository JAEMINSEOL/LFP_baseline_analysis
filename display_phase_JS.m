function fig = display_phase_JS(ROOT,thisCLUSTER,thisRegion, TargetTT)


%% load SPK data

[SpikeTime, SpikePosition, SpikeCell, UnrealCell, TTL1Time, FilteredPosition, FilteredTime, ...
    amb2skaggsrateMat,FogskaggsrateMat, amb1skaggsrateMat, amb0skaggsrateMat, stdskaggsrateMat, stdTrial, amb0Trial, amb1Trial, amb2Trial]...
    = get_raster_fog(thisCLUSTER, ROOT.Raw.Mother);


%% load theta band filtered LFP data
find_hypen = find(thisCLUSTER=='-');
thisRID = thisCLUSTER(1:find_hypen(1)-1);
thisSID = thisCLUSTER(find_hypen(1)+1:find_hypen(2)-1);
thisTTID = thisCLUSTER(find_hypen(2)+1:find_hypen(3)-1);
thisCLID = thisCLUSTER(find_hypen(3)+1:end);

cscID = [thisRID '-' thisSID '-' num2str(TargetTT)];

epochST = TTL1Time(1);
epochED = TTL1Time(end);

thisFileType = 'CSC';
CSCfileTag = 'RateReduced';
exportMODE = 0;
behExtraction = 1;



                    
                    CSCdata = loadCSC_JS(cscID,ROOT.Raw.Mother,CSCfileTag,exportMODE,behExtraction,epochST,epochED);
                    [EEG.eeg,EEG.timestamps] = expandCSC(CSCdata);


%% butterworth filter - bandpass
%
Wp = [4 12];   % passband edge frequencies
Ws = [2 14];   % stopband edge frequencies
Rp = 3;         % passband ripple of no more than Rp dB, When Rp is chosen as 3 dB, the Wn in BUTTER is equal to Wp in buttord.
Rs = 15;        % stopband attenuation of at least Rs dB
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


%% get phase of each spike


[PHASE_mat] = get_phase_JS(EEG,SpikeCell(:,stdTrial));


i = [];
for i=1:length(stdTrial)
    stdSpks(i)= length(cell2mat(SpikeCell(1,stdTrial(i))));
end

stdSpks = sum(stdSpks);


i = [];
for i=1:length(amb0Trial)
    amb0Spks(i)= length(cell2mat(SpikeCell(1,amb0Trial(i))));
end

amb0Spks = sum(amb0Spks);


r = corrcoef(stdskaggsrateMat(1,1:100), amb0skaggsrateMat(1,1:100));
ratemapR = r(2);

%%
fig = figure;
subplot(4,2,1)

plot(smoothdata(stdskaggsrateMat(1,1:100),'Movmean',5), 'k', 'linewidth',1.25)

%%
if stdSpks ==0
    ylabel 'FR (hz)'
    text(0,1.3,[thisCLUSTER '_ ' thisRegion],'Units','normalized', 'fontsize',11, 'FontWeight','bold')
    text(0,1.1,['pre-fog'],'Units','normalized', 'fontsize',9, 'FontWeight','bold')
    ylim([0 1])
    set(gca,'XTick',[])
        Stdphasestats.m = 0;
    Stdphasestats.r = [];
    Stdphasestats.k = [];
    Stdphasestats.p = 1;
    Stdphasedistros=[];
    subplot(4,2,2)
    
    phase_a = [];
    
    
else
    
    ylim([0 nanmax(stdskaggsrateMat(1,1:100))*1.15])
    ylabel 'FR (hz)'
    text(0,1.3,[thisCLUSTER '_ ' thisRegion],'Units','normalized', 'fontsize',11, 'FontWeight','bold')
    text(0,1.1,['pre-fog'],'Units','normalized', 'fontsize',9, 'FontWeight','bold')
    
    set(gca,'XTick',[])
    
    
    
    subplot(4,2,3)
    
    
    phase_a = PHASE_mat(:,1);
    
    phase_a = phase_a+180;
    
    plot(PHASE_mat(:,4)/500*3, phase_a, 'k.')
    hold on
    plot(PHASE_mat(:,4)/500*3, phase_a +360, 'k.')
    ylim([0 720])
    xlim([0 3])
    
    ylabel 'phase (θ)'
    set(gca,'XTick',[])
    
    
    hax = subplot(4,2,2);
    
    r = circ_plot(deg2rad(phase_a),'hist',[],20,true,true,'linewidth',2,'color','r');
    
    
    [Stdphasedistros,phasebins,ps]=CircularDistribution(circ_ang2rad(phase_a),'nBins',20);
    
    Stdphasestats.m = mod(ps.m,2*pi);
    Stdphasestats.r = ps.r;
    Stdphasestats.k = ps.k;
    Stdphasestats.p = ps.p;
    Stdphasestats.mode = ps.mode;
    
    
    h     = findall(gca,'type','text');
    legit = {'0','90','180','270',''};
    idx   = ~ismember(get(h,'string'),legit);
    set(h(idx),'string','')
    
    
    text(-0.65,-0.35,['Rayleigh p = ' num2str(Stdphasestats.p)],'Units','normalized', 'fontsize',8, 'FontWeight','bold')
    text(0.9,-0.35,['MRL = ' jjnum2str( Stdphasestats.r,2)],'Units','normalized', 'fontsize',8, 'FontWeight','bold')
    
    
    
    hax =  subplot(4,2,4);
    
    bar([(phasebins*180/pi)' ((phasebins*180/pi)+360)'],[Stdphasedistros' Stdphasedistros'],'k')
    xlim([0 720])
    set(hax,'XTick',[0 90 180 270 360 450 540 630 720])
    hold on;
    plot([0:720],cos((pi/180*([0:720]+180)))*0.25*max(Stdphasedistros)+0.5*max(Stdphasedistros),'color',[.7 .7 .7])
    ylim([0 max(Stdphasedistros)*1.2])
    
    xlabel 'phase (θ)'
    ylabel 'spike prob'
    
end
%%
if amb0Spks==0
    subplot(4,2,5)
        ylabel 'FR (hz)'
    text(0,1.3,[thisCLUSTER '_ ' thisRegion],'Units','normalized', 'fontsize',11, 'FontWeight','bold')
    text(0,1.1,['pre-fog'],'Units','normalized', 'fontsize',9, 'FontWeight','bold')
    ylim([0 1])
    set(gca,'XTick',[])
    Stdphasestats=[];
    subplot(4,2,6)
    
    phase_a = [];
amb0phasestats.m = 0;
amb0phasestats.r = [];
amb0phasestats.k = [];
amb0phasestats.p = 1;
amb0phasestats.mode = [];
amb0phasedistros=[];
else
subplot(4,2,5)

[PHASE_mat] = get_phase_JS(EEG,SpikeCell(:,[amb0Trial]));

plot(smoothdata(amb0skaggsrateMat(1,1:100),'Movmean',5), 'k', 'linewidth',1.25)
ylim([0 nanmax(amb0skaggsrateMat(1,1:100))*1.15])

ylabel 'FR (hz)'
set(gca,'XTick',[])
text(0,1.1,['post-fog'],'Units','normalized', 'fontsize',9, 'FontWeight','bold')



subplot(4,2,7)

phase_a = PHASE_mat(:,1);
phase_a = phase_a+180;

plot(PHASE_mat(:,4)/500*3, phase_a, 'k.')
hold on
plot(PHASE_mat(:,4)/500*3, phase_a +360, 'k.')
ylim([0 720])
xlim([0 3])

ylabel 'phase (θ)'
set(gca,'XTick',[])



hax = subplot(4,2,6);

r = circ_plot(deg2rad(phase_a),'hist',[],20,true,true,'linewidth',2,'color','r');


[amb0phasedistros,phasebins,ps]=CircularDistribution(circ_ang2rad(phase_a),'nBins',20);

amb0phasestats.m = mod(ps.m,2*pi);
amb0phasestats.r = ps.r;
amb0phasestats.k = ps.k;
amb0phasestats.p = ps.p;
amb0phasestats.mode = ps.mode;

h     = findall(gca,'type','text');
legit = {'0','90','180','270',''};
idx   = ~ismember(get(h,'string'),legit);
set(h(idx),'string','')


text(-0.65,-0.35,['Rayleigh p = ' num2str(amb0phasestats.p)],'Units','normalized', 'fontsize',8, 'FontWeight','bold')
text(0.9,-0.35,['MRL = ' jjnum2str( amb0phasestats.r,2)],'Units','normalized', 'fontsize',8, 'FontWeight','bold')


hax =  subplot(4,2,8);

bar([(phasebins*180/pi)' ((phasebins*180/pi)+360)'],[amb0phasedistros' amb0phasedistros'],'k')
xlim([0 720])
set(hax,'XTick',[0 90 180 270 360 450 540 630 720])
hold on;
plot([0:720],cos((pi/180*([0:720]+180)))*0.25*max(amb0phasedistros)+0.5*max(amb0phasedistros),'color',[.7 .7 .7])
ylim([0 max(amb0phasedistros)*1.2])

xlabel 'phase (θ)'
ylabel 'spike prob'
end


x0=50;
y0=100;
width=650;
height=550;
set(gcf,'units','points','position',[x0,y0,width,height])


ROOT.table = [ROOT.Save '\Tables\Phase\JSReplicate'];

if ~exist(ROOT.table,'dir'), mkdir(ROOT.table); end

save([ROOT.table '\' thisCLUSTER 'phase.mat'], 'stdSpks', 'amb0Spks', 'ratemapR', 'Stdphasestats', 'Stdphasedistros', 'amb0phasestats', 'amb0phasedistros');

end

