function DrawSpectrogram_JM(LFPData_aligned, movingwin,params,thisRID,thisSID, thisCSCID,RegionIndex,Norm,DivIDMax)

                %%
                sessionID = [thisRID '-' thisSID];
                if Norm == 0
                
                [S,t,f]=mtspecgramc(LFPData_aligned(DivIDMax-TBefDiv:DivIDMax+TAftDiv,:),movingwin,params);
                
                
                fig = figure('Position',FigSize);
                plot_matrix(S,t,f);
                colormap('jet')
                xlabel('Time (s)'); ylabel('Frequency (Hz)')
                set(gca, 'FontSize',12,'FontWeight','b');
                line([TBefDiv*1/params.Fs TBefDiv*1/params.Fs],params.fpass,'Color','k','LineWidth',2)
                text(TBefDiv*1/params.Fs+.05,6,'DivPnt','color','k')
                title(['Spectrogram-rat' sessionID '-' 'TT' num2str(thisCSCID) '(' RegionIndex ')'])
                
                
                cd(['D:\HPC-LFP project\Spectrogram(1,0.02)'])
                saveImage(fig,['rat' thisRID '_' thisSID '_' 'TT' num2str(thisCSCID) '(' RegionIndex ')_ Spectrogram.jpg'],'pixels',FigSize)
                end
end