
function fig = display_phase_common(Spk,thisCLUSTER,thisRegion,RefTT)


fig = figure;
subplot(2,2,1)

trial = arrayfun(@(x)max([find(Spk.trial_spk(x,:)),0]),(1:size(Spk.t_spk,1)))';
plot(Spk.x_spk(logical(trial)), trial(logical(trial)), 'r.')
hold on
scatter(Spk.x_spk(logical(~trial)), trial(logical(~trial)), 5,[.5 .5 .5],'filled')

ylim([0 size(Spk.trial_spk,2)])
ylabel 'trial'
xlabel 'postion(cm)'
text(0,1.1,[thisCLUSTER '_ ' thisRegion],'Units','normalized', 'fontsize',11, 'FontWeight','bold')



%%
subplot(2,2,3)

phase = Spk.phase_spk(:,RefTT );

phase = phase+180;

plot(Spk.x_spk(logical(trial)), phase(logical(trial)), 'r.')
hold on
plot(Spk.x_spk(logical(trial)), phase(logical(trial)) +360, 'r.')

scatter(Spk.x_spk(logical(~trial)), phase(logical(~trial)), 5,[.5 .5 .5],'filled')
scatter(Spk.x_spk(logical(~trial)), phase(logical(~trial)) +360, 5,[.5 .5 .5],'filled')
ylim([0 720])
xlim([0 300])

ylabel 'phase (θ)'
xlabel 'postion(cm)'

%%
hax = subplot(2,2,2);

r = circ_plot(deg2rad(phase),'hist',[],20,true,true,'linewidth',2,'color','r');


[Stdphasedistros,phasebins,ps]=CircularDistribution(circ_ang2rad(phase),'nBins',20);

Stdphasestats.m = mod(ps.m,2*pi);
Stdphasestats.r = ps.r;
Stdphasestats.k = ps.k;
Stdphasestats.p = ps.p;
Stdphasestats.mode = ps.mode;


h     = findall(gca,'type','text');
legit = {'0','90','180','270',''};
idx   = ~ismember(get(h,'string'),legit);
set(h(idx),'string','')


text(-0.65,-0.35,['Rayleigh p = ' num2str(Stdphasestats.p)],'Units','normalized', 'fontsize',10, 'FontWeight','bold')
text(0.9,-0.35,['MRL = ' jjnum2str( Stdphasestats.r,2)],'Units','normalized', 'fontsize',10, 'FontWeight','bold')


%%
hax =  subplot(2,2,4);

bar([(phasebins*180/pi)' ((phasebins*180/pi)+360)'],[Stdphasedistros' Stdphasedistros'],'r')
xlim([0 720])
set(hax,'XTick',[0 90 180 270 360 450 540 630 720])
hold on;
plot([0:720],cos((pi/180*([0:720]+180)))*0.25*max(Stdphasedistros)+0.5*max(Stdphasedistros),'color',[.7 .7 .7])
ylim([0 max(Stdphasedistros)*1.2])

xlabel 'phase (θ)'
ylabel 'spike prob'
%%
x0=50;
y0=100;
width=650;
height=300;
set(gcf,'units','points','position',[x0,y0,width,height])


end