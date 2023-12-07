function DrawRawEEG_Inbound_JM(EEG,index,ts_trial,trialNum_iter,sessionID,thisCSCID,RegionIndex)

plot(EEG.eeg,'k-');
                    EEGRawAbs = abs(EEG.eeg(index.eeg(1):index.eeg(end)));
                    EEG99 = mean(EEGRawAbs)+2*nanstd(EEGRawAbs);
                    ymax = max(round(EEG99*1.1*0.01)*100,500); if ymax==0 ymax=100; end
                    xlim([index.eeg(end) index.event(end)]);
                    ylim([-ymax ymax]);
                    
                    hold on;
                    ElapsedTime = round((ts_trial(end)-ts_trial(1))*100)/100;
                    set(gca,'FontSize',15,'xTick',[index.eeg(1) index.event],'xTickLabel',{'-0.5s' 'Open','S1','S2','S3','divPnt',['FW(' num2str(ElapsedTime) 's)'], 'End'});
                    ylabel('EEG (uV)');
                    title([sessionID ' - trial' num2str(trialNum_iter) ' - 3-300Hz (' 'TT' num2str(thisCSCID) ',' RegionIndex ')']);
                    for l=1:6
                        line([index.event(l) index.event(l)],[-ymax ymax],'Color','r')
                    end
end