function DrawSpectrogram_JM_forHS(LFPData_aligned, movingwin,params)

%% example parameters
Theta_lowcut = 4;
Theta_highcut = 12;
movingwin = [1 0.02];
params.pad =3;
params.tapers = [3 5];
params.Fs = 2000;
params.fpass = [num2str(Theta_lowcut) Theta_highcut];
params.pad = 2;
params.trialave=1;

DivIDMax = 900000;
TBefDiv = 1.5*params.Fs;
TAftDiv = 1*params.Fs;
 FigSize = [600 200 800 600];


                %%
                sessionID = [thisRID '-' thisSID];

                [S,t,f]=mtspecgramc(LFPData_aligned(1:5000,:),movingwin,params);
                [S,t,f]=mtspecgramc(LFPData_aligned(DivIDMax-TBefDiv:DivIDMax+TAftDiv,:),movingwin,params);
                
                
                fig = figure('Position',FigSize);
                plot_matrix(S,t,f);
                colormap('jet')
                xlabel('Time (s)'); ylabel('Frequency (Hz)')
                set(gca, 'FontSize',12,'FontWeight','b');
                line([TBefDiv*1/params.Fs TBefDiv*1/params.Fs],params.fpass,'Color','k','LineWidth',2)
                text(TBefDiv*1/params.Fs+.05,6,'DivPnt','color','k')
    

                
end