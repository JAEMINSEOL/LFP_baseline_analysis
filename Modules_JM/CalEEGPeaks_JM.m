function ScT = CalEEGPeaks_JM(EEG,index,MinPeakWidth,x,y,t)
ScT=[];
                    ETemp = (EEG.eeg(index.event(1):index.event(6)));
                    ETempT = EEG.timestamps(index.event(1):index.event(6));
                    [Peaks,Locs] = findpeaks(ETemp,'MinPeakDistance',MinPeakWidth);
                    if ~isempty(Locs)
                       ScT(:,1) =  ETempT(Locs);   
                       ScT(:,2) = interp1(t,y,ScT(:,1));          
                    ScT(1,3) = 0; dist=15;
                    ScT(2:length(ETempT(Locs)),3) = diff(ETempT(Locs));
% interp1(t,y,EEG.timestamps(index.event(2)))
%                     v = dist/(EEG.timestamps(index.event(4))-EEG.timestamps(index.event(3)));
%                     ScT(:,2) = (ETempT(Locs)-EEG.timestamps(index.event(5)))*v;
                    ScT(:,4)= ETemp(Locs);
                    
                   
%                     plot(ETemp)
%                     hold on
%                     scatter(Locs,ETemp(Locs))
                    end
end