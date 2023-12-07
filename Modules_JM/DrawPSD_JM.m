function DrawPSD_JM(data, c)

%%
if c=='g'
params.tapers = [1 1];
else
   params.tapers = [3 5]; 
end
params.Fs = 2000;
params.fpass = [4 12];
params.pad = 2;
params.trialave=1;
[S,f] = mtspectrumc(data, params);

plot(f,S,c,'LineWidth',2)
ylim([1 100000])
set(gca, 'YScale', 'log','FontSize',12)
xlim([4 12])
xlabel('Frequency(Hz)'); ylabel('Power')

%%
% movingwin = [0.3 0.15];
% params.pad =2;
% [S,t,f]=mtspecgramc(data,movingwin,params);
% plot_matrix(S,t,f);
% colormap('jet')

