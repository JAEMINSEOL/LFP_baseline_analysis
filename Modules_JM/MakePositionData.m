%%
clear all;
thisRIDPool = {'454'};
for ssRUN = 1:1
    thisRID = thisRIDPool{ssRUN};
thisSID=3;
%
cd(['H:\CA3_recording\CA3_DG\rat' thisRID '\CheetahData\BL1\ExtractedEvents'])
% t=TrialMatrix(4,:)+(1-TrialMatrix(4,:))*2;
% trial_set_all = [TrialMatrix(1:2,:);t]';
temp_t = csvread('sessionSummary.csv',1,0);
trial_set_all = horzcat(temp_t(:,1),temp_t(:,3),temp_t(:,2));


temp_s = csvread('sessionSummary.csv',1,5);
%
NonVoidID = find(temp_s(:,1)==1);
sensor_timestamp=temp_s(NonVoidID,2:8);
trial_set_all = trial_set_all(NonVoidID,:);
%
cd('F:\HPC-LFP Project\DG-CA3\AMB\2. SPK Data\variables for display (original)')
save(['rat' thisRID '-0' num2str(thisSID) '.mat'],'sensor_timestamp','trial_set_all')
% ST_Origin = textscan('sessionSummary.csv', '%d%d%d%d%d%d%f%f%f%f%f%f%f[^\n\r]', 'Delimiter', ',', 'EmptyValue' ,NaN, 'ReturnOnError', false);
end
%%
